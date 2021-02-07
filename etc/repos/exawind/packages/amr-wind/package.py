# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

import os
import itertools
from spack import *

def process_amrex_constraints():
    """Map constraints when building with external AMReX"""
    a1 = ['+', '~']
    a2 = ['mpi', 'hypre', 'cuda']
    a3 = [[x + y for x in a1] for y in a2]
    for k in itertools.product(*a3):
        if '+cuda' in k:
            for arch in CudaPackage.cuda_arch_values:
                yield ''.join(k) + " cuda_arch=%s"%arch
        else:
            yield ''.join(k)

class AmrWind(CMakePackage, CudaPackage):
    """ExaWind AMR-Wind block-structured, incompressible solver"""

    homepage = "https://exawind.github.io/amr-wind"
    git      = "https://github.com/exawind/amr-wind"

    maintainers = ['sayerhs', 'jrood-nrel', 'michaeljbrazell']

    version('develop', branch='development', submodules=True)

    generator = ('Ninja'
                 if os.environ.get('EXAWIND_MAKE_TYPE','').lower() == 'ninja'
                 else 'Unix Makefiles')

    # variant('cxxstd', default='14',
    #         values=['11', '14', '17', '20'],
    #         multi=False,
    #         description="C++ standard")
    variant('shared', default=True,
            description="Build shared libs")
    variant('unit', default=True,
            description="Build unit tests")
    variant('tests', default=True,
            description="Activate regression tests")
    variant('mpi', default=True,
            description='Enable MPI')
    variant('openmp', default=False,
            description='Enable OpenMP')
    variant('netcdf', default=True,
            description="Enable NetCDF support")
    variant('hypre', default=True,
            description="Enable hypre integration")
    variant('masa', default=False,
            description="Enable MASA integration")
    variant('openfast', default=False,
            description="Enable OpenFAST integration")
    variant('internal-amrex', default=True,
            description="Use AMReX submodule to build")

    depends_on('ninja-fortran',
               type='build',
               when=(generator == 'Ninja'))

    depends_on('mpi', when='+mpi')
    for opt in process_amrex_constraints():
        depends_on('amrex'+opt+'@20.12:', when='~internal-amrex'+opt)
    depends_on('hypre+mpi+int64~cuda@2.20.0:', when='+mpi~cuda+hypre')
    depends_on('hypre~mpi+int64~cuda@2.20.0:', when='~mpi~cuda+hypre')
    for arch in CudaPackage.cuda_arch_values:
        depends_on('hypre+mpi~int64+cuda cuda_arch=%s @2.20.0:'%arch,
                   when='+mpi+cuda+hypre cuda_arch=%s'%arch)
        depends_on('hypre~mpi~int64+cuda cuda_arch=%s @2.20.0:'%arch,
                   when='~mpi+cuda+hypre cuda_arch=%s'%arch)
    depends_on('netcdf-c', when='+netcdf')
    depends_on('masa', when='+masa')
    depends_on('openfast+cxx', when='+openfast')

    def process_cuda_args(self):
        """Process CUDA arch spec and convert it to AMReX format"""
        amrex_arch_map = {'20': '2.0', '21': '2.1', '30': '3.0', '32': '3.2',
                          '35': '3.5', '37': '3.7', '50': '5.0', '52': '5.2',
                          '53': '5.3', '60': '6.0', '61': '6.1', '62': '6.2',
                          '70': '7.0', '72': '7.2', '75': '7.5', '80': '8.0',
                          '86': '8.6'}

        cuda_arch = self.spec.variants['cuda_arch'].value
        try:
            amrex_arch = []
            for vv in cuda_arch:
                if vv in amrex_arch_map:
                    amrex_arch.append(amrex_arch_map[vv])
            return amrex_arch
        except:
            return []

    def cmake_args(self):
        define = CMakePackage.define

        args = [
            self.define_from_variant("AMR_WIND_ENABLE_%s"%v.upper(), v)
            for v in "mpi cuda openmp netcdf hypre masa openfast tests".split()
        ]

        args += [
            define('CMAKE_EXPORT_COMPILE_COMMANDS', True),
            define('AMR_WIND_ENABLE_ALL_WARNINGS', True),
            self.define_from_variant('BUILD_SHARED_LIBS', 'shared'),
            self.define_from_variant('AMR_WIND_TEST_WITH_FCOMPARE', 'tests'),
        ]

        if '+cuda' in self.spec:
            amrex_arch = self.process_cuda_args()
            if amrex_arch:
                args.append(define('AMReX_CUDA_ARCH', ';'.join(amrex_arch)))

        if '+internal-amrex' in self.spec:
            args += [
                self.define('AMR_WIND_USE_INTERNAL_AMREX', True)
            ]
        else:
            args += [
                self.define('AMR_WIND_USE_INTERNAL_AMREX', False),
                self.define('AMReX_ROOT', self.spec['amrex'].prefix)
            ]

        return args
