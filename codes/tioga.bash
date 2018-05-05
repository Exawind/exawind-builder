#!/bin/bash

exawind_proj_env ()
{
    echo "no additional dependencies"
}

exawind_cmake ()
{
    local extra_args="$@"
    local install_dir=""
    if [ -n "$TIOGA_INSTALL_PREFIX" ] ; then
        install_dir="-DCMAKE_INSTALL_PREFIX=\"$TIOGA_INSTALL_PREFIX\""
    fi

    command cmake ${install_dir} ${extra_args} ../
}
