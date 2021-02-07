# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *
from spack.pkg.builtin.kokkos_nvcc_wrapper import KokkosNvccWrapper as KokkosNvccWrapperBase

class KokkosNvccWrapper(KokkosNvccWrapperBase):
    """The NVCC wrapper provides a wrapper around NVCC to make it a
       'full' C++ compiler that accepts all flags"""

    def setup_dependent_build_environment(self, env, dependent_spec):
        super(KokkosNvccWrapper, self).setup_dependent_build_environment(
            env, dependent_spec)
        wrapper = join_path(self.prefix.bin, "nvcc_wrapper")
        env.set('MPICXX_CXX', wrapper)
