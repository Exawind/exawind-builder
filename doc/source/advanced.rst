.. _advanced_usage:

Advanced Usage
==============

We start with a description of the code organization that will be used in the
rest of the manual before describing the installation and usage of the build
scripts. All source code, build directories, installation directories, and the
``exawind-builder`` package itself is assumed to be located within
:file:`exawind` base directory. Within this directory the main subdirectories
are shown below:

::

  exawind/
  ├── exawind-builder
  ├── exawind-config.sh
  ├── install
  │   ├── hypre
  │   ├── tioga
  │   ├── trilinos-omp
  │   └── trilinos
  ├── scripts
  │   ├── hypre-clang.sh
  │   ├── nalu-wind-clang.sh
  │   ├── tioga-clang.sh
  │   └── trilinos-clang.sh
  ├── spack
  └── source
      ├── hypre
      ├── nalu-wind
      ├── openfast
      ├── tioga
      ├── trilinos
      └── wind-utils

The sub-directories are:

- ``exawind-builder``: The build script package cloned from the git repository
  that contains scripts to configure and build codes on different systems.

- ``spack``: Optional location for `spack <https://github.com/llnl/spack>`_ if
  using Spack to manage dependencies.

- ``source``: Local git repository checkouts of the ExaWind codes of interest to the user.

- ``scripts``: The default build scripts for different project and compiler
  combination. Users can either symlink the scripts into the build directory or
  copy and modify them within different build directories (e.g., release vs.
  debug builds).

- ``install``: The default install location where ``make install`` will install
  the headers, libraries, and executables.

In addition to the sub-directories, users can also provide an optional
configuration file :file:`exawind-config.sh` that can be used to customize
options common to building all the codes.

.. _installation:

Installation
------------


This section will walk through the steps to creating a basic directory layout,
cloning ``exawind-builder`` repository. In this example, we will create the
:file:`exawind` base directory within the user's home directory. Modify this
appropriately.

.. code-block:: bash

   cd ${HOME}  # Change this to your preferred location

   # Create the basic directory layout
   mkdir -p exawind/{source,install,scripts}

   # Clone exawind-builder repo
   cd exawind
   git clone https://github.com/sayerhs/exawind-builder.git

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

Initial Homebrew (Mac OS X only)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For OS X we will use a combination of `Homebrew <https://brew.sh>`_ and `spack
<https://github.com/llnl/spack>`_ to set up our dependencies. The setup will use
Apple's Clang compiler for C and C++ and GNU GCC ``gfortran`` for Fortran codes.


#. Setup homebrew if you don't already have it installed on your machine. Follow
   the section **Install Homebrew** at the `Homebrew website <https://brew.sh>`.
   Note that you will need ``sudo`` access and will have to enter your password
   several times during the installation process.

#. Setup ExaWind directory structure and clone ``exawind-builder`` as described
   in :ref:`installation` section.

#. Install necessary packages through Homebrew

   .. code-block:: bash

      # Switch to the location where you setup your exawind directory
      cd ${HOME}/exawind
      brew tap Homebrew/brewdler

      # Install brew packages (fix path to the file appropriately)
      brew bundle --file=./exawind-builder/spack_cfg/osx/Brewfile

   This step will install the necessary packages, GCC compilers, OpenMPI, and
   CMake.

Install dependencies via spack (all systems)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Setup ExaWind directory structure as described in :ref:`Installation`.

#. Clone the spack repository

   .. code-block:: bash

      cd ${HOME}/exawind
      git clone git@github.com:LLNL/spack.git

      # Activate spack (for the remainder of the steps)
      source ./spack/share/spack/setup-env.sh

      # Let spack detect compilers installed on your system
      spack compiler find

#. Copy package specifiations for Spack. The file :file:`packages.yaml`
   instructs Spack to use the installed compilers and MPI packages thereby
   cutting down on build time. It also pins other packages to specific versions
   so that the build is consistent with other machines.

   .. code-block:: bash

      cd ${HOME}/exawind/exawind-builder/spack_cfg/osx
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

      .. code-block:: bash

         ln -s packages.yaml ${HOME}/.spack/$(spack arch -p)/

#. Instruct spack to track packages installed via Homebrew. Note that on most
   systems the following commands will run very quickly and will not attempt to
   download and build packages.

   .. code-block:: bash

      spack install cmake
      spack install mpi
      spack install m4
      spack install zlib
      spack install libxml2
      spack install boost

#. Install remaining dependencies via Spack. The following steps will download,
   configure, and compile packages.

   .. code-block:: bash

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

.. code-block:: bash

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

.. code-block:: bash

   ### Example exawind-config.sh file
   #
   # Note: these variables can be overridden within the build script
   #

   # Specify path to your own Spack install (if not in default location)
   export SPACK_ROOT=${HOME}/spack

   # Track trilinos builds by date
   # export TRILINOS_INSTALL_DIR=${EXAWIND_INSTALL_DIR}/trilinos-$(date "+%Y-%m-%d")

   # Specify custom builds for certain packages
   export TRILINOS_ROOT_DIR=${EXAWIND_INSTALL_DIR}/trilinos-omp
   export TIOGA_ROOT_DIR=${EXAWIND_INSTALL_DIR}/tioga
   export HYPRE_ROOT_DIR=${EXAWIND_INSTALL_DIR}/hypre
   export OPENFAST_ROOT_DIR=${EXAWIND_INSTALL_DIR}/openfast

   # Turn on/off certain TPLs and options
   ENABLE_OPENMP=OFF
   ENABLE_TIOGA=OFF
   ENABLE_OPENFAST=ON

See :ref:`reference` for more details. Note that the default path for Spack
install is :file:`${EXAWIND_PROJECT_DIR}/spack`.

.. _new-script:

Generating Build Scripts
------------------------

``exawind-builder`` provides a :file:`new-script.sh` command to generate build
scripts for combination of system, project, and compiler. The basic usage is shown below

.. code-block:: bash

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

.. code-block:: bash

   # Switch to scripts directory
   cd ${HOME}/exawind/scripts

   # Create the new script
   ../exawind-builder/new-script.sh -s cori -c intel -p trilinos

   # Create a script with a different name
   ../exawind-builder/new-script.sh -s cori -c intel -p trilinos trilinos-haswell.sh
