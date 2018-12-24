#!/bin/bash

module purge

case "${EXAWIND_COMPILER:-gcc}" in
    gcc)
        module load sierra-devel
        ;;

    intel)
        module load sierra-devel/intel
        ;;
esac

module unload sierra-python/2.7
module load sierra-python/3.6.3
