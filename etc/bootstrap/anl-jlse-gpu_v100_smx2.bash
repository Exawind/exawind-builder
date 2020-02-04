#!/bin/bash

# Setup proxy to enable wget/curl downloads via http/https
export http_proxy=http://proxy:3128
export https_proxy=https://proxy:3128
export ENABLE_CUDA=${ENABLE_CUDA:-ON}
