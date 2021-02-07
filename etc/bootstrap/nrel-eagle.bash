#!/bin/bash

exawind_eagle_common ()
{
    export EXAWIND_MODULES_DIR=/nopt/nrel/ecom/hpacf
    local moddate=${EXAWIND_MODULES_SNAPSHOT:-modules-2020-07}

    if [ ! -z "$MODULEPATH" ] ; then
        module unuse $MODULEPATH
    fi

    module use ${EXAWIND_MODULES_DIR}/binaries/${moddate}
    module use ${EXAWIND_MODULES_DIR}/compilers/${moddate}
    module use ${EXAWIND_MODULES_DIR}/utilities/${moddate}
    module use ${EXAWIND_MODULES_DIR}/software/${moddate}

    if [ ! -z "${EXAWIND_EXTRA_MODDIRS}" ] ; then
        module use ${EXAWIND_EXTRA_MODDIRS}
    fi

    echo "==> Using modules: $(readlink -f ${EXAWIND_MODULES_DIR}/software/${moddate})"
}

module purge || true
exawind_eagle_common
module load python binutils

mkdir -p /scratch/${USER}/.tmp
export TMPDIR=/scratch/${USER}/.tmp
echo "==> Setting TMPDIR=${TMPDIR}"
