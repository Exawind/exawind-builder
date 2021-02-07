# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *

class HypreMiniApp(CMakePackage, CudaPackage):
    """ExaWind hypre mini-app"""

    homepage = "https://github.com/exawind/hypre-mini-app"
    git = "https://github.com/exawind/hypre-mini-app"

    maintainers = [ 'sayerhs', 'pmullown', 'jrood-nrel' ]

    version('develop', branch='master')

    variant('pic', default=True,
            description="Position independent code")

    depends_on('mpi')
    depends_on('yaml-cpp')
    depends_on('hypre+mpi+int64~cuda@2.20.0:', when='~cuda')
    for arch in CudaPackage.cuda_arch_values:
        depends_on('hypre+mpi~int64+cuda cuda_arch=%s @2.20.0:'%arch,
                   when='+cuda cuda_arch=%s'%arch)

    def cmake_args(self):
        args = [
            self.define_from_variant('CMAKE_POSITION_INDEPENDENT_CODE', 'pic'),
            self.define_from_variant('ENABLE_CUDA', 'cuda'),
            self.define('YAML_ROOT', self.spec['yaml-cpp'].prefix),
            self.define('HYPRE_DIR', self.spec['hypre'].prefix),
        ]

        return args
