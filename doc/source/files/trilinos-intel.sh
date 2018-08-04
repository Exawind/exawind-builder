#!/bin/bash

#
# ExaWind build script for project: trilinos
#
# compiler = intel
# system   = cori
#

#
# Setup variables used by functions
#
export EXAWIND_SRCDIR=${HOME}/exawind/exawind-builder
export EXAWIND_COMPILER=intel
export EXAWIND_SYSTEM=cori

#
# Source the core, system, and project specific build scripts
#
source ${EXAWIND_SRCDIR}/core.bash
source ${EXAWIND_SRCDIR}/envs/cori.bash
source ${EXAWIND_SRCDIR}/codes/trilinos.bash

### Override specific functions here and/or provide extra configuration
export EXAWIND_PROJECT_DIR=${EXAWIND_PROJECT_DIR:-${HOME}/exawind}
export EXAWIND_INSTALL_DIR=${EXAWIND_PROJECT_DIR}/install

# Source any user specific configuration
if [ -f ${HOME}/.exawind-config ] ; then
    source ${HOME}/.exawind-config
fi

# Source exawind project specific configuration
if [ -f ${EXAWIND_PROJECT_DIR}/exawind-config.sh ] ; then
    source ${EXAWIND_PROJECT_DIR}/exawind-config.sh
fi

# Path to the source directory, default assumes that the user is executing cmake
# from SOURCE/build directory. See the commented option below for
# out of source builds
TRILINOS_SOURCE_DIR=..
### Use this for out of source builds
###TRILINOS_SOURCE_DIR=${EXAWIND_PROJECT_DIR}/source/trilinos
# Directory where "make install" will install the project
# executables, libraries, and headers
TRILINOS_INSTALL_PREFIX=${EXAWIND_INSTALL_DIR}/trilinos

########## BEGIN user specific configuration ###########

########## END user specific configuration   ###########

### Execute main function (must be last line of this script)
if [[ "${BASH_SOURCE[0]}" != "${0}" ]] ; then
    exawind_env && exawind_proj_env
else
    exawind_main "$@"
fi
