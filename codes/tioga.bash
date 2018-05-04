#!/bin/bash

exawind_proj_env ()
{
    echo "no additional dependencies"
}

exawind_cmake ()
{
    local extra_args="$@"

    command cmake ${extra_args} ../
}
