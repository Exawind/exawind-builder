.. _installation:

Installation
============

Exawind-builder provides a *bootstrap* script that will create the exawind
directory structure, fetch necessary repositories, install dependencies, and
perform initial setup and configuration. For fine control of the installation
process please refer to the :ref:`manual_installation` section.

Basic installation for all systems
----------------------------------

To install using *bootstrap* script please follow these steps.


#. Mac OS X users will need to have Hombrew packages installed as documented in
   :ref:`homebrew-setup`.

#. Download the *bootstrap* script

   .. code-block:: console

      # Download bootstrap script
      curl -fsSL -o bootstrap.sh https://raw.githubusercontent.com/sayerhs/exawind-builder/master/bootstrap.sh
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
:ref:`compiling-software` for instructions on how to compile Trilinos and
Nalu-Wind.

.. note::

   - If you have multiple versions of the same compiler installed, then use
     :envvar:`SPACK_COMPILER` to set an exact specification that you will when
     installing packages. For example, to use GCC 7.2.0 version instead of older
     versions, it might be necessary to set ``SPACK_COMPILER=gcc%7.2.0`` before
     executing the bootstrap script.

.. _homebrew-setup:

Initial Homebrew Setup for Mac OS-X Users
-----------------------------------------

On Mac OS X, we will use a combination of `Homebrew <https://brew.sh>`_ and
`LLNL spack <https://github.com/llnl/spack>`_ to setup our dependencies. This
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
   curl -fsSL -o Brewfile https://raw.githubusercontent.com/sayerhs/exawind-builder/master/etc/spack/osx/Brewfile

   # Install brew packages
   brew bundle --file=Brewfile

Upon successful installation, please proceed to the :ref:`installation` section.
