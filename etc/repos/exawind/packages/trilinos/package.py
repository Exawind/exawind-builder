# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

import os
from spack import *
from spack.pkg.builtin.kokkos import Kokkos
from spack.pkg.builtin.trilinos import Trilinos as TrilinosBase

class Trilinos(TrilinosBase):
    """ExaWind Trilinos configuration"""

    depends_on('ninja-fortran')

    @property
    def generator(self):
        """Override generator to use Ninja

        However, handle the situation where VerifyFortran fails on Intel
        compilers when using ninja.
        """
        gen_default = 'Unix Makefiles'
        gen = ('Ninja'
               if os.environ.get('EXAWIND_MAKE_TYPE','').lower() == 'ninja'
               else gen_default)
        return gen_default if '%intel' in self.spec else gen

    @property
    def std_cmake_args(self):
        args = super(Trilinos, self).std_cmake_args

        if '%intel' in self.spec:
            return [aa for aa in args
                    if not 'CMAKE_INSTALL_RPATH:STRING' in aa]
        else:
            return args

    def setup_build_environment(self, env):
        # Workaround for segfaults with IPO
        if '%intel' in self.spec:
            for cc in "CXX C F LD".split():
                env.append_flags(cc + "FLAGS", '-no-ipo')

    def cmake_args(self):
        args = super(Trilinos, self).cmake_args()

        if '%intel' in self.spec:
            args.append(self.define(
                'CMAKE_INSTALL_RPATH_USE_LINK_PATH', True))

        return args
