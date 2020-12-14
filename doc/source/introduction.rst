.. _introduction:

Introduction
============

`Exawind-builder <https://github.com/exawind/exawind-builder>`_ is a set of bash
functions that can be compiled to generate build scripts for the software used
in `ExaWind <https://www.exawind.org>`_ project on the different systems of
interest. It separates machine-specific configuration from the software-specific
configuration (tracking library dependencies and CMake configuration) so that
they can be modularized and combined for different systems and compilers.

Pre-configured systems
----------------------

Pre-built configurations exist for the following systems. Use the ``system
name`` shown on the following table when generating scripts targeting that
particular system. Within the build scripts the system is accessed using the
environment variable :envvar:`EXAWIND_SYSTEM`.

  ==========================  ============================================================================================
  System Name                 Description
  ==========================  ============================================================================================
  ``spack``                   `Spack <https:://github.com/spack/spack>`_ (system agnostic)
  ``anl-jlse-skylake``        `ANL JLSE Skylake <https://www.jlse.anl.gov>`_
  ``anl-jlse-gpu_v100_smx2``  `ANL JLSE V100 nodes <https://www.jlse.anl.gov>`_
  ``ornl-summit``             `OLCF Summit <https://www.olcf.ornl.gov/summit/>`_
  ``eagle``                   `NREL Eagle <https://www.nrel.gov/hpc/eagle-system.html>`_
  ``cori``                    `NERSC Cori <http://www.nersc.gov/users/computational-systems/cori/>`_
  ``snl-waterman``.           Sandia waterman cluster (also ``snl-waterman-atdm``)
  ``snl-ghost``               Sandia Ghost cluster
  ``snl-skybridge``           Sandia Skybridge cluster
  ``snl-ascicgpu``            Sandia ASC GPU development machines
  ``snl-ceerws``              Sandia blade workstations
  ``snl-ews``                 Sandia engineering workstations
  ``pnnl-constance``          PNNL Constance system
  ``rhodes``                  NREL nightly build and test system
  ==========================  ============================================================================================

Supported compilers for pre-configured systems
``````````````````````````````````````````````

The following compilers are configured for each machine. In situations where
multiple compilers are present, we recommend that the users use the first one.
The latter ones have not received enough testing and might have issues. Within
the build scripts and elsewhere in the user manual the compiler suite is
referred using the environment variable :envvar:`EXAWIND_COMPILER`.

====================== ========================
Environment            Compilers
====================== ========================
anl-jlse-skylake       gcc
anl-jlse-gpu_v100_smx2 gcc, cuda
ornl-summit            gcc, cuda
eagle                  gcc
cori                   intel
snl-waterman           gcc, cuda
snl-ghost              intel
snl-skybridge          intel
snl-ascicgpu           gcc, cuda
snl-ceerws             gcc
snl-ews                gcc
pnnl-constance         gcc
rhodes                 gcc, intel
Mac OSX                clang, gcc
====================== ========================

.. _exawind_codes:

ExaWind software suite
----------------------

Exawind-builder provides CMake configurations for the following codes used
within the ExaWind project. Please consult :ref:`reference` section for
configuration variables availble to customize configuration of each project.
Within the build scripts, the code that is being configured/compiled is referred
using the environment variable :envvar:`EXAWIND_CODE`.

  ==================== =================================================
  Code                 Public Git repository
  ==================== =================================================
  Nalu-Wind            https://github.com/exawind/nalu-wind.git
  AMR-Wind             https://github.com/exawind/amr-wind.git
  Trilinos             https://github.com/trilinos/trilinos.git
  OpenFAST             https://github.com/openfast/openfast.git
  Nalu Wind Utilities  https://github.com/exawind/wind-utils.git
  TIOGA                https://github.com/jsitaraman/tioga.git
  TIOGA Utilities      https://github.com/sayerhs/tioga_utils.git
  pySTK                https://github.com/sayerhs/pystk.git
  pyAMReX              https://github.com/sayerhs/pyamrex.git
  ExaWind-Sim          https://github.com/sayerhs/exawind-sim.git
  HYPRE                https://github.com/LLNL/hypre.git
  hypre-mini-app       https://github.com/exawind/hypre-mini-app.git
  ArborX               https://github.com/arborx/ArborX.git
  ==================== =================================================


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
  ├── exawind-config-ornl-summit.sh
  ├── exawind-config-gcc7-cuda10.sh
  ├── exawind-config.sh
  ├── install
  │   └── gcc8
  │       ├── amr-wind
  │       ├── amrex
  │       ├── hypre
  │       ├── nalu-wind
  │       ├── openfast
  │       ├── tioga
  │       └── trilinos
  │   └── gcc8-cuda10
  │       ├── amr-wind
  │       ├── amrex
  │       ├── hypre
  │       ├── nalu-wind
  │       ├── openfast
  │       ├── tioga
  │       └── trilinos
  │   └── intel18
  │       ├── amr-wind
  │       ├── amrex
  │       ├── nalu-wind
  │       ├── openfast
  │       ├── tioga
  │       └── trilinos
  ├── scripts
  │   ├── amr-wind-gcc.sh
  │   ├── amrex-gcc.sh
  │   ├── arborx-gcc.sh
  │   ├── exawind-env-gcc.sh
  │   ├── exawind-sim-gcc.sh
  │   ├── hypre-gcc.sh
  │   ├── hypre-mini-app-gcc.sh
  │   ├── nalu-wind-gcc.sh
  │   ├── openfast-gcc.sh
  │   ├── pifus-gcc.sh
  │   ├── pyamrex-gcc.sh
  │   ├── pystk-gcc.sh
  │   ├── tioga-gcc.sh
  │   ├── tioga-utils-gcc.sh
  │   ├── trilinos-gcc.sh
  │   └── wind-utils-gcc.sh
  ├── spack
  └── source
      ├── amr-wind
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
  central installations of ExaWind that are maintained by the ExaWind team. To
  determine whether you need this directory please refer :ref:`how_to_use`
  section.

- ``spack``: Optional location for Spack if using Spack to manage dependencies.
  Like exawind-builder, this directory is not necessary if you are on a system
  where ExaWind suite is maintained by the ExaWind team.

- ``source``: Local git repository checkouts of the ExaWind codes of interest to
  the user. This is the recommended location for all the development versions of
  the various codes (e.g., nalu-wind, openfast, etc.).

- ``scripts``: On an existing exawind-builder installation, this directory
  contains the *driver* scripts that user will use on a daily basis. This
  directory contains two types of scripts:

  - *Build scripts* that are used to configure and compile local git checkouts
    of :ref:`ExaWind codes <exawind_codes>` that are checked out in the
    ``source`` directory. These scripts have a naming convention
    ``project-compiler.sh`` (in scripts
    ``${EXAWIND_CODE}-${EXAWIND_COMPILER}.sh``). For example, the build script
    that is used to compile hypre using GCC compiler suite is named
    ``hypre-gcc.sh``. Similarly the script that is used to compile `nalu-wind``
    using ``LLVM/Clang`` suite is named ``nalu-wind-clang.sh``.

  - *Environment scripts* that can be *sourced* to load all the necessary
    modules and update user paths to run the codes. These scripts are useful
    during interactive sessions or to source within job submission scripts.
    These scripts are named ``exawind-env-${EXAWIND_COMPILER}.sh``. For example,
    to source the environment that was used to build the code using GCC compiler
    suite, the user would add

    .. code-block:: bash

       source ${EXAWIND_POJECT_DIR}/scripts/exawind-env-gcc.sh

- ``install``: The default install location where ``make install`` will install
  the headers, libraries, and executables.

The ExaWind project directory also contains several *configuration files* that
are used to customize the behavior on different systems and different execution
types, e.g., compiling and executing codes on host using Intel compiler vs.
compiling and executing codes on GPUs using GCC as host compiler and NVIDIA CUDA
to compile device code.


.. _how_to_use:

How to use ExaWind builder?
---------------------------

Depending on the system on which you intend to use ExaWind software, there are
two options for using exawind-builder.

#. If the desired system is one that is currently actively used by the ExaWind
   software team, then exawind-builder, as well as all necessary third-party
   libraries (TPLs), are already installe and configured on the system.
   Therefore, installation step is not required. Users can proceed directly to
   cloning and building the desired codes.

   Currently, ExaWind simulation environment, along with exawind-builder, is
   pre-installed and available on the following systems:

   - OLCF Summit
   - NREL Eagle
   - NERSC Cori

   If you are on of the systems listed above, please proceed to :ref:`basic_usage`
   section to learn how to use pre-built codes, or to build your own versions of
   the ExaWind codes using the TPLs pre-built by the ExaWind team.

#. If your system is not listed above, then you should first follow
   :ref:`installation instructions <installation>` and on successfull installation
   proceed to :ref:`basic_usage`.
