#!/usr/bin/env bash
# execute this script to automatically transcribe audio files on a cloud provider of choice

# start logging
cdatetime=`date +"%Y%m%d-%H%M%S"`
if [ $LOGGING = "true" ]
then
  # start logging to file
  echo "Logging to file ${BASEDIR}/${LOG_DIR}/${cdatetime}.log"
  exec > >(tee -a ${BASEDIR}/${LOG_DIR}/${cdatetime}.log) 2>&1
fi

# functions

# check requirements
__checkreq() {
  [ -f ${CONFIGFILE} ] \
    || { echo "Error: config file ${CONFIGFILE} cannot be found or is not readable"; exit 1; }
  source ${CONFIGFILE}
  [ -f ${BASEDIR}/${CONFIG_DIR}/${SECRETSFILE} ] \
    || { echo "Error: config file ${BASEDIR}/${CONFIG_DIR}/${SECRETSFILE} cannot be found or is not readable"; exit 1; }
  source ${BASEDIR}/${CONFIG_DIR}/${SECRETSFILE}

  # check if the source directory exists
  [ -d ${BASEDIR}/${SRC_DIR} ] \
    || { echo "Error: source directory ${BASEDIR}/${SRC_DIR} cannot be found or is not readable"; exit 1; }

  # check if the destination directory exists
  [ -d ${BASEDIR}/${DST_DIR} ] \
    || { echo "Error: destination directory ${BASEDIR}/${DST_DIR} cannot be found or is not readable"; exit 1; }

  # check if the config directory exists
  [ -d ${BASEDIR}/${CONFIG_DIR} ] \
    || { echo "Error: config directory ${BASEDIR}/${CONFIG_DIR} cannot be found or is not readable"; exit 1; }

  # check if the ansible directory exists
  [ -d ${BASEDIR}/ansible ] \
    || { echo "Error: ansible directory ${BASEDIR}/ansible cannot be found or is not readable"; exit 1; }

  [ -x "$(command -v ansible)" ] \
    || { echo "Error: ansible is not installed or not executable"; exit 1; }
  [ -x "$(command -v ansible-playbook)" ] \
    || { echo "Error: ansible-playbook is not installed or not executable"; exit 1; }
  [ -x "$(command -v terraform)" ] \
    || { echo "Error: terraform is not installed or not executable"; exit 1; }
}

__sshkeygen() {

  # create ssh key if it does not exist
  if [ ! -f "${BASEDIR}/id_rsa" ]
  then
    ssh-keygen -t rsa -b 4096 -N "" -f ${BASEDIR}/id_rsa
  elif [ $SSH_CREATE_KEY_FORCE = "true" ] # create ssh key if it exists and force is set to true
  then
    [ -f ${BASEDIR}/id_rsa ] && rm -f ${BASEDIR}/id_rsa
    ssh-keygen -t rsa -b 4096 -N "" -f ${BASEDIR}/id_rsa
  fi
}

# distribute files for ansible upload
__distributefiles() {

  # create a directory for the files to be distributed
  [ ! -d ${BASEDIR}/${DST_DIR} ] && mkdir -p ${BASEDIR}/${DST_DIR}
  if (( $NUMVMS > 1 ))
  then

    # split files into NUMVMS directories
    readarray -t files < <(find "${BASEDIR}/${SRC_DIR}" -type f | grep -E "*.mp3$|*.wav$")

    # calculate the number of files per directory
    files_per_dir=$(( ${#files[@]} / $NUMVMS ))

    # if there are files left over, add one more file to the last directory
    if [ $(( ${#files[@]} % $NUMVMS )) -gt 0 ]
    then
      files_per_dir=$(( files_per_dir + 1 ))
    fi

    # split the files into NUMVMS directories
    split -l $files_per_dir -d -a 1 <(printf '%s\n' "${files[@]}") vm-whisper-

    # copy the files to the destination directory
    find . -name "vm-whisper-*" -print0 | while IFS= read -r -d '' file
    do
      sub_dir="${BASEDIR}/${DST_DIR}/${file}"
      echo "subdir $sub_dir"

      [ ! -d "$sub_dir" ] && mkdir -p "$sub_dir"

      while read line
      do
        printf '%s\n' "$line"
        cp "${line}" "$sub_dir/" \
          || { echo "Error: could not copy file to ${sub_dir}"; exit 1; }
      done < "$file"
      [ -f "$file" ] && rm -f $file
    done

  else
    target_filedir="${BASEDIR}/${DST_DIR}/vm-whisper-0/"
    echo "target_filedir: ${target_filedir}"

    files=$(find "${BASEDIR}/${SRC_DIR}" -type f | grep -E "*.mp3$|*.wav$")

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
  fi
}

__exit_handler() {

  # exit handler
  exit_code=$?
  if [[ $exit_code -eq 0 ]]
  then
    echo "Command exited successfully"
  else
    echo "Command exited with an error: $exit_code"
    __cleanup # call cleanup function
  fi
}

__cleanup() {

  dirtodelete=$(find "${BASEDIR}/${DST_DIR}" -maxdepth 1 -mindepth 1 -type d) # get all directories in the destination directory
  for dir in $dirtodelete
  do
    [ -d $dir ] && rm -rf $dir
  done

  [ -f "${BASEDIR}/${CONFIG_DIR}/${TFVARSNUMVMS}" ] && rm -f ${BASEDIR}/${CONFIG_DIR}/${TFVARSNUMVMS}
  [ -f "${BASEDIR}/ansible/group_vars/all/${ANSIBLETEMPLATE}" ] && rm -f ${BASEDIR}/ansible/group_vars/all/${ANSIBLETEMPLATE}
}

__doobsidian() {
 echo "do something"
}

__docopyouput() {
  # copy output files to the source directory

  # get all files from the output directory
  readarray -t download_array < <(find $BASEDIR/$DST_DIR/output -type f -exec basename {} \; | sed 's/\.[^.]*$//')

  # get unique files from the output directory
  download_unique_array=($(printf "%s\n" "${download_array[@]}" | sort -u))

  # get all files from the source directory
  readarray -t upload_array < <(find $BASEDIR/$SRC_DIR -type f | grep -E "*.mp3$|*.wav$")
  
  # iterate over the unique files and copy them to the source directory
  for i in "${download_unique_array[@]}"
  do
      for f in "${upload_array[@]}"
      do
          if [[ "$f" =~ ${i}\.(mp3|wav)$ ]]
          then
              echo "found $i in $f"
              dir=$(dirname "$f")
              echo "target directory for all ${i} files: $dir"

              # copy all files with the same name to the source directory, overwrite only if newer
              cp -u $BASEDIR/$DST_DIR/output/${i}.* "$dir"
          fi
      done
  done
}

__dogetcpu() {

  # copy the template file to the ansible group_vars directory
  cp "${BASEDIR}/${TEMPLATE_DIR}/${ANSIBLETEMPLATE}" ${BASEDIR}/ansible/group_vars/all/${ANSIBLETEMPLATE} \
    || { echo "Error: could not copy template ${ANSIBLETEMPLATE} to ${BASEDIR}/ansible/group_vars/all"; exit 1; }

  # in order to only have the instance_type variable in the tfvars file, get it here as shell var
  instance_type=$(grep -E "^instance_type" ${BASEDIR}/${CONFIG_DIR}/${TFVARS} | grep -oP '(?<=")[^"]+(?=")')

  [ ! -z $instance_type ] \
    || { echo "__dogetcpu: ERROR - instance_type is empty"; exit 1; }

  # get the number of threads for whisper threading information from the API of the CLOUDPROVIDER being used
  case $CLOUDPROVIDER in
    hetzner)
      THREADS=$(curl -s -H "Authorization: Bearer ${HCLOUD_TOKEN}" "https://api.hetzner.cloud/v1/server_types" \
        | jq -r --arg i "${instance_type}" '.server_types[] | select(.name == $i) | .cores')
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
    gcp)
      [ -x "$(command -v gcloud)" ] \
        || { echo "Error: gcloud cli is not installed or not executable"; exit 1; }
      zone=$(grep -E "^zone" ${BASEDIR}/${CONFIG_DIR}/${TFVARS} | grep -oP '(?<=")[^"]+(?=")')
      THREADS=$(gcloud compute machine-types describe ${instance_type} --format="value(guestCpus)" --zone ${zone})
      ;;
    ovh)
      [ -x "$(command -v openstack)" ] \
        || { echo "Error: openstack is not installed or not executable"; exit 1; }
      THREADS=$(openstack flavor list -f json | jq -r --arg i "${instance_type}" '.[] | select(.Name == $i) | .VCPUs')
      ;;
    *)
      echo "__dogetcpu: I should never be here" && exit 1
      ;;
  esac

  # change the template file to the actual number of threads
  sed -i -e "s/THREADS/$THREADS/" ${BASEDIR}/ansible/group_vars/all/$ANSIBLETEMPLATE \
    || { echo "Error: could not change THREADS in ${ANSIBLETEMPLATE} to ${THREADS}"; exit 1; }
}

__doterraform() {
  tfmode=$1 # apply or destroy

  # copy template to config for the terraform runtime
  cp "${BASEDIR}/${TEMPLATE_DIR}/${TFTEMPLATE}" ${BASEDIR}/${CONFIG_DIR}/${TFTEMPLATE} \
    || { echo "Error: could not copy template ${TFTEMPLATE} to ${BASEDIR}/${CONFIG_DIR}"; exit 1; }
  sed -i -e "s/NUMVMS/$NUMVMS/" ${BASEDIR}/${CONFIG_DIR}/${TFTEMPLATE}

  # depending on the cloudprovider, run terraform with the correct variables
  case $CLOUDPROVIDER in
    hetzner)
      cd ${BASEDIR}/$CLOUDPROVIDER || { echo "Error: could not chdir to ${CLOUDPROVIDER}"; exit 1; }
      terraform init || { echo "Error: terraform init failed"; exit 1; }
      terraform $tfmode -auto-approve -var="hcloud_token=${HCLOUD_TOKEN}" \
        -var-file="${BASEDIR}/${CONFIG_DIR}/${TFVARS}" -var-file="${BASEDIR}/${CONFIG_DIR}/${TFTEMPLATE}" \
        || echo "Error: terraform $tfmode failed" && exit 1
      ;;
    linode)
      cd ${BASEDIR}/$CLOUDPROVIDER || { echo "Error: could not chdir to ${CLOUDPROVIDER}"; exit 1; }
      terraform init || { echo "Error: terraform init failed"; exit 1; }
      terraform $tfmode -auto-approve  -var="linode_token=${LINODE_TOKEN}" \
        -var-file="${BASEDIR}/${CONFIG_DIR}/${TFVARS}" -var-file="${BASEDIR}/${CONFIG_DIR}/${TFTEMPLATE}" \
        || echo "Error: terraform $tfmode failed" && exit 1
      ;;
    digitalocean)
      cd ${BASEDIR}/$CLOUDPROVIDER || { echo "Error: could not chdir to ${CLOUDPROVIDER}"; exit 1; }
      terraform init || { echo "Error: terraform init failed"; exit 1; }
      terraform $tfmode -auto-approve -var="do_token=${DO_TOKEN}" \
        -var-file="${BASEDIR}/${CONFIG_DIR}/${TFVARS}" -var-file="${BASEDIR}/${CONFIG_DIR}/${TFTEMPLATE}" \
        || echo "Error: terraform $tfmode failed" && exit 1
      ;;
    gcp)
      cd ${BASEDIR}/$CLOUDPROVIDER || { echo "Error: could not chdir to ${CLOUDPROVIDER}"; exit 1; }
      [ $(gcloud auth list --filter=status:ACTIVE  --format="value(account)" | wc -l) -gt 0 ] && echo "gcloud auth ok" \
        || { echo "Error: gcloud auth is not ok"; exit 1; }
      terraform init || { echo "Error: terraform init failed"; exit 1; }
      terraform $tfmode -auto-approve -var-file="${BASEDIR}/${CONFIG_DIR}/${TFVARS}" \
        -var-file="${BASEDIR}/${CONFIG_DIR}/${TFTEMPLATE}" || echo "Error: terraform $tfmode failed" && exit 1
      ;;
    ovh)
      source ${CONFIG_DIR}/openrc.sh \
        || { echo "Error: could source openrc.sh openstack config for ${CLOUDPROVIDER}"; exit 1; }
      cd ${BASEDIR}/$CLOUDPROVIDER || { echo "Error: could not chdir to ${CLOUDPROVIDER}"; exit 1; }
      terraform init || { echo "Error: terraform init failed"; exit 1; }
      terraform $tfmode -auto-approve -var-file="${BASEDIR}/${CONFIG_DIR}/${TFVARS}" \
        -var-file="${BASEDIR}/${CONFIG_DIR}/${TFTEMPLATE}" || echo "Error: terraform $tfmode failed" && exit 1
      ;;
    *)
      echo "not supported cloud provider: ${CLOUDPROVIDER}"
      exit 1
      ;;
  esac
}

__doansible() {
  # turn off host key checking for ansible
  export ANSIBLE_HOST_KEY_CHECKING=False
  if [ $USE_GPU = "true" ]
  then
    # copy template to config for the ansible runtime
    cp "${BASEDIR}/${TEMPLATE_DIR}/playbook_cuda.yaml" ${BASEDIR}/ansible/playbook.yaml \
      || { echo "Error: could not copy ${BASEDIR}/${TEMPLATE_DIR}/playbook_cuda.yaml to ${BASEDIR}/ansible/playbook.yaml"; exit 1; }

    # cd to ansible dir
    [ -d ${BASEDIR}/ansible ] && cd $BASEDIR/ansible

    # run ansible
    ansible-playbook -i hosts.cfg playbook.yaml || exit 1
  elif [ $USE_GPU = "false" ]
  then
    # copy template to config for the ansible runtime
    cp "${BASEDIR}/${TEMPLATE_DIR}/playbook_default.yaml" ${BASEDIR}/ansible/playbook.yaml \
      || { echo "Error: could not copy ${BASEDIR}/${TEMPLATE_DIR}/playbook_default.yaml to ${BASEDIR}/ansible/playbook.yaml"; exit 1; }

    # cd to ansible dir
    [ -d ${BASEDIR}/ansible ] && cd $BASEDIR/ansible

    # run ansible
    ansible-playbook -i hosts.cfg playbook.yaml || exit 1
  fi
}

__main() {
  # check if config file is given
  [ -z $CONFIGFILE ] && CONFIGFILE="${BASEDIR}/${CONFIG_DIR}/config.sh"
  [ -z $NUMVMS ] && NUMVMS=1
  __checkreq
  [ $LOGGING = "true" ] && __enablelog
  [ $SSH_CREATE_KEY = "true" ] && __sshkeygen
  __distributefiles
  __doterraform apply
  __dogetcpu
  [ $ANSIBLE = "true" ] && __doansible
  [ $OBSIDIAN = "true" ] && __doobsidian
  [ $TFDESTROY = "true" ] && __doterraform destroy
  [ $COPYOUTPUT = "true" ] && __docopyouput
  [ $CLEANUP = "true" ] && __cleanup
}

__show_help() {
    echo "Usage: $0 [-f CONFIGFILE] [-n NUMBER VMS] [-h]"
    echo "  -f CONFIGFILE Specify a config file (optional. will use ${BASEDIR}/${CONFIG_DIR}/config.sh if not specified))"
    echo "  -n NUMVMS     Specify a number of VMS to create (optional. will use 1 if not specified))"
    echo "  -h            Display this help message"
}

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

# stop logging
if [ $LOGGING = "true" ]
then
  exec 1>&3 3>&- 2>&4 4>&-
fi

trap __exit_handler EXIT SIGINT SIGTERM SIGQUIT SIGABRT SIGKILL 
