#!/usr/bin/env bash
#
# Exawind environment source script for system: {{ system }}
#
# 1. See https://exawind.github.io/exawind-builder for documentation
# 2. Use new-script.sh to regenerate this script
#

#
# Setup variables used by functions
#
export EXAWIND_SRCDIR={{ exawind_builder_dir }}
export EXAWIND_COMPILER={{ compiler }}
export EXAWIND_SYSTEM={{ system }}
export EXAWIND_CFGFILE=exawind-config

#
# Source the core, system, and project specific build scripts
#
source ${EXAWIND_SRCDIR}/core.bash
source ${EXAWIND_SRCDIR}/envs/${EXAWIND_SYSTEM}.bash
source ${EXAWIND_SRCDIR}/codes/${EXAWIND_CODE}.bash

# Path to ExaWind project and install directories
export EXAWIND_PROJECT_DIR=${EXAWIND_PROJECT_DIR:-{{ exawind_dir }}}
export EXAWIND_INSTALL_DIR=${EXAWIND_INSTALL_DIR:-${EXAWIND_PROJECT_DIR}/install/${EXAWIND_COMPILER}}
export EXAWIND_CONFIG=${EXAWIND_CONFIG:-${EXAWIND_PROJECT_DIR}/${EXAWIND_CFGFILE}.sh}

# Source any user specific configuration (see documentation)
exawind_load_user_configs

# Finally load the environment
exawind_env
