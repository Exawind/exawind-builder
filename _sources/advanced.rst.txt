.. _manual_installation:

Manual Installation
===================

This section will walk through the steps to creating a :ref:`basic directory
layout <exawind_dir_layout>`, cloning ``exawind-builder`` repository. In this
example, we will create the :file:`exawind` base directory within the user's
home directory. Modify this appropriately.

.. code-block:: console

   cd ${HOME}  # Change this to your preferred location

   # Create the basic directory layout
   mkdir -p exawind/{source,install,scripts}

   # Clone exawind-builder repo
   cd exawind
   git clone https://github.com/exawind/exawind-builder.git

   # Clone nalu-wind that we will use as an example later
   cd ../source
   git clone https://github.com/exawind/nalu-wind.git

If you are working on a system where the dependencies are already installed in a
shared project location, then you can skip the next location and go to
:ref:`new-script`.

Setting up dependencies
--------------------------

This section details basic steps to install all dependencies from scratch and
have a fully independent installation of the ExaWind software ecosystem. This is
a one-time setup step.

Mac OS X users will need to setup Homebrew as described in :ref:`homebrew-setup`
before proceeding.

Install dependencies via spack (all systems)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Setup ExaWind directory structure as described in :ref:`exawind_dir_layout`.

#. Clone the spack repository

   .. code-block:: console

      cd ${HOME}/exawind
      git clone https://github.com/spack/spack.git

      # Activate spack (for the remainder of the steps)
      source ./spack/share/spack/setup-env.sh

#. Copy package specifications for Spack. The file :file:`packages.yaml`
   instructs Spack to use the installed compilers and MPI packages thereby
   cutting down on build time. It also pins other packages to specific versions
   so that the build is consistent with other machines.

   .. code-block:: console

      cd ${HOME}/exawind/exawind-builder/etc/spack/osx
      cp packages.yaml ${HOME}/.spack/$(spack arch -p)/

   The above example shows the configuration of OSX. Choose other appropriate
   directory within :file:`spack_cfg`. Spack configs for other systems can be
   adapted from the `build-test
   <https://github.com/Exawind/build-test/tree/master/configs/machines>`_
   repository.

   Users can also copy :file:`compilers.yaml` if desired to override default
   compilers detected by spack.

   .. note::

      For automatic updates, users can symlink the packages.yaml file within the
      spack configuration directory to the version in ``exawind-builder``

      .. code-block:: console

         ln -s ${HOME}/exawind/exawind-builder/etc/spack/${SYSTEM}/packages.yaml ${HOME}/.spack/$(spack arch -p)/

#. Setup compilers to be used by spack. As with :file:`packages.yaml`, it is
   recommended that the users use the compiler configuration provided with
   ``exawind-builder``.

   .. code-block:: console

      cp compilers.yaml ${HOME}/.spack/$(spack arch -p)/

   For more flexibility, users can use ``spack`` to determine the compilers
   available on their system.

   .. code-block:: console

      spack compiler find

   The command will detect all available compiler on users environment and
   create a :file:`compilers.yaml` in the :file:`${HOME}/.spack/$(spack arch -p)`.

   .. note::

      If you have multiple :file:`compilers.yaml` in several locations, make
      sure that the specs are not conflicting. Also check :file:`packages.yaml`
      to make sure that the compilers are listed in the preferred order for
      spack to pick up the right compiler.

#. Instruct spack to track packages installed via Homebrew. Note that on most
   systems the following commands will run very quickly and will not attempt to
   download and build packages.

   .. code-block:: console

      spack install cmake
      spack install mpi
      spack install m4
      spack install zlib
      spack install libxml2
      spack install boost

#. Install remaining dependencies via Spack. The following steps will download,
   configure, and compile packages.

   .. code-block:: console

      # These dependencies must be installed (mandatory)
      spack install superlu
      spack install hdf5
      spack install netcdf
      spack install yaml-cpp

      # These are optional
      spack install openfast
      spack install hypre
      spack install tioga

   It is recommended that you build/install Trilinos using the build scripts
   described in :ref:`basic_usage` section. The *optional* dependencies could be
   installed via that method also.

#. Generate build scripts as described in :ref:`new-script` section. On OS X,
   use ``-s spack`` for the system when generating the build scripts. For Cori
   and SummitDev, use the appropriate :envvar:`system <EXAWIND_SYSTEM>` which
   will initialize the compiler and MPI modules first and then activate Spack in
   the background. You will need to configure at least :envvar:`SPACK_ROOT` if
   it was not installed in the default location suggested in the directory
   layout at the beginning of this section.

Upon successful installation, executing ``spack find`` at the command line
should show you the following packages (on Mac OSX)

.. code-block:: console

   $ spack find
   ==> 12 installed packages.
   -- darwin-sierra-x86_64 / clang@9.0.0-apple ---------------------
   boost@1.67.0  libxml2@2.2     netlib-lapack@3.8.0    superlu@4.3
   cmake@3.12.0  m4@1.4.6        openmpi@3.1.1          yaml-cpp@develop
   hdf5@1.10.1   netcdf@4.4.1.1  parallel-netcdf@1.8.0  zlib@1.2.8


.. _builder-config:

Generate builder configuration
------------------------------

Create your specific configuration in :file:`${HOME}/exawind/exawind-config.sh`.
A sample file is shown below

.. code-block:: console

   ### Example exawind-config.sh file
   #
   # Note: these variables can be overridden through the script in build directory
   #

   # Specify path to your own Spack install (if not in default location)
   export SPACK_ROOT=${HOME}/spack

   # Track trilinos builds by date
   # export TRILINOS_INSTALL_DIR=${EXAWIND_INSTALL_DIR}/trilinos-$(date "+%Y-%m-%d")

   ### Specify custom builds for certain packages. The following are only
   ### necessary if you didn't install these packages via spack, but instead are
   ### using your own development versions.
   export TRILINOS_ROOT_DIR=${EXAWIND_INSTALL_DIR}/trilinos
   export TIOGA_ROOT_DIR=${EXAWIND_INSTALL_DIR}/tioga
   export HYPRE_ROOT_DIR=${EXAWIND_INSTALL_DIR}/hypre
   export OPENFAST_ROOT_DIR=${EXAWIND_INSTALL_DIR}/openfast

   # Turn on/off certain TPLs and options
   ENABLE_OPENMP=OFF
   ENABLE_TIOGA=OFF
   ENABLE_OPENFAST=OFF
   ENABLE_HYPRE=OFF

See :ref:`reference` for more details. Note that the default path for Spack
install is :file:`${EXAWIND_PROJECT_DIR}/spack`.

.. _new-script:

Generating Build Scripts
------------------------

``exawind-builder`` provides a :file:`new-script.sh` command to generate build
scripts for combination of system, project, and compiler. The basic usage is shown below

.. code-block:: console

   bash$ ./new-script.sh -h
   new-script.sh [options] [output_file]

   Options:
     -h             - Show help message and exit
     -p <project>   - Select project (nalu-wind, openfast, etc)
     -s <system>    - Select system profile (spack, peregrine, cori, etc.)
     -c <compiler>  - Select compiler type (gcc, intel, clang)

   Argument:
     output_file    - Name of the build script (default: '$project-$compiler.sh')

So if the user desires to generate a build script for Trilinos on the NERSC Cori
system using the Intel compiler, they would execute the following at the command line

.. code-block:: console

   # Switch to scripts directory
   cd ${HOME}/exawind/scripts

   # Declare project directory variable (default is parent directory of exawind-builder)
   export EXAWIND_PROJECT_DIR=${HOME}/exawind

   # Create the new script
   ../exawind-builder/new-script.sh -s cori -c intel -p trilinos

   # Create a script with a different name
   ../exawind-builder/new-script.sh -s cori -c intel -p trilinos trilinos-haswell.sh


.. _create-env:

Creating runtime environment script
-----------------------------------

``exawind-builder`` provides a :file:`create-env.sh` command to generate a
source-able script that can be used within job submission scripts as well as to
recreate the environment used to build the code in interactive shells.

.. code-block:: console

   create-env.sh [options] [output_file_name]

   By default it will create a file called exawind-env-$COMPILER.sh

   Options:
     -h             - Show help message and exit
     -s <system>    - Select system profile (spack, cori, summitdev, etc.)
     -c <compiler>  - Select compiler type (gcc, clang, intel, etc.)

Sample usage shown below

.. code-block:: console

   # Create a new environment file
   cd ${HOME}/exawind/scripts

   ../exawind-builder/create-env.sh -s eagle -c gcc

   # Source the script within interactive shells
   source ./exawind-env-gcc.sh

   # Load additional modules
   exawind_load_deps hdf5 netcdf

It is recommended that the user use :func:`exawind_load_deps` instead of
:program:`spack load` or :program:`module load` as this has several advantages:
``exawind-builder`` will automatically use spack/module to load depending on the
system you are on, so you can use one command across different systems; this
command will respect :envvar:`EXAWIND_MODMAP` and load the appropriate module
that you have configured instead of the defaults on the system; it will
configure CUDA based on :envvar:`ENABLE_CUDA`.

.. _get-ninja:

Configuring exawind-builder to use Ninja
----------------------------------------

`Ninja <https://ninja-build.org>`_ is a build system that is an alternative to
:program:`make`. It provides several features of :program:`make` but is
considerably faster when building code. The speedup is particularly evident when
compiling Trilinos. Since codes used in ExaWind project contain Fortran files,
it requires a `special fork <https://github.com/Kitware/ninja>`_ of Ninja
(maintained by Kitware). ``exawind-builder`` provides a script
:file:`get-ninja.sh` to fetch and configure Ninja for builds.

.. code-block:: console

   # Get Ninja
   cd ${HOME}/exawind
   ./exawind-builder/utils/get-ninja.sh

.. note::

   You will need to execute ``cmake_full`` to force CMake to recreate build
   files using Ninja if they were previously configured to use
   :file:`Makefiles`.

.. _code-build-steps:

Compiling Nalu-Wind
-------------------

At this point you have manually recreated all the steps performed by the
*bootstrap* process. Please follow :ref:`tut-basic-compilation` to build Trilinos
and Nalu-Wind
