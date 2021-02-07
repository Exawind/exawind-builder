# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

import sys
import os
from spack import *

class NaluWindUtils(CMakePackage):
    """ExaWind Nalu-Wind utilities"""

    homepage = "https://naluwindutils.readthedocs.io"
    git      = "https://github.com/exawind/wind-utils.git"

    maintainers = ['sayerhs', 'jrood-nrel']

    generator = ('Ninja'
                 if os.environ.get('EXAWIND_MAKE_TYPE','').lower() == 'ninja'
                 else 'Unix Makefiles')

    version('develop', branch='master', submodules=True)

    variant('shared', default=(sys.platform != 'darwin'),
            description='Build dependencies as shared libraries')
    variant('pic', default=True,
            description='Position independent code')
    variant('hypre', default=True,
            description='Compile with hypre support')

    depends_on('ninja-fortran',
               type='build',
               when=(generator == 'Ninja'))

    depends_on('mpi')
    depends_on('trilinos~cuda~wrapper')
    depends_on('yaml-cpp@0.6.2:')
    depends_on('hypre', when='+hypre')

    conflicts('trilinos+cuda')

    def cmake_args(self):
        spec = self.spec

        options = [
            self.define('Trilinos_DIR', spec['trilinos'].prefix),
            self.define('YAML_ROOT', spec['yaml-cpp'].prefix),
            self.define_from_variant('ENABLE_HYPRE', 'hypre'),
            self.define_from_variant('CMAKE_POSITION_INDEPENDENT_CODE', 'pic'),
        ]

        if '+hypre' in spec:
            options.append(self.define('HYPRE_DIR', spec['hypre'].prefix))

        return options
