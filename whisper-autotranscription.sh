#!/usr/bin/env bash
# execute this script to automatically transcribe audio files on a cloud provider of choice

# functions

# check requirements
__checkreq() {
  [ -f $FILE ] || { echo "Error: config file ${FILE} cannot be found or is not readable"; exit 1; }
  source $FILE
  [ -x "$(command -v ansible)" ] || { echo "Error: ansible is not installed or not executable"; exit 1; }
  [ -x "$(command -v terraform)" ] || { echo "Error: terraform is not installed or not executable"; exit 1; }
}

# distribute files for ansible upload
__distributefiles() {
  declare -a extensions=( mp3 wav ogg )
  [ ! -d $dst_filedir ] && mkdir -p $dst_filedir
  if (( $NUMVMS > 1 ))
  then
  echo foo
    counter=1
    OIFS="$IFS"
    IFS=$'\n'

    files=$(find "$src_filedir" -type f -name "*.extension")

    for ext in "${extensions[@]}"
    do
      files=$(find "$src_filedir" -type f -name "*.$ext" -print)

      for file in $files
      do
        target_dir="$dst_filedir/$((counter / num))"

        if [ ! -d "$target_filedir" ]
        then
          mkdir "$target_filedir"
        fi

        if [ ! -f "$target_filedir$(basename "$file")" ]
        then
          echo "copying file: ${file}"
          cp "$file" "$target_filedir$(basename "$file")" || { echo "Error: could not copy file to ${target_filedir}"; exit 1; }
        else
          echo "file exists already: ${file}"
        fi
        counter=$((counter + 1))
      done
    done
    IFS="$OIFS"
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
    [ -d $dir ] && rm -r $dir
  done
}

__doobsidian() {
 echo "do something"
}

__dotfapply() {
 echo "do something"
}
__dotfdestroy() {
 echo "do something"
}

__doansible() {
 echo "do something"
}

__main() {
  [ -z $FILE ] && FILE="config/config.sh"
  [ -z $NUMVMS ] && NUMVMS=1
  __checkreq
  __distributefiles
  __dotfapply
  __doansible
  __doobsidian
  [ $CLEANUP = "true" ] && __cleanup
  __dotfdestroy
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
