#!/bin/bash

export EXAWIND_NUM_JOBS_DEFAULT=32

exawind_env_common ()
{
    module purge
    module load sierra-devel/nvidia
    # Spack has issues with the default 2.7 python from sierra-devel
    module unload sierra-python/2.7
    module load sierra-python/3.6.3

    export SPACK_ROOT=${SPACK_ROOT:-${EXAWIND_PROJECT_DIR}/spack}
    export SPACK_EXE=${SPACK_ROOT}/bin/spack
    module use ${SPACK_ROOT}/share/spack/modules/$(${SPACK_EXE} arch)

    export EXAWIND_CUDA_WRAPPER=${EXAWIND_CUDA_WRAPPER:-${EXAWIND_PROJECT_DIR}/source/trilinos/packages/kokkos/bin/nvcc_wrapper}
    export CUDA_LAUNCH_BLOCKING=${CUDA_LAUNCH_BLOCKING:-1}
    export ENABLE_CUDA=${ENABLE_CUDA:-ON}
    export KOKKOS_ARCH=${KOKKOS_ARCH:-Pascal60}
    export HYPRE_CUDA_SM=${HYPRE_CUDA_SM:-60}
}

exawind_env_gcc ()
{
    exawind_env_common

    export SPACK_COMPILER=gcc
    export CC=$(which gcc)
    export CXX=$(which g++)
    export F77=$(which mpif90)
    export FC=$(which mpif90)

    export NVCC_WRAPPER_DEFAULT_COMPILER=$CXX
    export OMPI_CXX=${EXAWIND_CUDA_WRAPPER}
    export CXX=$(which mpic++)

    exawind_load_deps netlib-lapack zlib libxml2
}

exawind_env_intel ()
{
    echo "ERROR: No Intel environment setup for snl-ascicgpu"
}

exawind_load_deps ()
{
    for dep in $@ ; do
        root_dir_var="$(echo $dep | sed -e 's/\([-a-zA-Z0-9_]*\).*/\1/;s/-/_/g' | tr '[:lower:]' '[:upper:]')_ROOT_DIR"

        local depname=${EXAWIND_MODMAP[$dep]:-$dep}
        if [ -z ${!root_dir_var} ] ; then
            module load $(${SPACK_EXE} module tcl find $depname %${SPACK_COMPILER})
            eval "export $root_dir_var=$(${SPACK_EXE} location -i $depname %${SPACK_COMPILER})"
        fi
        echo "==> ${depname} = ${!root_dir_var}"
    done
}
