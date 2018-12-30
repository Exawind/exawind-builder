#!/bin/bash

# Setup proxy to enable wget/curl downloads via http/https
export http_proxy=http://wwwproxy.sandia.gov:80
export https_proxy=https://wwwproxy.sandia.gov:80

# Setup the environment for spack builds
module load sierra-devel/intel
module unload gnu/4.9.2
module load gcc/4.9.3
