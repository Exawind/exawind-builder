# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *
from spack.pkg.builtin.hypre import Hypre as HypreBase

class Hypre(HypreBase, CudaPackage):
    """ExaWind specific fork of hypre package"""

    variant('cuda-uvm', default=False,
            description="Enable CUDA UVM support")
    variant('curand', default=True,
            description="Enable CURAND integration")
    variant('cub', default=False,
            description="Enable CUB integration")

    # conflicts('+cuda +int64')

    def _cfg_opt_from_spec(self, var):
        return '--%s-%s'%('enable' if '+'+var in self.spec else 'disable', var)

    def _configure_args(self):
        """Generate configuration arguments

        See builtin hypre for more details
        """
        # Reproduced from spack/var/spack/repos/builtin/packages/hypre
        # Note: --with-(lapack|blas)_libs= needs space separated list of names
        lapack = self.spec['lapack'].libs
        blas = self.spec['blas'].libs

        configure_args = [
            '--prefix=%s' % prefix,
            '--with-lapack-libs=%s' % ' '.join(lapack.names),
            '--with-lapack-lib-dirs=%s' % ' '.join(lapack.directories),
            '--with-blas-libs=%s' % ' '.join(blas.names),
            '--with-blas-lib-dirs=%s' % ' '.join(blas.directories)
        ]

        if '+mpi' in self.spec:
            configure_args.append('--with-MPI')
        else:
            configure_args.append('--without-MPI')

        configure_args.append(
            '--%s-openmp'%('with' if '+openmp' in self.spec else 'without'))
        configure_args.extend(
            self._cfg_opt_from_spec(vv)
            for vv in "mixedint complex shared debug".split())

        configure_args.append(
            '--%s-cuda'%('with' if '+cuda' in self.spec else 'without'))
        if '+cuda' in self.spec:
            configure_args.extend([
                self._cfg_opt_from_spec('curand'),
                self._cfg_opt_from_spec('cub'),
            ])
            if '+cuda-uvm' in self.spec:
                configure_args.append('--enable-unified-memory')

        if '~cuda+int64' in self.spec:
            configure_args.append('--enable-bigint')
        else:
            configure_args.append('--disable-bigint')

        if '~internal-superlu' in self.spec:
            configure_args.append("--without-superlu")
            # MLI and FEI do not build without superlu on Linux
            configure_args.append("--without-mli")
            configure_args.append("--without-fei")

        if '+superlu-dist' in self.spec:
            configure_args.append('--with-dsuperlu-include=%s' %
                                  spec['superlu-dist'].prefix.include)
            configure_args.append('--with-dsuperlu-lib=%s' %
                                  spec['superlu-dist'].libs)
            configure_args.append('--with-dsuperlu')

        return configure_args

    def setup_build_environment(self, env):
        env.set('CC', self.spec['mpi'].mpicc)
        env.set('CXX', self.spec['mpi'].mpicxx)
        env.set('F77', self.spec['mpi'].mpif77)

        if '+cuda' in self.spec:
            env.set('CUDA_HOME', self.spec['cuda'].prefix)
            env.set('CUDA_PATH', self.spec['cuda'].prefix)
            cuda_arch = self.spec.variants['cuda_arch'].value
            if cuda_arch:
                arch_sorted = list(sorted(cuda_arch, reverse=True))
                env.set('HYPRE_CUDA_SM', arch_sorted[0])
            # In CUDA builds hypre currently doesn't handle flags correctly
            env.append_flags(
                'CXXFLAGS', '-O2' if '~debug' in self.spec else '-g')

    def install(self, spec, prefix):
        configure_args = self._configure_args()
        # Hypre's source is staged under ./src so we'll have to manually
        # cd into it.
        with working_dir("src"):
            configure(*configure_args)

            make()
            # ExaWind -- Disabled run tests option
            make("install")
