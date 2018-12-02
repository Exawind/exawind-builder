#!/bin/bash

exawind_module_env ()
{
    export MODULE_PREFIX=/opt/utilities/module_prefix
    export PATH=${MODULE_PREFIX}/Modules/bin:${PATH}
    local moddate=${EXAWIND_MODULES_SNAPSHOT:-modules}
    module use /opt/compilers/${moddate}
    module use /opt/utilities/${moddate}
    export EXAWIND_MODULES_DIR=/opt/software/${moddate}
}

module ()
{
    eval $(${MODULE_PREFIX}/Modules/bin/modulecmd $(basename ${SHELL}) $*);
}

exawind_env_gcc ()
{
    exawind_module_env
    module use ${EXAWIND_MODULES_DIR}/gcc-7.3.0
    module purge
    module load gcc/7.3.0
    module load binutils
    module load cmake

    export CC=mpicc
    export CXX=mpicxx
    export FC=mpifort
}

exawind_env_intel ()
{
    exawind_module_env
    module use ${EXAWIND_MODULES_DIR}/intel-18.0.4
    module purge
    module load intel-parallel-studio/cluster.2019.1 cmake
    module load intel-mpi
    module load intel-mkl

    export CC=mpiicc
    export CXX=mpiicpc
    export FC=mpiifort
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/g' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        if [ -z ${!root_dir_var} ] ; then
            module load $dep
        fi
        echo "==> ${depname} = ${!root_dir_var}"
    done
}
