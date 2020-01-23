.. _introduction:

Introduction
============

Exawind-builder is a set of bash functions that can be compiled to generate
build scripts for the software used in `ExaWind <https://www.exawind.org>`_
project on the different systems of interest. It separates machine-specific
configuration from the software-specific configuration (tracking library
dependencies and CMake configuration) so that they can be modularized and
combined for different systems and compilers.

Pre-built configurations exist for the following systems. Use the ``system
name`` shown on the following table when generating scripts targeting that
particular system.

  ==================== ============================================================================================
  System Name          Description
  ==================== ============================================================================================
  ``spack``             `Spack <https:://github.com/spack/spack>`_ (system agnostic)
  ``anl-jlse-skylake``  `ANL JLSE Skylake <https://www.jlse.anl.gov>`_
  ``ornl-summit``       `OLCF Summit <https://www.olcf.ornl.gov/summit/>`_
  ``eagle``             `NREL Eagle <https://www.nrel.gov/hpc/eagle-system.html>`_
  ``cori``              `NERSC Cori <http://www.nersc.gov/users/computational-systems/cori/>`_
  ``summitdev``         `OLCF SummitDev <https://www.olcf.ornl.gov/olcf-resources/compute-systems/summit/>`_
  ``snl-waterman``.     Sandia waterman cluster (also ``snl-waterman-atdm``)
  ``snl-ghost``         Sandia Ghost cluster
  ``snl-skybridge``     Sandia Skybridge cluster
  ``snl-ascicgpu``      Sandia ASC GPU development machines
  ``snl-ceerws``        Sandia blade workstations
  ``pnnl-constance``    PNNL Constance system
  ``rhodes``            NREL nightly build and test system
  ``peregrine``         `NREL Peregrine <https://www.nrel.gov/hpc/peregrine-system.html>`_
  ==================== ============================================================================================

  The following compilers are configured for each machine. In situations where
  multiple compilers are present, we recommend that the users use the first one.
  The latter ones have not received enough testing and might have issues.

  ================== ========================
  Environment        Compilers
  ================== ========================
  anl-jlse-skylake   gcc
  ornl-summit        gcc, cuda
  eagle              gcc
  cori               intel
  summitdev          gcc, xl, cuda
  snl-waterman.      gcc, cuda
  snl-ghost          intel
  snl-skybridge      intel
  snl-ascicgpu       gcc, cuda
  snl-ceerws         gcc
  pnnl-constance     gcc
  rhodes             gcc, intel
  Mac OSX            clang, gcc
  peregrine          gcc, intel
  ================== ========================


Exawind-builder provides CMake configurations for the following codes used
within the ExaWind project. Please consult :ref:`reference` section for
configuration variables availble to customize configuration of each project.

  ==================== =================================================
  Nalu-Wind            https://github.com/exawind/nalu-wind.git
  Trilinos             https://github.com/trilinos/trilinos.git
  OpenFAST             https://github.com/openfast/openfast.git
  Nalu Wind Utilities  https://github.com/exawind/wind-utils.git
  TIOGA                https://github.com/jsitaraman/tioga.git
  TIOGA Utilities      https://github.com/sayerhs/tioga_utils.git
  HYPRE                https://github.com/LLNL/hypre.git
  hypre-mini-app       https://github.com/exawind/hypre-mini-app.git
  ArborX               https://github.com/arborx/ArborX.git
  ==================== =================================================


Use cases
---------

The exawind-builder provides capability for three different workflows of
increasing complexity:

#. The simplest use case is on a system where all the dependencies are managed
   by the ExaWind team (e.g., NREL Peregrine, NERSC Cori, etc.). In this
   scenario, the user just needs to clone the appropriate code repo and use the
   build script to compile their desired branch with apporpriate CMake options.
   This use case is described in :ref:`basic_usage` section.

#. Depending on the task, users might need to use different branch of a
   third-party library (TPL). For example, user might need a different branch of
   OpenFAST or TIOGA when developing a new feature within Nalu-Wind. This will
   require the user to maintain multiple development builds of the codes and
   keep them all in sync. :ref:`build_custom` provides information on how to
   manage this workflow.

#. Finally, the user might need to install and manage all dependencies
   themselves, e.g., on their personal laptops. :ref:`installation` details
   all the necessary steps to setup your own ExaWind environment and manage all
   dependencies on different machines. This mimics the `build-test
   <https://github.com/Exawind/build-test>`_ infrastructure of ExaWind project,
   but opts to use system configuration as much as possible to minimize build
   time on dependencies.

.. _exawind_dir_layout:

Exawind directory structure
---------------------------

Exawind-builder recommends the organizing code under a standard directory
structure for ExaWind project. While it is not necessary to follow this
directory structure, and the user is free to call the build scripts from any
location, the standard directory structure will be used in the rest of the
manual. A brief description of the standard layout is presented here.

All source code, build directories, installation directories, and the
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
  that contains scripts to configure and build codes on different systems. This
  directory must be considered read-only unless you are adding features to
  exawind-builder. This directory is not necessary if you are using one of the
  central installations of ExaWind.

- ``spack``: Optional location for Spack if using Spack to manage dependencies.
  Not used on NREL systems -- Peregrine, Eagle, and Rhodes.

- ``source``: Local git repository checkouts of the ExaWind codes of interest to
  the user. This is the recommended location for all the development versions of
  the various codes (e.g., nalu-wind, openfast, etc.).

- ``scripts``: The default build scripts for different project and compiler
  combination. Users can either symlink the scripts into the build directory or
  copy and modify them within different build directories (e.g., release vs.
  debug builds). Use the :ref:`new-script.sh <new-script>` utility to generate
  these build scripts.

- ``install``: The default install location where ``make install`` will install
  the headers, libraries, and executables.

In addition to the sub-directories, users can also provide an optional
configuration file :file:`exawind-config.sh` that can be used to customize
options common to building all the codes.
