#!/bin/bash

exawind_proj_env ()
{
    exawind_load_deps zlib libxml2 hdf5 netcdf parallel-netcdf superlu boost
}

exawind_cmake ()
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

    # Force CMake to use absolute paths for the libraries so that it doesn't
    # pick up versions installed in `/usr/lib64` on peregrine
    local lib_path_save=${LIBRARY_PATH}
    unset LIBRARY_PATH

    local cmake_cmd=(
        cmake
            -DCMAKE_INSTALL_PREFIX=${install_dir}
            -DCMAKE_BUILD_TYPE:STRING=${BUILD_TYPE:-RELEASE}
            -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS:-OFF}
            -DTrilinos_ENABLE_OpenMP:BOOL=ON
            -DKokkos_ENABLE_OpenMP:BOOL=ON
            -DTpetra_INST_OPENMP:BOOL=ON
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
            -DTrilinos_ENABLE_ML:BOOL=OFF
            -DTrilinos_ENABLE_MueLu:BOOL=ON
            -DTrilinos_ENABLE_EpetraExt:BOOL=OFF
            -DTrilinos_ENABLE_AztecOO:BOOL=OFF
            -DTrilinos_ENABLE_Belos:BOOL=ON
            -DTrilinos_ENABLE_Ifpack2:BOOL=ON
            -DTrilinos_ENABLE_Amesos2:BOOL=ON
            -DTrilinos_ENABLE_Zoltan2:BOOL=ON
            -DTrilinos_ENABLE_Ifpack:BOOL=OFF
            -DTrilinos_ENABLE_Amesos:BOOL=OFF
            -DTrilinos_ENABLE_Zoltan:BOOL=ON
            -DTrilinos_ENABLE_STKMesh:BOOL=ON
            -DTrilinos_ENABLE_STKSimd:BOOL=ON
            -DTrilinos_ENABLE_STKIO:BOOL=ON
            -DTrilinos_ENABLE_STKTransfer:BOOL=ON
            -DTrilinos_ENABLE_STKSearch:BOOL=ON
            -DTrilinos_ENABLE_STKUtil:BOOL=ON
            -DTrilinos_ENABLE_STKTopology:BOOL=ON
            -DTrilinos_ENABLE_STKUnit_tests:BOOL=ON
            -DTrilinos_ENABLE_STKUnit_test_utils:BOOL=ON
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
            -DTPL_ENABLE_SuperLU:BOOL=ON
            -DSuperLU_INCLUDE_DIRS:PATH=${SUPERLU_ROOT_DIR}/include
            -DSuperLU_LIBRARY_DIRS:PATH=${SUPERLU_ROOT_DIR}/lib
            -DTPL_ENABLE_Netcdf:BOOL=ON
            -DNetCDF_ROOT:PATH=${NETCDF_ROOT_DIR}
            -DNetcdf_LIBRARY_DIRS=${NETCDF_ROOT_DIR}/lib
            -DNetcdf_INCLUDE_DIRS=${NETCDF_ROOT_DIR}/include
            -DTPL_Netcdf_PARALLEL:BOOL=ON
            -DTPL_Netcdf_Enables_Netcdf4:BOOL=ON
            -DTPL_ENABLE_Pnetcdf:BOOL=ON
            -DPNetCDF_ROOT:PATH=${PARALLEL_NETCDF_ROOT_DIR}
            -DPnetcdf_LIBRARY_DIRS=${PARALLEL_NETCDF_DIR}/lib
            -DPnetcdf_INCLUDE_DIRS=${PARALLEL_NETCDF_DIR}/include
            -DTPL_ENABLE_HDF5:BOOL=ON
            -DHDF5_ROOT:PATH=${HDF5_ROOT_DIR}
            -DHDF5_INCLUDE_DIRS:PATH=${HDF5_ROOT_DIR}/include
            -DHDF5_LIBRARY_DIRS:PATH=${HDF5_ROOT_DIR}/lib
            -DHDF5_NO_SYSTEM_PATHS:BOOL=ON
            -DTPL_ENABLE_Zlib:BOOL=ON
            -DZlib_INCLUDE_DIRS:PATH=${ZLIB_ROOT_DIR}/include
            -DZlib_LIBRARY_DIRS:PATH=${ZLIB_ROOT_DIR}/lib
            -DTPL_ENABLE_BLAS:BOOL=ON
            ${blas_lapack}
            ${extra_args}
            ${TRILINOS_SOURCE_DIR:-..}
    )

    echo "${cmake_cmd[@]}" > cmake_output.log
    eval "${cmake_cmd[@]}" 2>&1 | tee -a cmake_output.log

    export LIBRARY_PATH=${lib_path_save}
}
