#!/usr/bin/env bash

# Create a new python environment based on inputs

EXAWIND_SRCDIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

exw_show_help ()
{
    cat <<EOF
$(basename ${BASH_SOURCE[0]}) [options] [output_file_name]

Initialize the ExaWind python environment and create a script to source it.
By default, it will create a file called exawind-env-python-$COMPILER.sh

Options:
  -h             - Show help message and exit
  -s <system>    - Select system profile (spack, ornl-summit, etc.)
  -c <compiler>  - Select compiler type (gcc, clang, intel)
  -n <name>      - Name of the custom python environment (default: exawind)
  -f <file>      - Python requirements.txt file
  -r <env_root>  - Absolute path to the root directory for Pyvenv

EOF
}

check_inputs ()
{
    local dirname=${EXAWIND_SRCDIR}/$1
    local value=$2
    local option=$3

    local tgt_file=${dirname}/${value}.bash
    if [ ! -f ${tgt_file} ] ; then
        echo "Invalid value provided for ${option} = ${value}. Valid options are: "
        for fname in $(ls ${dirname}); do
            echo "    - $(basename -s .bash $fname)"
        done
        err_stat=1
    fi
}

main ()
{
    # Define defaults
    export EXAWIND_SYSTEM=${EXAWIND_SYSTEM:-spack}
    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-gcc}
    export EXAWIND_CFGFILE=exawind-config
    export EXAWIND_PROJECT_DIR=${EXAWIND_PROJECT_DIR:-$(dirname ${EXAWIND_SRCDIR})}
    local env_name=""
    local env_file=""
    local pyvenv_root=""

    # Parse user options
    OPTIND=1
    while getopts ":s:c:n:f:r:h" opt ; do
        case "$opt" in
            h)
                exw_show_help
                exit 0
                ;;
            s)
                export EXAWIND_SYSTEM=$OPTARG
                ;;
            c)
                export EXAWIND_COMPILER=$OPTARG
                ;;
            n)
                env_name=$OPTARG
                ;;
            f)
                env_file=$OPTARG
                ;;
            r)
                pyvenv_root=$OPTARG
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
    check_inputs envs ${EXAWIND_SYSTEM} "system"
    if [[ err_stat -ne 0 ]] ; then
        echo "Invalid system encountered, exiting now"
        exit 1
    fi

    # Source files
    source ${EXAWIND_SRCDIR}/src/environment.bash
    source ${EXAWIND_SRCDIR}/src/python-env.bash
    source ${EXAWIND_SRCDIR}/envs/${EXAWIND_SYSTEM}.bash

    exawind_load_user_configs

    # Override configuration variables with command line variables
    if [ ! -z ${env_name} ] ; then
        export EXAWIND_PYVENV=${env_name}
    fi
    if [ ! -z ${env_file} ] ; then
        export EXAWIND_PYENV_SPEC=${env_file}
    fi
    if [ ! -z ${pyvenv_root} ] ; then
        export EXAWIND_PYVENV_ROOT=${pyvenv_root}
    fi

    exawind_env
    exawind_pyvenv_create

    output_file=${1:-exawind-pyenv-${EXAWIND_PYVENV}.sh}
    tmpl_file=${EXAWIND_SRCDIR}/etc/python/venv/pyvenv_tmpl.bash

    sed -e "s#%%SRCDIR%%#${EXAWIND_SRCDIR}#g;s#%%COMPILER%%#${EXAWIND_COMPILER}#g;s#%%SYSTEM%%#${EXAWIND_SYSTEM}#g;s#%%PYVENV_ROOT%%#${EXAWIND_PYVENV_ROOT}#;s#%%PYVENV%%#${EXAWIND_PYVENV}#" $tmpl_file > $output_file
    chmod a+x $output_file

    echo "==> Python environment script ${output_file} created succesfully"
}

main "$@"
