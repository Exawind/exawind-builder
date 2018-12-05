#!/bin/bash

# Create a new build script
#
# Creates a boilerplate executable script that has been configured for a
# particular project and system. The default arguments are: project=nalu-wind,
# compiler=gcc, and system=spack.
#

show_help ()
{
    cat <<EOF
$(basename ${BASH_SOURCE[0]}) [options] [output_file]

Options:
  -h             - Show help message and exit
  -p <project>   - Select project (nalu, openfast, etc)
  -s <system>    - Select system profile (spack, peregrine, cori, etc.)
  -c <compiler>  - Select compiler type (gcc, intel)

Argument:
  output_file    - Name of the build script (default: '\$project-\$compiler.sh')

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

# Get the source directory
EXAWIND_SRCDIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Set default options
system=spack
compiler=gcc
project=nalu-wind

# Parse user options
OPTIND=1
while getopts ":s:c:p:h" opt; do
    case "$opt" in
        h)
            show_help
            exit 0
            ;;
        s)
            system=$OPTARG
            ;;
        c)
            compiler=$OPTARG
            ;;
        p)
            project=$OPTARG
            ;;
        \?)
            echo "ERROR: Invalid argument provided"
            show_help
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))
[ "$1" == "--" ] && shift

err_stat=0
check_inputs envs ${system} "system"
check_inputs codes ${project} "project"
if [[ err_stat -ne 0 ]] ; then
    echo "Invalid options encountered, exiting now"
    exit 1
fi

# Set the install directory
project_name="$(echo ${project} | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/g' | tr '[:lower:]' '[:upper:]')"
install_dir_var="${project_name}_INSTALL_PREFIX"
source_dir_var="${project_name}_SOURCE_DIR"
ecp_prj_dir=${EXAWIND_PROJECT_DIR:-$(dirname ${EXAWIND_SRCDIR})}

# Setup bash shebang for OSX
bash_shebang="/bin/bash"
if [ "$(uname)" = "Darwin" ] ; then
    bash_shebang='/usr/local/bin/bash'
fi

# Output and template file
output_file=$1
tmpl_file=${EXAWIND_SRCDIR}/etc/script_tmpl.bash

if [ -z "$output_file" ]; then
    output_file=${project}-${compiler}.sh
fi

sed -e "s#%%SRCDIR%%#${EXAWIND_SRCDIR}#g;s#%%COMPILER%%#${compiler}#g;s#%%SYSTEM%%#${system}#g;s#%%PROJECT%%#${project}#g;s#%%INSTALL_DIR%%#${install_dir_var}#g;s#%%CODE_DIR%%#${source_dir_var}#g;s#%%EXAWIND_PRJDIR%%#${ecp_prj_dir}#g;s#%%BASH_SHEBANG%%#${bash_shebang}#" $tmpl_file > $output_file
chmod a+x ${output_file}

cat <<EOF
==> Build script ${output_file} created successfully.
EOF
