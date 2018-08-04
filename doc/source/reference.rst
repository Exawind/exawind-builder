.. _reference:

Reference
=========

This section documents all the available options that the user can use to
customize the build process. It is divided into common options (most begin with
``EXAWIND_`` prefix) and code-specific parameters under individual projects.

ExaWind Builder configuration
-----------------------------

.. envvar:: EXAWIND_SYSTEM

   The system code used to determine modules to be loaded. The available systems are

   ============== ============================================================================================
   ``spack``       `Spack <https:://github.com/LLNL/spack>`_ (system agnostic)
   ``peregrine``   `NREL Peregrine <https://www.nrel.gov/hpc/peregrine-system.html>`_
   ``cori``        `NERSC Cori <http://www.nersc.gov/users/computational-systems/cori/>`_
   ``summitdev``   `OLCF SummitDev <https://www.olcf.ornl.gov/olcf-resources/compute-systems/summit/>`_
   ============== ============================================================================================


.. envvar:: EXAWIND_COMPILER

   The compiler to be used for the build. Valid options are `gcc`, `clang`,
   `intel`, and `xl`. Not all compiler options are available on all systems.

.. envvar:: EXAWIND_PROJECT_DIR

   The root directory where all ExaWind code is located. In the
   :ref:`introduction` section the examples used :file:`${HOME}/exawind`.

.. envvar:: EXAWIND_INSTALL_DIR

   The default location where custom builds are installed. Each project is
   installed within its own directory
   (:file:`${EXAWIND_INSTALL_DIR}/${PROJECT_NAME}`).

.. note::

   The variables described above are set when :ref:`generating build scripts
   <new-script>` and rarely needs to be changed by the user.

.. envvar:: EXAWIND_MODMAP

   A dictionary containing the exact resolution of the module that must be
   loaded. For example, on NREL Peregrine the builder will load
   ``trilinos/develop`` module by default. However, if the user prefers the
   ``develop`` branch with OpenMP enabled, then they can override it by
   providing the following either in the build script or the
   :file:`exawind-config.sh` configuration file.

   .. code-block:: bash

      # Use develop branch of trilinos that has OpenMP enabled
      EXAWIND_MODMAP[trilinos]=trilinos/develop-omp

   For system configuration using Spack, the compiler flag (e.g., ``%gcc``) is
   automatically added to the spec.

.. envvar:: EXAWIND_NUM_JOBS

   The maximum number of parallel build jobs to execute when ``make`` is
   invoked. Setting this variable within the build script is equivalent to
   passing ``-j X`` at the command line for ``make``.


Variables controlling project properties
----------------------------------------

These variables all start with the project name. The convention is that
the project name is converted to all upper case and any dashes are replaced by
underscores. For example, ``parallel-netcdf`` becomes
``PARALLEL_NETCDF_ROOT_DIR``, SuperLU becomes ``SUPERLU_ROOT_DIR`` and so on.

.. envvar:: PROJECTNAME_ROOT_DIR

   The use can declare a variable (e.g., ``OPENFAST_ROOT_DIR``) to provide a
   path to a custom installation of a particular dependency and bypass the
   module search and load process. A typical example is to provide the following
   line either in the build script or the :file:`exawind-config.sh`
   configuration file.

   .. code-block:: bash

      export OPENFAST_ROOT_DIR=${EXAWIND_INSTALL_DIR}/openfast-dev-debug

   The primary purpose of this variable is to indicate pass this as a parameter
   during the build process of other projects.

   Currently the following ``ROOT_DIR`` variables are used within the scripts::

     BOOST_ROOT_DIR
     HDF5_ROOT_DIR
     HYPRE_ROOT_DIR
     NALU_WIND_ROOT_DIR
     NETCDF_ROOT_DIR
     OPENFAST_ROOT_DIR
     PARALLEL_NETCDF_ROOT_DIR
     SUPERLU_ROOT_DIR
     TIOGA_ROOT_DIR
     TRILINOS_ROOT_DIR
     YAML_CPP_ROOT_DIR
     ZLIB_ROOT_DIR

.. envvar:: PROJECTNAME_INSTALL_DIR

   The location where ``make install`` will install the project. The default
   value for this variable is ``${EXAWIND_INSTALL_DIR}/${PROJECT_NAME}``

.. envvar:: PROJECTNAME_SOURCE_DIR

   This variable is used in situations where the ``build`` directory is not a
   subdirectory located at the root of the project source directory. The default
   value is just the parent directory from where the script is executed.

Variables controlling build process
-----------------------------------

This section describes various environment variables that control the build
process for individual projects.

Common build variables
~~~~~~~~~~~~~~~~~~~~~~

.. envvar:: BUILD_TYPE

   Control the type of build, e.g., Release, Debug, RelWithDebInfo, etc.

.. envvar:: BUILD_SHARED_LIBS

   Control whether shared libraries or static libraries are built. Valid values:
   ``ON`` or ``OFF``.

.. envvar:: BLASLIB

   Path to BLAS/LAPACK libraries.

.. envvar:: ENABLE_OPENMP

   Boolean flag indicating whether OpenMP is enabled. (default: ON)

Nalu-Wind
~~~~~~~~~

.. envvar:: ENABLE_OPENFAST

   Boolean flag indicating whether OPENFAST TPL is activated when building
   Nalu-Wind. (default: ON)

.. envvar:: ENABLE_HYPRE

   Boolean flag indicating whether HYPRE TPL is activated when building
   Nalu-Wind. (default: ON)

.. envvar:: ENABLE_TIOGA

   Boolean flag indicating whether TIOGA TPL is activated when building
   Nalu-Wind. (default: ON)

.. envvar:: ENABLE_TESTS

   Boolean flag indicating whether tests are enabled when building Nalu-Wind.
   (default: ON)

OpenFAST
~~~~~~~~

.. envvar:: FAST_CPP_API

   Boolean flag indicating whether the C++ API is enabled. (default: ON)

Other variables used: :envvar:`BUILD_SHARED_LIBS`, :envvar:`BUILD_TYPE`, and
:envvar:`BLASLIB`.

Trilinos
~~~~~~~~

Trilinos uses :envvar:`ENABLE_OPENMP` and :envvar:`BLASLIB` if configured.
OpenMP is enabled by default, and CMake attempts to automatically detect
BLAS/LAPACK.


HYPRE
~~~~~

HYPRE uses :envvar:`ENABLE_OPENMP` if configured. OpenMP is disabled by default
for HYPRE builds.

.. envvar:: ENABLE_BIGINT

   Boolean flag indicating whether 64-bit integer support is enabled. (default: ON)
