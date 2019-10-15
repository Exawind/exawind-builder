#!/bin/bash

# Setup proxy to enable wget/curl downloads via http/https
export http_proxy=http://wwwproxy.sandia.gov:80
export https_proxy=https://wwwproxy.sandia.gov:80

# Load necessary modules for bootstrapping
module purge
module load gcc/7.2.0
module load openmpi/3.1.1/gcc/7.2.0/cuda/9.2.88
module load cmake/3.12.3
module load python/2.7.12
module load git/2.10.1
module load curl/7.46.0
