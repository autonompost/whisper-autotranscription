#!/usr/bin/env bash


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

  if (( $NUMVMS > 1 ))
  then
    
    files=$(find "$src_dir" -type f -name "*.extension")
    
    counter=0
    
    for file in $files; do
      target_dir="$dest_dir/$((counter / num))"
    
      if [ ! -d "$target_dir" ]; then
        mkdir "$target_dir"
      fi
    
      cp "$file" "$target_dir"
      counter=$((counter + 1))
    done
  fi
}

# obsidian function
__doobsidian() {
 echo "do something"
}

__doterraform() {
 echo "do something"
}

__doansible() {
 echo "do something"
}

__main() {
  [ -z $FILE ] && FILE="config/config.sh"
  [ -z $NUMVMS ] && NUMVMS="1"
  __checkreq
  echo "do something"
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
