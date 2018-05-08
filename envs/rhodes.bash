#!/bin/bash

exawind_module_env ()
{
    export MODULE_PREFIX=/opt/software/module_prefix
    export PATH=${MODULE_PREFIX}/Modules/bin:${PATH}
    module use /opt/software/modules
}

module ()
{
    eval $(${MODULE_PREFIX}/Modules/bin/modulecmd $(basename ${SHELL}) $*);
}

exawind_env_gcc ()
{
    exawind_module_env
    module purge
    module load gcc/7.3.0 cmake/3.9.4
}

exawind_env_intel ()
{
    echo "ERROR: Intel environment not supported on this system"
    exit 1
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        if [ -z ${!root_dir_var} ] ; then
            module load $dep
        fi
    done
}
