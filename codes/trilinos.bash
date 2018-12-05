#!/bin/bash

_EXAWIND_PROJECT_CMAKE_RMEXTRA_=(
    packages
    commonTools
    Testing
)

exawind_proj_env ()
{
    echo "==> Loading dependencies for Trilinos..."
    exawind_load_deps zlib libxml2 hdf5 netcdf parallel-netcdf superlu boost
}

exawind_cmake_base ()
{
    local extra_args="$@"
    if [ -n "$TRILINOS_INSTALL_PREFIX" ] ; then
        install_dir="$TRILINOS_INSTALL_PREFIX"
    else
        install_dir="$(cd .. && pwd)/install"
    fi

    # Configure BLAS/LAPACK if user has setup the BLASLIB variable
    local blas_lapack=""
    if [ -n "$BLASLIB" ] ; then
        blas_lapack="-DTPL_BLAS_LIBRARIES=$BLASLIB -DTPL_LAPACK_LIBRARIES=$BLASLIB"
    fi

    # Allow user to configure OpenMP
    local enable_openmp=${ENABLE_OPENMP:-ON}
    if [[ $OSTYPE = "darwin" ]] ; then
        enable_openmp=OFF
    fi
    if [ "${enable_openmp}" = "OFF" ] ; then
        echo "==> Trilinos: disabling OpenMP"
    fi

    local enable_cuda=${ENABLE_CUDA:-OFF}
    local kokkos_args=""
    local enable_simd=${ENABLE_SIMD:-ON}
    if [ "${enable_cuda}" = "ON" ] ; then
        echo "==> Trilinos: enabling CUDA"
        kokkos_args="-DKOKKOS_ARCH=${KOKKOS_ARCH:-None}"
    fi

    local enable_superlu=ON
    local enable_klu2=OFF
    if [ "${ENABLE_KLU2:-OFF}" = "ON" ] ; then
        enable_superlu=OFF
        enable_klu2=ON
        echo "==> Trilinos: enabling KLU2 and disabling SuperLU"
    fi

    # Force CMake to use absolute paths for the libraries so that it doesn't
    # pick up versions installed in `/usr/lib64` on peregrine
    local lib_path_save=${LIBRARY_PATH}
    unset LIBRARY_PATH

    local cmake_cmd=(
        cmake
            -DCMAKE_INSTALL_PREFIX=${install_dir}
            -DCMAKE_BUILD_TYPE:STRING=${BUILD_TYPE:-RELEASE}
            -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS:-OFF}
            -DTrilinos_ENABLE_OpenMP:BOOL=${enable_openmp}
            -DKokkos_ENABLE_OpenMP:BOOL=${enable_openmp}
            -DTpetra_INST_OPENMP:BOOL=${enable_openmp}
            -DTrilinos_ENABLE_CUDA:BOOL=${enable_cuda}
            -DTPL_ENABLE_CUDA:BOOL=${enable_cuda}
            -DKokkos_ENABLE_CUDA:BOOL=${enable_cuda}
            -DKokkos_ENABLE_Cuda_UVM:BOOL=${enable_cuda}
            -DTpetra_ENABLE_CUDA:BOOL=${enable_cuda}
            -DTpetra_INST_CUDA:BOOL=${enable_cuda}
            -DKokkos_ENABLE_Cuda_Lambda:BOOL=${enable_cuda}
            -DKOKKOS_ENABLE_CUDA_RELOCATABLE_DEVICE_CODE:BOOL=${enable_cuda}
            -DTpetra_INST_SERIAL:BOOL=ON
            -DTrilinos_ENABLE_CXX11:BOOL=ON
            -DTrilinos_ENABLE_EXPLICIT_INSTANTIATION:BOOL=ON
            -DTpetra_INST_DOUBLE:BOOL=ON
            -DTpetra_INST_INT_LONG:BOOL=ON
            -DTpetra_INST_COMPLEX_DOUBLE:BOOL=OFF
            -DTrilinos_ENABLE_TESTS:BOOL=OFF
            -DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES:BOOL=OFF
            -DTrilinos_ASSERT_MISSING_PACKAGES:BOOL=OFF
            -DTrilinos_ALLOW_NO_PACKAGES:BOOL=OFF
            -DTrilinos_ENABLE_Epetra:BOOL=OFF
            -DTrilinos_ENABLE_Tpetra:BOOL=ON
            -DTrilinos_ENABLE_KokkosKernels:BOOL=ON
            -DTrilinos_ENABLE_ML:BOOL=OFF
            -DTrilinos_ENABLE_MueLu:BOOL=ON
            -DXpetra_ENABLE_Kokkos_Refactor:BOOL=ON
            -DMueLu_ENABLE_Kokkos_Refactor:BOOL=ON
            -DTrilinos_ENABLE_EpetraExt:BOOL=OFF
            -DTrilinos_ENABLE_AztecOO:BOOL=OFF
            -DTrilinos_ENABLE_Belos:BOOL=ON
            -DTrilinos_ENABLE_Ifpack2:BOOL=ON
            -DTrilinos_ENABLE_Amesos2:BOOL=ON
            -DAmesos2_ENABLE_KLU2:BOOL=${enable_klu2}
            -DTrilinos_ENABLE_Zoltan2:BOOL=ON
            -DTrilinos_ENABLE_Ifpack:BOOL=OFF
            -DTrilinos_ENABLE_Amesos:BOOL=OFF
            -DTrilinos_ENABLE_Zoltan:BOOL=ON
            -DTrilinos_ENABLE_STKMesh:BOOL=ON
            -DTrilinos_ENABLE_STKSimd:BOOL=${enable_simd}
            -DTrilinos_ENABLE_STKNGP:BOOL=ON
            -DTrilinos_ENABLE_STKIO:BOOL=ON
            -DTrilinos_ENABLE_STKTransfer:BOOL=ON
            -DTrilinos_ENABLE_STKSearch:BOOL=ON
            -DTrilinos_ENABLE_STKUtil:BOOL=ON
            -DTrilinos_ENABLE_STKTopology:BOOL=ON
            -DTrilinos_ENABLE_STKUnit_tests:BOOL=ON
            -DTrilinos_ENABLE_STKUnit_test_utils:BOOL=ON
            -DSTK_ENABLE_UnitMain:BOOL=OFF
            -DTrilinos_ENABLE_Gtest:BOOL=ON
            -DTrilinos_ENABLE_STKClassic:BOOL=OFF
            -DTrilinos_ENABLE_STKExprEval:BOOL=ON
            -DTrilinos_ENABLE_SEACASExodus:BOOL=ON
            -DTrilinos_ENABLE_SEACASEpu:BOOL=ON
            -DTrilinos_ENABLE_SEACASExodiff:BOOL=ON
            -DTrilinos_ENABLE_SEACASNemspread:BOOL=ON
            -DTrilinos_ENABLE_SEACASNemslice:BOOL=ON
            -DTrilinos_ENABLE_SEACASIoss:BOOL=ON
            -DTPL_ENABLE_MPI:BOOL=ON
            -DTPL_ENABLE_Boost:BOOL=ON
            -DBoostLib_INCLUDE_DIRS:PATH=${BOOST_ROOT_DIR}/include
            -DBoostLib_LIBRARY_DIRS:PATH=${BOOST_ROOT_DIR}/lib
            -DBoost_INCLUDE_DIRS:PATH=${BOOST_ROOT_DIR}/include
            -DBoost_LIBRARY_DIRS:PATH=${BOOST_ROOT_DIR}/lib
            -DTPL_ENABLE_SuperLU:BOOL=${enable_superlu}
            -DSuperLU_INCLUDE_DIRS:PATH=${SUPERLU_ROOT_DIR}/include
            -DSuperLU_LIBRARY_DIRS:PATH=${SUPERLU_ROOT_DIR}/lib
            -DTPL_ENABLE_Netcdf:BOOL=ON
            -DNetCDF_ROOT:PATH=${NETCDF_ROOT_DIR}
            -DTPL_Netcdf_PARALLEL:BOOL=ON
            -DTPL_Netcdf_Enables_Netcdf4:BOOL=ON
            -DTPL_ENABLE_Pnetcdf:BOOL=ON
            -DPNetCDF_ROOT:PATH=${PARALLEL_NETCDF_ROOT_DIR}
            -DTPL_ENABLE_HDF5:BOOL=ON
            -DHDF5_ROOT:PATH=${HDF5_ROOT_DIR}
            -DHDF5_NO_SYSTEM_PATHS:BOOL=ON
            -DTPL_ENABLE_Zlib:BOOL=ON
            -DZlib_INCLUDE_DIRS:PATH=${ZLIB_ROOT_DIR}/include
            -DZlib_LIBRARY_DIRS:PATH=${ZLIB_ROOT_DIR}/lib
            -DTPL_ENABLE_BLAS:BOOL=ON
            ${blas_lapack}
            ${kokkos_args}
            ${extra_args}
            ${TRILINOS_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log

    export LIBRARY_PATH=${lib_path_save}
}

exawind_cmake_osx ()
{
    local extra_args="$@"

    exawind_cmake_base \
        -DTrilinos_ENABLE_OpenMP=OFF \
        -DKokkos_ENABLE_OpenMP:BOOL=OFF \
        -DTpetra_INST_OPENMP=OFF \
        ${extra_args}
}

exawind_cmake_cori ()
{
    local extra_args="$@"
    exawind_cmake_base \
        -DMPI_USE_COMPILER_WRAPPERS:BOOL=ON \
        -DMPI_CXX_COMPILER:FILEPATH=${CXX} \
        -DMPI_C_COMPILER:FILEPATH=${CC} \
        -DMPI_Fortran_COMPILER:FILEPATH=${FC} \
        -DMPI_EXEC=srun \
        -DMPI_EXEC_NUMPROCS_FLAG=-n \
        -DCMAKE_SKIP_INSTALL_RPATH=TRUE \
        ${extra_args}
}
