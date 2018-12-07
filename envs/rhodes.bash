#!/bin/bash

EXAWIND_DEP_LOADER=module

exawind_module_env ()
{
    local compiler_arg=$1

    export MODULE_PREFIX=/opt/utilities/module_prefix
    export PATH=${MODULE_PREFIX}/Modules/bin:${PATH}
    local moddate=${EXAWIND_MODULES_SNAPSHOT:-modules}
    module use /opt/compilers/${moddate}
    module use /opt/utilities/${moddate}
    module use /opt/software/${moddate}/${compiler_arg}

    echo "==> Using modules: $(readlink -f /opt/software/${moddate}/${compiler_arg})"
}

module ()
{
    eval $(${MODULE_PREFIX}/Modules/bin/modulecmd $(basename ${SHELL}) $*);
}

exawind_env_gcc ()
{
    exawind_module_env gcc-7.3.0
    module purge
    module load gcc/7.3.0
    module load binutils cmake openmpi

    export CC=$(which mpicc)
    export CXX=$(which mpicxx)
    export FC=$(which mpifort)
}

exawind_env_intel ()
{
    exawind_module_env intel-18.0.4
    module purge
    module load intel-parallel-studio
    module load binutils cmake intel-mpi intel-mkl

    export CC=$(which mpiicc)
    export CXX=$(which mpiicpc)
    export FC=$(which mpiifort)
}
