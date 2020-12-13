.. _installation:

Installing exawind-builder
==========================

Exawind-builder provides a *bootstrap* script that will create the exawind
directory structure, fetch necessary repositories, install dependencies, and
perform initial setup and configuration. Note that this step is just preparation
for being able to build ``nalu-wind`` and doesn't install ``nalu-wind`` itself.
You will need to follow the additional steps mentioned in
:ref:`tut-basic-compilation`.

.. note::

   On OLCF Summit, NREL Eagle and Rhodes, and NERSC Cori systems, the build
   scripts are pre-installed and configured in the project directory. Users do
   not have to install their own exawind-builder on these systems. On these
   systems, you can skip the installation steps and proceed to the
   :ref:`tut-basic-compilation` section. Please consult the Exawind team if you
   are unsure where the build scripts are located on these systems. Please refer
   to :ref:`how_to_use` for more details.

For fine control of the installation process please refer to the
:ref:`manual_installation` section.

Basic installation for all systems
----------------------------------

To install using *bootstrap* script please follow these steps.

#. Mac OS X users will need to have Hombrew packages installed as documented in
   :ref:`homebrew-setup`.

#. Download the *bootstrap* script

   .. code-block:: console

      # Download bootstrap script
      curl -fsSL -o bootstrap.sh https://raw.githubusercontent.com/exawind/exawind-builder/master/bootstrap.sh
      chmod a+x bootstrap.sh

#. Execute the script by providing a target system and compiler -- see
   :ref:`available target systems <introduction>`. If your target system is not
   available, you can use the generic ``spack`` system which will fetch and compile
   all necessary dependencies for you.

   .. code-block:: console

      bootstrap.sh [options]

      Options:
        -h             - Show help message and exit
        -s <system>    - Select system profile (spack, cori, summitdev, etc.)
        -c <compiler>  - Select compiler type (gcc, clang, intel, etc.)
        -p <path>      - Root path for exawind project (default: ${HOME}/exawind)
        -n             - Configure exawind-builder to use ninja build system

   A few examples are shown below

   .. code-block:: console

      # Invoke by providing the system specification
      ./bootstrap.sh -s cori -c intel        # on NERSC Cori
      ./bootstrap.sh -s snl-ascicgpu -c gcc  # On SNL ASC GPU machine
      ./bootstrap.sh -s summitdev -c gcc     # On ORNL SummitDev

      # Example with a custom path
      ./bootstrap.sh -s cori -c intel -p ${HOME}/MyProjects/exawind

Upon sucessful execution, the bootstrap process will have created default build
scripts, an exawind configuration file (:file:`exawind-config.sh`), and an
exawind environment file (:file:`scripts/exawind-env-COMPILER.sh`). Please
verify the default values provided in :file:`exawind-config.sh` and adjust them
if necessary. By default, the *bootstrap* script will not install Trilinos or
Nalu-Wind, these need to be manually installed by the user. Please proceed to
:ref:`tut-basic-compilation` for instructions on how to compile Trilinos and
Nalu-Wind.

.. note::

   - If you have multiple versions of the same compiler installed, then use
     :envvar:`SPACK_COMPILER` to set an exact specification that you will when
     installing packages. For example, to use GCC 7.2.0 version instead of older
     versions, it might be necessary to set ``SPACK_COMPILER=gcc%7.2.0`` before
     executing the bootstrap script.

   - `Ninja <https://ninja-build.org>`_ is a build system that is an alternative
     to :program:`make`. It provides several features of :program:`make` but is
     considerably faster when building code. The speedup is particularly evident
     when compiling Trilinos. Since codes used in ExaWind project contain
     Fortran files, it requires a `special fork
     <https://github.com/Kitware/ninja>`_ of Ninja (maintained by Kitware). If
     you have already executed bootstrap and forgot to add the ``-n`` flag, then
     use :ref:`get-ninja` to install Ninja for your use.

Setting up custom ExaWind python environment
--------------------------------------------

``exawind-builder`` now supports building certain Python packages (e.g., `pySTK
<https://sayerhs.github.io/pystk/index.html>`_. To enable this capability,
you'll need to set up a custom virtual environment with the necessary python
modules. Currently, ``exawind-builder`` only supports the `Conda
<https://docs.conda.io/en/latest/index.html>`__ python package manager. To enable this capability:

1. Install `Conda <https://docs.conda.io/en/latest/miniconda.html>`__ if you
   don't have an existing conda installation.

2. Create a new virtual environment using the `create-pyenv.sh` utility

.. code-block:: console

   cd ${EXAWIND_PROJECT_DIR}
   ./exawind-builder/create-pyenv.sh -s <system> -c <compiler> -r ${CONDA_ROOT_DIR}

Upon successful installation, this creates a new virtual environment ``exawind``
with all the necessary Python modules to build and use ExaWind python libraries.

.. _homebrew-setup:

Initial Homebrew Setup for Mac OS-X Users
-----------------------------------------

On Mac OS X, we will use a combination of `Homebrew <https://brew.sh>`_ and
`spack <https://github.com/spack/spack>`_ to setup our dependencies. This
setup will use Apple's Clang compiler for C and C++ sources, and GNU GCC
``gfortran`` for Fortran sources. The dependency on Homebrew is to avoid the
compilation time required for compiling OpenMPI on Mac. Please follow these
one-time installation process to set up your Homebrew environment.

#. Setup homebrew if you don't already have it installed on your machine. Follow
   the section **Install Homebrew** at the `Homebrew website <https://brew.sh>`_.
   Note that you will need ``sudo`` access and will have to enter your password
   several times during the installation process.

#. Once Homebrew has been installed execute the following commands to install
   packages necessary for exawind-builder from homebrew.

.. code-block:: console

   # Allow installation of brew bundles
   brew tap Homebrew/brewdler

   # Fetch the exawind Brewfile
   curl -fsSL -o Brewfile https://raw.githubusercontent.com/exawind/exawind-builder/master/etc/spack/osx/Brewfile

   # Install brew packages
   brew bundle --file=Brewfile

Upon successful installation, please proceed to the :ref:`installation` section.
