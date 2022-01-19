#!/bin/bash

if [ -z "${OLCF_SPECTRUM_MPI_ROOT}" ] ; then
    module load DefApps
fi

if [ "${EXAWIND_COMPILER}" = "gcc" ] ; then
   module unload xl
   module load gcc/9.3.0
fi
