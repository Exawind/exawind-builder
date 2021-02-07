# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

import sys
import os
from spack import *

def _parse_float(val):
    try:
        return float(val) > 0.0
    except ValueError:
        return False

class NaluWind(CMakePackage, CudaPackage):
    """ExaWind Nalu-Wind unstructured, incompressible CFD solver"""

    homepage = "https://nalu-wind.readthedocs.io"
    git      = "https://github.com/exawind/nalu-wind.git"

    maintainers = ['sayerhs', 'jrood-nrel']

    generator = ('Ninja'
                 if os.environ.get('EXAWIND_MAKE_TYPE','').lower() == 'ninja'
                 else 'Unix Makefiles')

    version('develop', branch='master', submodules=True)

    variant('shared', default=sys.platform != 'darwin',
            description="Build shared libraries")
    variant('pic', default=True,
            description="Enable position independent code")
    variant('openfast', default=True,
            description="Enable OpenFAST integration")
    variant('tioga', default=True,
            description="Enable TIOGA integration")
    variant('hypre', default=True,
            description="Enable hypre integration")
    variant('fftw', default=False,
            description="Enable FFTW integration")
    # Catalyst has been broken for a while
    # variant('catalyst', default=False,
    #         description="Enable ParaView Catalyst integration")
    variant('openmp', default=False,
            description="Enable OpenMP support")
    variant('boost', default=False,
            description="Enable Boost integration")
    variant('tests', default=True,
            description="Activate regression testing")
    variant('abs_tol', default=1.0e-15,
            values=float,
            description="Absolute tolerance for tests")
    variant('rel_tol', default=1.0e-12,
            values=_parse_float, multi=False,
            description="Relative tolerance for tests")

    conflicts('+shared+cuda')

    depends_on('ninja-fortran',
               type='build',
               when=(generator == 'Ninja'))

    depends_on('mpi')
    depends_on('kokkos-nvcc-wrapper', type='build', when='+cuda')
    depends_on('trilinos~cuda~wrapper', when='~cuda')
    depends_on('yaml-cpp@0.6.2:')
    depends_on('openfast+cxx', when='+openfast')
    depends_on('tioga', when='+tioga')
    depends_on('hypre+mpi+int64~superlu-dist@2.18.2:', when='+hypre~cuda')
    depends_on('fftw', when='+fftw')
    depends_on('boost cxxstd=14', when='+boost')

    depends_on('trilinos+cuda+cuda_rdc+wrapper~shared', when='+cuda')
    depends_on('hypre+mpi+cuda~int64~superlu-dist@2.18.2:', when='+hypre+cuda')
    for _arch in CudaPackage.cuda_arch_values:
        depends_on('trilinos+cuda+cuda_rdc+wrapper~shared cuda_arch=%s'%_arch,
                   when='+cuda cuda_arch=%s'%_arch)
        depends_on('hypre+mpi+cuda~int64~superlu-dist cuda_arch=%s @2.18.2:'%_arch,
                   when='+hypre+cuda cuda_arch=%s'%_arch)

    def cmake_args(self):
        args = [
            self.define_from_variant('BUILD_SHARED_LIBS', 'shared'),
            self.define_from_variant('CMAKE_POSITION_INDEPENDENT_CODE', 'pic'),
            self.define('CMAKE_EXPORT_COMPILE_COMMANDS', True),

            # This is needed because of how nvcc_wrapper is handled
            self.define('CMAKE_CXX_COMPILER', self.spec['mpi'].mpicxx),
            self.define('CMAKE_C_COMPILER', self.spec['mpi'].mpicc),
            self.define('CMAKE_Fortran_COMPILER', self.spec['mpi'].mpifc),
        ]

        args.extend(
            self.define_from_variant("ENABLE_%s"%vv.upper(), vv)
            for vv in "cuda openfast tioga hypre fftw openmp boost tests".split())

        if 'darwin' in self.spec.architecture:
            options.append('-DCMAKE_MACOSX_RPATH:BOOL=ON')

        if '+tests' in self.spec:
            args.extend([
                self.define('TEST_TOLERANCE',
                  self.spec.variants['abs_tol'].value),
                self.define('TEST_REL_TOL',
                  self.spec.variants['rel_tol'].value),
            ])

        return args
