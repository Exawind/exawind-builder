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
    module load cmake/3.9.4

    export CC=gcc
    export CXX=g++
    export FC=gfortran
}

exawind_env_intel ()
{
    exawind_module_env
    module purge
    module load intel-parallel-studio/cluster.2018.1 cmake/3.9.4

    export CC=icc
    export CXX=icpc
    export FC=ifort
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
