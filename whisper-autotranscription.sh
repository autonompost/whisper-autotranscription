#!/usr/bin/env bash
# execute this script to automatically transcribe audio files on a cloud provider of choice

# functions

# check requirements
__checkreq() {
  [ -f $FILE ] || { echo "Error: config file ${FILE} cannot be found or is not readable"; exit 1; }
  source $FILE
  [ -x "$(command -v ansible)" ] || { echo "Error: ansible is not installed or not executable"; exit 1; }
  [ -x "$(command -v ansible-playbook)" ] || { echo "Error: ansible-playbook is not installed or not executable"; exit 1; }
  [ -x "$(command -v terraform)" ] || { echo "Error: terraform is not installed or not executable"; exit 1; }
}

__sshkeygen() {
  if [ ! -f "$(pwd)/id_rsa" ]
  then
    ssh-keygen -t rsa -b 4096 -N "" -f $(pwd)/id_rsa
  fi
}

# distribute files for ansible upload
__distributefiles() {
  [ ! -d $dst_filedir ] && mkdir -p $dst_filedir
  if (( $NUMVMS > 1 ))
  then
    readarray -t files < <(find "$src_filedir" -type f | grep -E "*.mp3|*.wav")
    files_per_dir=$(( ${#files[@]} / $NUMVMS ))
    if [ $(( ${#files[@]} % $NUMVMS )) -gt 0 ]
    then
      files_per_dir=$(( files_per_dir + 1 ))
    fi

    split -l $files_per_dir -d -a 1 <(printf '%s\n' "${files[@]}") xaa

    find . -name "xaa*" -print0 | while IFS= read -r -d '' file
    do
      sub_dir="${dst_filedir}/`echo $file | sed 's/\.\/xaa//'`/"
      echo "subdir $sub_dir"

      if [ ! -d "$sub_dir" ]
      then
        mkdir -p "$sub_dir"
      fi

      while read line
      do
        printf '%s\n' "$line"
        cp "${line}" "$sub_dir/" || { echo "Error: could not copy file to ${sub_dir}"; exit 1; }
      done < "$file"
      [ -f "$file" ] && rm -f $file
    done

  else
    target_filedir="${dst_filedir}/1/"
    echo "target_filedir: ${target_filedir}"

    OIFS="$IFS"
    IFS=$'\n'

    for ext in "${extensions[@]}"
    do
      files=$(find "$src_filedir" -type f -name "*.$ext" -print)

      [ ! -d $target_filedir ] && mkdir $target_filedir
      for file in $files
      do

        if [ ! -f "$target_filedir$(basename "$file")" ]
        then
          echo "copying file: ${file}"
          cp "$file" "$target_filedir$(basename "$file")" || { echo "Error: could not copy file to ${target_filedir}"; exit 1; }
        else
          echo "file exists already: ${file}"
        fi
      done
    done
    IFS="$OIFS"
  echo bar
  fi
}

__cleanup() {
  dirtodelete=$(find "${dst_filedir}" -maxdepth 1 -mindepth 1 -type d)
  for dir in $dirtodelete
  do
    [ -d $dir ] && rm -rf $dir
  done

  [ -f "${config_dir}/${tfvarsnumvms}" ] && rm -f ${config_dir}/${tfvarsnumvms}
}

__doobsidian() {
 echo "do something"
}

__dogetcpu() {
  # get the cpu for whisper threading information from the API of the cloudprovider being used
  case $cloudprovider in
    hetzner)
      THREADS=$(curl -s -H "Authorization: Bearer ${HCLOUD_TOKEN}" "https://api.hetzner.cloud/v1/server_types" \
        | jq -r '.server_types[] | select(.name == "${instance_type}") | .cores')
      ;;
    linode)
      THREADS=$(curl -s -H "Authorization: Bearer ${LINODE_TOKEN}" "https://api.linode.com/v4/linode/types" \
        | jq -r ".data[] | select(.id == \"${instance_type}\") | .vcpus")
      ;;
    digitalocean)
      THREADS=$(curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${DO_TOKEN}" \
        "https://api.digitalocean.com/v2/sizes?per_page=200" \
        | jq -r ".sizes[] | select(.slug == \"${instance_type}\") | .vcpus")
      ;;
    ovh)
      THREADS=$(openstack flavor list -f json | jq '.[] | select(.Name == "${instance_type}") | .VCPUs')
      ;;
    *)
      echo "do something"
      ;;
  esac
}

__doterraform() {
  tfmode=$1

  # copy template to config for the terraform runtime
  cp "$numvmstemplate" ${config_dir}/${tfvarsnumvms} || { echo "Error: could not copy ${tfvarsnumvms} to ${config_dir}"; exit 1; }
  sed -i -e "s/NUMVMS/$NUMVMS/" ${config_dir}/${tfvarsnumvms}

  case $cloudprovider in
    hetzner)
      cd $(pwd)/$cloudprovider || { echo "Error: could not chdir to ${cloudprovider}"; exit 1; }
      terraform init
      terraform $tfmode -auto-approve -var="hcloud_token=${HCLOUD_TOKEN}" -var-file="../config/variables.tfvars"
      ;;
    linode)
      cd $(pwd)/$cloudprovider || { echo "Error: could not chdir to ${cloudprovider}"; exit 1; }
      terraform init
      terraform $tfmode -auto-approve -var-file="../config/variables.tfvars"
      ;;
    digitalocean)
      cd $(pwd)/$cloudprovider || { echo "Error: could not chdir to ${cloudprovider}"; exit 1; }
      terraform init
      terraform $tfmode -auto-approve -var="do_token=${DO_TOKEN}" -var-file="../config/variables.tfvars"
      ;;
    ovh)
      source $(pwd)/config/openrc.sh || { echo "Error: could source openrc.sh openstack config for ${cloudprovider}"; exit 1; }
      cd $(pwd)/cloudprovider || { echo "Error: could not chdir to ${cloudprovider}"; exit 1; }
      terraform init
      terraform $tfmode -auto-approve -var="do_token=${DO_TOKEN}" -var-file="../config/variables.tfvars"
      ;;
    *)
      echo "not supported cloud provider: ${cloudprovider}"
      exit 1
      ;;
  esac
}

__doansible() {
  export ANSIBLE_HOST_KEY_CHECKING=False
  [ -d $(pwd)/ansible ] && ansible-playbook -i hosts.cfg playbook.yaml
}

__main() {
  [ -z $FILE ] && FILE="config/config.sh"
  [ -z $NUMVMS ] && NUMVMS=1
  __checkreq
  __distributefiles
  __doterraform apply
  __dogetcpu
  __doansible
  [ $OBSIDIAN = "true" ] && __doobsidian
  [ $CLEANUP = "true" ] && __cleanup
  [ $TFDESTROY = "true" ] && __doterraform destroy
}

__show_help() {
    echo "Usage: $0 [-f CONFIGFILE] [-n NUMBER VMS] [-h]"
    echo "  -f CONFIGFILE Specify a config file"
    echo "  -n NUMVMS     Specify a number of VMS to create"
    echo "  -h            Display this help message"
}

# Parse command-line options
while getopts "f:n:h" opt; do
    case ${opt} in
        f ) # Process -f option
            FILE=$OPTARG
            ;;
        n ) # Process -n option
            NUMVMS=$OPTARG
            ;;
        h ) # Display help information
            __show_help
            exit 0
            ;;
        \? ) # Invalid option
            echo "Invalid option: -$OPTARG" 1>&2
            __show_help
            exit 1
            ;;
    esac
done

__main
