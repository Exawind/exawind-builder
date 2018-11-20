#!/bin/bash

# Create a script that can be source to initialize an environment

exw_show_help ()
{
    cat <<EOF
$(basename ${BASH_SOURCE[0]}) [options] [output_file_name]

By default it will create a file called exawind-env-\$COMPILER.sh

Options:
  -h             - Show help message and exit
  -s <system>    - Select system profile (spack, cori, summitdev, etc.)
  -c <compiler>  - Select compiler type (gcc, clang, intel, etc.)

EOF
}

check_inputs ()
{
    local dirname=${EXAWIND_SRCDIR}/$1
    local value=$2
    local option=$3

    local tgt_file=${dirname}/${value}.bash
    if [ ! -f ${tgt_file} ] ; then
        echo "Invalid value provided for ${option} = ${value}. Valid options are
: "
        for fname in $(ls ${dirname}); do
            echo "    - $(basename -s .bash $fname)"
        done
        err_stat=1
    fi
}

# Get the source directory
EXAWIND_SRCDIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Set default options
system=spack
compiler=gcc

# Parse user options
OPTIND=1
while getopts ":s:c:h" opt; do
    case "$opt" in
        h)
            exw_show_help
            exit 0
            ;;
        s)
            system=$OPTARG
            ;;
        c)
            compiler=$OPTARG
            ;;
        \?)
            echo "ERROR: Invalid argument provided"
            exw_show_help
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))
[ "$1" == "--" ] && shift

err_stat=0
check_inputs envs ${system} "system"
if [[ err_stat -ne 0 ]] ; then
    echo "Invalid options encountered, exiting now"
    exit 1
fi

# Output and template file
output_file=$1
tmpl_file=${EXAWIND_SRCDIR}/etc/env_tmpl.bash

if [ -z "$output_file" ]; then
    output_file=exawind-env-${compiler}.sh
fi

sed -e "s#%%SRCDIR%%#${EXAWIND_SRCDIR}#g;s#%%COMPILER%%#${compiler}#g;s#%%SYSTEM%%#${system}#g;" $tmpl_file > $output_file
chmod a+x ${output_file}

cat <<EOF
Environment script ${output_file} created successfully. Modify script to change defaults
EOF
