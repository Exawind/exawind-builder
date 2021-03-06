#!/bin/bash

_EXAWIND_PROJECT_CMAKE_RMEXTRA_=(
    src
    unit_tests
    reg_tests
    Testing
    include
)

exawind_proj_env ()
{
    local opt_packages=(
        fftw
        hypre
        openfast
        tioga
        umpire
    )

    echo "==> Loading dependencies for nalu-wind... "
    exawind_load_deps python trilinos yaml-cpp boost

    for pkg in ${opt_packages[@]} ; do
        local pkg_flag="ENABLE_${pkg^^}"
        if [ "${!pkg_flag:-ON}" = "ON" ] ; then
            exawind_load_deps $pkg
        fi
    done

    if [ "${ENABLE_PARAVIEW_CATALYST:-OFF}" = "ON" ] ; then
       exawind_load_deps paraview trilinos-catalyst-ioss-adapter
    fi
}

exawind_cmake_base ()
{
    local extra_args="$@"
    local install_dir=""
    local ccache_args=""
    if [ -n "$NALU_WIND_INSTALL_PREFIX" ] ; then
        install_dir="-DCMAKE_INSTALL_PREFIX=$NALU_WIND_INSTALL_PREFIX"
    fi

    local compiler_flags=$(exawind_get_compiler_flags)

    if [ "${EXAWIND_UNSET_LIBRARY_PATH:-ON}" = "ON" ] ; then
        # Force CMake to use absolute paths for the libraries so that it doesn't
        # pick up versions installed in `/usr/lib64` on peregrine
        local lib_path_save=${LIBRARY_PATH}
        unset LIBRARY_PATH
    fi

    if [ "${ENABLE_CCACHE:-OFF}" = "ON" ] ; then
        ccache_args="-DCMAKE_CXX_COMPILER_LAUNCHER:STRING=$(which ccache)"
    fi

    local cmake_cmd=(
        cmake
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE:-RELEASE}
        -DENABLE_OPENMP=${ENABLE_OPENMP:-OFF}
        -DENABLE_CUDA=${ENABLE_CUDA:-OFF}
        -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS:-OFF}
        -DTrilinos_DIR:PATH=${TRILINOS_ROOT_DIR}
        -DBOOST_DIR=${BOOST_ROOT_DIR}
        -DYAML_DIR:PATH=${YAML_CPP_ROOT_DIR}
        -DENABLE_FFTW=${ENABLE_FFTW:-OFF}
        -DFFTW_DIR:PATH=${FFTW_ROOT_DIR}
        -DENABLE_HYPRE:BOOL=${ENABLE_HYPRE:-ON}
        -DHYPRE_DIR:PATH=${HYPRE_ROOT_DIR}
        -DENABLE_UMPIRE:BOOL=${ENABLE_UMPIRE:-OFF}
        -DUMPIRE_DIR:PATH=${UMPIRE_ROOT_DIR}
        -DENABLE_TIOGA:BOOL=${ENABLE_TIOGA:-ON}
        -DTIOGA_DIR:PATH=${TIOGA_ROOT_DIR}
        -DENABLE_OPENFAST:BOOL=${ENABLE_OPENFAST:-ON}
        -DOpenFAST_DIR:PATH=${OPENFAST_ROOT_DIR}
        -DENABLE_PARAVIEW_CATALYST=${ENABLE_PARAVIEW_CATALYST:-OFF}
        -DPARAVIEW_CATALYST_INSTALL_PATH:PATH=${TRILINOS_CATALYST_IOSS_ADAPTER_ROOT_DIR}
        -DENABLE_TESTS:BOOL=${ENABLE_TESTS:-ON}
        -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=ON
        ${ccache_args}
        ${compiler_flags}
        ${install_dir}
        ${extra_args}
        ${NALU_WIND_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log

    if [ "${EXAWIND_UNSET_LIBRARY_PATH:-ON}" = "ON" ] ; then
        export LIBRARY_PATH=${lib_path_save}
    fi
}

#exawind_cmake_osx ()
#{
#    local extra_args="$@"
#    exawind_cmake_base \
#        -DMPIEXEC_PREFLAGS:STRING='"--use-hwthread-cpus --oversubscribe"' \
#        ${extra_args}
#}

exawind_cmake_cori ()
{
    local extra_args="$@"
    exawind_cmake_base \
        -DMPIEXEC_EXECUTABLE=$(which srun) \
        -DMPIEXEC_NUMPROC_FLAG="-n" \
        ${extra_args}
}

exawind_cmake_eagle ()
{
    local extra_args="$@"

    exawind_cmake_base \
        -DMPIEXEC_EXECUTABLE=$(which srun) \
        -DMPIEXEC_NUMPROC_FLAG="-n" \
        -DMPIEXEC_PREFLAGS='"--cpu-bind=cores --exclusive"' \
        ${extra_args}
}

exawind_cmake_ornl-summit ()
{
    local extra_args="$@"
    local jsrun_args=$'--smpiargs=\x22-gpu\x22'

    exawind_cmake_base \
        -DMPIEXEC_EXECUTABLE='"$(which jsrun) ${jsrun_args}"' \
        -DMPIEXEC_NUMPROC_FLAG="-n" \
        -DMPIEXEC_PREFLAGS='"-a 1 -c 1 -g 1"' \
        ${extra_args}
}
