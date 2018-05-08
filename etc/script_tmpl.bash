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
EXAWIND_INSTALL_DIR=${HOME}/exawind/install/
%%INSTALL_DIR%%=${HOME}/exawind/install/%%PROJECT%%

### Execute main function (must be last line of this script)
if [[ "${BASH_SOURCE[0]}" != "${0}" ]] ; then
    exawind_env && exawind_proj_env
else
    exawind_main "$@"
fi
