#!/bin/bash

#
# ExaWind build script for project: %%PROJECT%%
#
# compiler = %%COMPILER%%
# system   = %%SYSTEM%%
#

#
# Setup variables used by functions
#
export EXAWIND_SRCDIR=%%SRCDIR%%
export EXAWIND_COMPILER=%%COMPILER%%
export EXAWIND_SYSTEM=%%SYSTEM%%

#
# Source the core, system, and project specific build scripts
#
source ${EXAWIND_SRCDIR}/core.bash
source ${EXAWIND_SRCDIR}/envs/%%SYSTEM%%.bash
source ${EXAWIND_SRCDIR}/codes/%%PROJECT%%.bash

### Override specific functions here and/or provide extra configuration
export EXAWIND_PROJECT_DIR=${EXAWIND_PROJECT_DIR:-${HOME}/exawind/}
export EXAWIND_INSTALL_DIR=${EXAWIND_PROJECT_DIR}/install/

# Path to the source directory, default assumes that the user is executing cmake
# from SOURCE/build directory. See the commented option below for
# out of source builds
%%CODE_DIR%%=..
# Use this for out of source builds
#%%CODE_DIR%%=${EXAWIND_PROJECT_DIR}/source/%%PROJECT%%

# Directory where "make install" will install the project
# executables, libraries, and headers
%%INSTALL_DIR%%=${EXAWIND_INSTALL_DIR}/%%PROJECT%%

### Execute main function (must be last line of this script)
if [[ "${BASH_SOURCE[0]}" != "${0}" ]] ; then
    exawind_env && exawind_proj_env
else
    exawind_main "$@"
fi
