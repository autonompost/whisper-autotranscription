#!/usr/bin/env bash
# execute this script to automatically transcribe audio files on a cloud provider of choice

# functions

# check requirements
__checkreq() {
  [ -f $CONFIGFILE ] || { echo "Error: config file ${CONFIGFILE} cannot be found or is not readable"; exit 1; }
  source $CONFIGFILE
  [ -f $SECRETSFILE ] || { echo "Error: config file ${SECRETSFILE} cannot be found or is not readable"; exit 1; }
  source $SECRETSFILE
  [ -x "$(command -v ansible)" ] \
    || { echo "Error: ansible is not installed or not executable"; exit 1; }
  [ -x "$(command -v ansible-playbook)" ] \
    || { echo "Error: ansible-playbook is not installed or not executable"; exit 1; }
  [ -x "$(command -v terraform)" ] \
    || { echo "Error: terraform is not installed or not executable"; exit 1; }
}

__enablelog() {
  echo "do something"
}

__sshkeygen() {
  if [ ! -f "${BASEDIR}/id_rsa" ]
  then
    ssh-keygen -t rsa -b 4096 -N "" -f $(pwd)/id_rsa
  elif [ $SSH_CREATE_KEY_FORCE = "true" ]
  then
    [ -f ${BASEDIR}/id_rsa ] && rm -f $(pwd)/id_rsa
    ssh-keygen -t rsa -b 4096 -N "" -f $(pwd)/id_rsa
  fi
}

# distribute files for ansible upload
__distributefiles() {
  [ ! -d $DST_DIR ] && mkdir -p $DST_DIR
  if (( $NUMVMS > 1 ))
  then
    readarray -t files < <(find "$SRC_DIR" -type f | grep -E "*.mp3|*.wav")
    files_per_dir=$(( ${#files[@]} / $NUMVMS ))
    if [ $(( ${#files[@]} % $NUMVMS )) -gt 0 ]
    then
      files_per_dir=$(( files_per_dir + 1 ))
    fi

    split -l $files_per_dir -d -a 1 <(printf '%s\n' "${files[@]}") vm-whisper-

    find . -name "vm-whisper-*" -print0 | while IFS= read -r -d '' file
    do
      sub_dir="${DST_DIR}/${file}"
      echo "subdir $sub_dir"

      if [ ! -d "$sub_dir" ]
      then
        mkdir -p "$sub_dir"
      fi

      while read line
      do
        printf '%s\n' "$line"
        cp "${line}" "$sub_dir/" \
          || { echo "Error: could not copy file to ${sub_dir}"; exit 1; }
      done < "$file"
      [ -f "$file" ] && rm -f $file
    done

  else
    target_filedir="${DST_DIR}/vm-whisper-0/"
    echo "target_filedir: ${target_filedir}"

    OIFS="$IFS"
    IFS=$'\n'

    for ext in "${extensions[@]}"
    do
      files=$(find "$SRC_DIR" -type f -name "*.$ext" -print)

      [ ! -d $target_filedir ] && mkdir $target_filedir
      for file in $files
      do

        if [ ! -f "$target_filedir$(basename "$file")" ]
        then
          echo "copying file: ${file}"
          cp "$file" "$target_filedir$(basename "$file")" \
            || { echo "Error: could not copy file to ${target_filedir}"; exit 1; }
        else
          echo "file exists already: ${file}"
        fi
      done
    done
    IFS="$OIFS"
  fi
}

__cleanup() {
  dirtodelete=$(find "${DST_DIR}" -maxdepth 1 -mindepth 1 -type d)
  for dir in $dirtodelete
  do
    [ -d $dir ] && rm -rf $dir
  done

  [ -f "${CONFIG_DIR}/${TFVARSNUMVMS}" ] && rm -f ${CONFIG_DIR}/${TFVARSNUMVMS}
  [ -f "${BASEDIR}/ansible/group_vars/all/${ANSIBLETEMPLATE}" ] && rm -f ${BASEDIR}/ansible/group_vars/all/${ANSIBLETEMPLATE}
}

__doobsidian() {
 echo "do something"
}

__dogetcpu() {
  # get the cpu for whisper threading information from the API of the CLOUDPROVIDER being used
  cp "${BASEDIR}/templates/${ANSIBLETEMPLATE}" ${BASEDIR}/ansible/group_vars/all/${ANSIBLETEMPLATE} \
    || { echo "Error: could not copy ${ANSIBLETEMPLATE} to ${BASEDIR}/ansible/group_vars/all"; exit 1; }

  # in order to only have the instance_type variable in the tfvars file, get it here as shell var
  instance_type=$(grep -E "^instance_type" ${TFVARS} | perl -pe 's/^(instance_type.*)"(.*)"/$2/')

  [ ! -z $instance_type ] \
    || { echo "__dogetcpu: ERROR - instance_type is empty"; exit 1; }

  case $CLOUDPROVIDER in
    hetzner)
      set -x
      THREADS=$(curl -s -H "Authorization: Bearer ${HCLOUD_TOKEN}" "https://api.hetzner.cloud/v1/server_types" \
        | jq -r --arg i "${instance_type}" '.server_types[] | select(.name == $i) | .cores')
      set +x
      ;;
    linode)
      THREADS=$(curl -s -H "Authorization: Bearer ${LINODE_TOKEN}" "https://api.linode.com/v4/linode/types" \
        | jq -r --arg i "${instance_type}" ".data[] | select(.id == $i) | .vcpus")
      ;;
    digitalocean)
      THREADS=$(curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${DO_TOKEN}" \
        "https://api.digitalocean.com/v2/sizes?per_page=200" \
        | jq -r --arg i "${instance_type}" ".sizes[] | select(.slug == $i) | .vcpus")
      ;;
    ovh)
      THREADS=$(openstack flavor list -f json | jq -r --arg i "${instance_type}" '.[] | select(.Name == $i) | .VCPUs')
      ;;
    *)
      echo "__dogetcpu: I should never be here" && exit 1
      ;;
  esac
  sed -i -e "s/THREADS/$THREADS/" ${BASEDIR}/ansible/group_vars/all/$ANSIBLETEMPLATE \
    || { echo "Error: could not change THREADS in ${ANSIBLETEMPLATE} to ${THREADS}"; exit 1; }
  echo "threads: ${THREADS}"
}

__doterraform() {
  tfmode=$1

  # copy template to config for the terraform runtime
  cp "$TFTEMPLATE" ${CONFIG_DIR}/${TFVARSNUMVMS} \
    || { echo "Error: could not copy ${TFVARSNUMVMS} to ${CONFIG_DIR}"; exit 1; }
  sed -i -e "s/NUMVMS/$NUMVMS/" ${CONFIG_DIR}/${TFVARSNUMVMS}

  case $CLOUDPROVIDER in
    hetzner)
      cd ${BASEDIR}/$CLOUDPROVIDER || { echo "Error: could not chdir to ${CLOUDPROVIDER}"; exit 1; }
      terraform init
      terraform $tfmode -auto-approve -var="hcloud_token=${HCLOUD_TOKEN}" -var-file="${CONFIG_DIR}/variables.tfvars" -var-file="${CONFIG_DIR}/${TFVARSNUMVMS}"
      ;;
    linode)
      cd ${BASEDIR}/$CLOUDPROVIDER || { echo "Error: could not chdir to ${CLOUDPROVIDER}"; exit 1; }
      terraform init
      terraform $tfmode -auto-approve -var-file="${CONFIG_DIR}/variables.tfvars" -var-file="${CONFIG_DIR}/${TFVARSNUMVMS}"
      ;;
    digitalocean)
      cd ${BASEDIR}/$CLOUDPROVIDER || { echo "Error: could not chdir to ${CLOUDPROVIDER}"; exit 1; }
      terraform init
      terraform $tfmode -auto-approve -var="do_token=${DO_TOKEN}" -var-file="${CONFIG_DIR}/variables.tfvars" -var-file="${CONFIG_DIR}/${TFVARSNUMVMS}"
      ;;
    ovh)
      source ${CONFIG_DIR}/openrc.sh \
        || { echo "Error: could source openrc.sh openstack config for ${CLOUDPROVIDER}"; exit 1; }
      cd ${BASEDIR}/$CLOUDPROVIDER || { echo "Error: could not chdir to ${CLOUDPROVIDER}"; exit 1; }
      terraform init
      terraform $tfmode -auto-approve -var-file="${CONFIG_DIR}/variables.tfvars" -var-file="${CONFIG_DIR}/${TFVARSNUMVMS}"
      ;;
    *)
      echo "not supported cloud provider: ${CLOUDPROVIDER}"
      exit 1
      ;;
  esac
}

__doansible() {
  export ANSIBLE_HOST_KEY_CHECKING=False
  if [ $USE_GPU = "true" ]
  then
    cp "${BASEDIR}/templates/playbook_gpu.yaml" ${BASEDIR}/ansible/playbook.yaml \
      || { echo "Error: could not copy ${BASEDIR}/templates/playbook_gpu.yaml to ${BASEDIR}/ansible/playbook.yaml"; exit 1; }
    [ -d ${BASEDIR}/ansible ] && ansible-playbook -i hosts.cfg playbook.yaml
  elif [ $USE_GPU = "true" ]
  then
    cp "${BASEDIR}/templates/playbook_default.yaml" ${BASEDIR}/ansible/playbook.yaml \
      || { echo "Error: could not copy ${BASEDIR}/templates/playbook_default.yaml to ${BASEDIR}/ansible/playbook.yaml"; exit 1; }
    [ -d ${BASEDIR}/ansible ] && ansible-playbook -i hosts.cfg playbook.yaml
  fi
}

__main() {
  [ -z $CONFIGFILE ] && CONFIGFILE="`pwd`/config/config.sh"
  [ -z $NUMVMS ] && NUMVMS=1
  __checkreq
  [ $LOGGING = "true" ] && __enablelog
  [ $SSH_CREATE_KEY = "true" ] && __sshkeygen
  __distributefiles
  __doterraform apply
  __dogetcpu
  [ $ANSIBLE = "true" ] && __doansible
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
        f ) CONFIGFILE=$OPTARG
            ;;
        n ) NUMVMS=$OPTARG
            ;;
        h ) __show_help
            exit 0
            ;;
        \? ) echo "Invalid option: -$OPTARG" 1>&2
            __show_help
            exit 1
            ;;
    esac
done

__main
