.. _usage-quickref:

ExaWind-builder -- Quick reference
==================================

Activating ExaWind environment
------------------------------

.. code-block:: bash

   # Adjust variables appropriately
   export EXWDIR=/projects/exawind
   export COMPILER=gcc

   # Source environment in an interactive shell or within a job submission script
   ${EXWDIR}/scripts/exawind-env-${COMPILER}.sh

   # Activate additional modules (e.g., netcdf to use ncdump command)
   exawind_load_deps netcdf-c
   # Check whether ncdump is available
   which ncdump

   # Purge all exawind variables/functions from environment
   exawind_purge_env

Please refer to :ref:`tut-exawind-env` and :ref:`build-custom` for more details.

Compiling codes
---------------

On systems where ExaWind software stack has been pre-installed and maintained by
the ExaWind team, you can execute the following commands to quickly build code.

.. code-block:: bash

   # Adjust variables appropriately
   export EXWDIR=/projects/exawind
   export CODE=nalu-wind
   export COMPILER=gcc

   #### One-time setup
   mkdir -p ${HOME}/exawind/source
   cd ${HOME}/exawind/source
   git clone --recurse-submodules https://github.com/exawind/${CODE}.git
   cd ${CODE}
   mkdir build-${COMPILER}
   ln -s ${EXWDIR}/scripts/${CODE}-${COMPILER}.sh

   #### Build executables
   # Option 1 - Execute both configure and make steps
   cd ${HOME}/exawind/source/${CODE}/build-${COMPILER}
   ./${CODE}-${COMPILER}.sh

   # Option 2 - Execute steps sequentially with arguments
   cd ${HOME}/exawind/source/${CODE}/build-${COMPILER}
   ./${CODE}-${COMPILER}.sh cmake -DENABLE_TESTS=OFF
   ./${CODE}-${COMPILER}.sh make -j 12

   # Option 3 - Force full reconfigure
   cd ${HOME}/exawind/source/${CODE}/build-${COMPILER}
   ./${CODE}-${COMPILER} cmake_full -DENABLE_TESTS=ON
   ./${CODE}-${COMPILER}.sh make

Detailed documentation sections:

- :ref:`tut-basic-compilation`
- :ref:`tut-build-script-tasks`
- :ref:`build-custom`

.. _basic_usage:

Basic usage
=======================================

This section describes the basic steps to configure exawind-builder and use the
scripts provided to build software used within the ExaWind project. We begin
with the simplest example, building one of the ExaWind codes on a system with
pre-installed dependencies, and then proceed with more complex workflows. These
examples assume that the ExaWind simulation environment has been previously
installed on the system you are working on. To determine if a previous
installation exists or if you need to install one yourself please refer to
:ref:`how_to_use`. To install exawind-builder and dependencies please refer to
:ref:`installation guide <installation>`.

.. _tut-basic-compilation:

Compiling executables using build scripts
-----------------------------------------

This tutorial describes the steps involved in biulding your own executable of
`Nalu-Wind <https://github.com/exawind/nalu-wind>`__ using exawind-builder
scripts. You can replace ``nalu-wind`` with any of the other codes in
:ref:`exawind_codes` and follow the same steps to build code. Tutorials on
complex workflows will refer back to this tutorial. This tutorial will assume
that the path to the pre-installed exawind project directory is
:file:`/projects/exawind/`.

One time setup
~~~~~~~~~~~~~~~~

Assuming you have not setup your own local :ref:`directory structure
<exawind_dir_layout>` before, we will create a working setup that will be used
to do development builds.

#. Create exawind directory layout

   .. code-block:: bash

      # Path to exawind installation
      export EXAWIND_DIR=/projects/exawind

      # Choose directory where you want to work on exawind codes
      export MY_EXAWIND_DIR=${HOME}/exawind

      # Create directory structure if you haven't done this previously
      mkdir -p ${HOME}/exawind/source

   .. note::

      If you installed your own exawind (see :ref:`installation`) and are not
      using a central installation, then ``${EXAWIND_DIR}`` and
      ``${MY_EXAWIND_DIR}`` would point to the same location and you can skip
      this step.

#. Clone desired code repository if you do not have a previously checked out
   version. In this example, we will use nalu-wind. Please replace ``nalu-wind``
   with your desired code, e.g., ``amr-wind`` in the following steps.

   .. code-block:: bash

      # Switch to source directory
      cd ${MY_EXAWIND_DIR}/source

      # Clone the repository
      git clone --recurse-submodules https://github.com/exawind/nalu-wind.git

      # Switch to a different branch if necessary

#. Create build directory and link build script. In this tutorial, we will use
   the ``gcc`` compiler. Replace ``gcc`` with ``clang`` or ``intel`` to switch
   compiler.

   .. code-block:: bash

      # Switch to previously cloned nalu-wind repository
      cd ${MY_EXAWIND_DIR}/source/nalu-wind

      # Create a build directory if one doesn't exist
      mkdir build-gcc
      cd build-gcc

      # Create a symbolic link to the build script within the build directory
      ln -s /projects/exawind/scripts/nalu-wind-gcc.sh

.. note::

   In this tutorial we assume that the path to the exawind project maintained by
   ExaWind team is :file:`/projects/exawind/`. Please change this appropriately
   based on your system.

Configuring and compiling software
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

After following the one-time setup steps described above, you can modify the
your local copy and compile code using the process described below.

To build code, simply execute the following command

.. code-block:: bash

   # Switch to build directory if necessary (refer to one-time steps for details)
   cd ${MY_EXAWIND_DIR}/source/nalu-wind/build-gcc

   # Execute script to compile nalu-wind
   ./nalu-wind-gcc.sh

When invoked without any arguments, the script will first execute ``cmake`` with
appropriate arguments to configure the project and then call ``make`` to compile
the project. On successful compilation, you will have executables in the build
directory.

.. _build-output:

Understanding exawind-builder output
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When an exawind-builder script is executed, e.g., as described in previous
section, it will output lots of informational messages to the screen. Under most
situations, the build process would just work and you can ignore the output.
However, in some circumstances, you might encounter errors. This section briefly
describes the output from build script that can be used to troubleshoot the
error, or submit bug reports to relevant ExaWind projects.

When you execute a build script (e.g., :program:`./nalu-wind-gcc.sh`) you will
see output as shown below. Note that the paths will be different depending on
your system and directory layout.

::

  ==> Loading options from /projects/exawind/exawind/exawind-config-gcc.sh
  ==> Using spack configuration: /projects/exawind/exawind/spack
  ==> spack: locating mpi%gcc
  ==> mpi = /projects/exawind/exawind/spack/opt/spack/linux-centos7-skylake/gcc-8.4.0/mpich-3.3.1-dn34cqtj7tlnxzwamooud6rxbdbkro42
  ==> spack: locating cmake%gcc
  ==> cmake = /usr/local
  ==> spack: locating netlib-lapack%gcc
  ==> netlib-lapack = /projects/exawind/exawind/spack/opt/spack/linux-centos7-skylake/gcc-8.4.0/netlib-lapack-3.8.0-bmrqbsbwfqaqkjipdhbbm6t4eewxkvr4
  ==> No user environment actions defined
  ==> Loading dependencies for nalu-wind...
  ==> trilinos = /projects/exawind/exawind/install/gcc/trilinos
  ==> spack: locating yaml-cpp%gcc
  ==> yaml-cpp = /projects/exawind/exawind/spack/opt/spack/linux-centos7-skylake/gcc-8.4.0/yaml-cpp-0.6.2-k3me2qqeadfw3jzvgwkiagn3hhw23ekv
  ==> spack: locating boost%gcc
  ==> boost = /projects/exawind/exawind/spack/opt/spack/linux-centos7-skylake/gcc-8.4.0/boost-1.68.0-ttkfazswxptatzfrohvpn7pjoz5ggqx6
  ==> spack: locating hypre%gcc
  ==> hypre = /projects/exawind/exawind/spack/opt/spack/linux-centos7-skylake/gcc-8.4.0/hypre-develop-crw7bxgflmfwoxkv52qqe5tulzqjvnwx
  ==> tioga = /projects/exawind/exawind/install/gcc/tioga

The messages with the ``==>`` prefix are output from exawind-builder. These
messages show the configuration files that are being loaded followed by the
paths to the required dependencies that are loaded to enable configuring and
building nalu-wind. The output from CMake configure process is simultaneously
shown on screen as well as redirected to :file:`cmake_output.log`. Similarly,
the output from ``make`` step is shown on screen as well as saved to file
:file:`make_output.log`. Outputs stored in :file:`make_output.log` is useful
when troubleshooting errors in parallel builds as it captures all messages.

.. _tut-exawind-env:

Running ExaWind executables
--------------------------------------

Exawind-builder provides scripts that can be sourced to create appropriate
execution environments for the codes either in an interactive console or within
job submission scripts. These scripts recreate the exact environment that was
used to build the codes. The environment scripts are stored in within the
``scripts`` directory (see :ref:`exawind_dir_layout` for more details) and are
of the form :file:`exawind-env-${COMPILER}.sh`. In the following examples,
replace :file:`/projects/exawind` with the correct exawind installation path.

.. code-block:: bash

   # Load the environment corresponding to GCC compiler suite
   source /projects/exawind/scripts/exawind-env-gcc.sh

In addition to loading the default modules, sourcing this file will also
introduce a bash command ``exawind_load_deps`` that can be used to load
additional codes within the bash environment.

.. code-block:: bash

   exawind_load_deps nalu-wind amr-wind trilinos wind-utils
   nalu_wind_exe=${NALU_WIND_ROOT_DIR}/bin/naluX
   amr_wind_exe=${AMR_WIND_ROOT_DIR}/bin/amr_wind
   epu_exe=${TRILINOS_ROOT_DIR}/bin/epu

   # Generate an ABL mesh using wind utilities executable
   ${EXAWIND_INSTALL_DIR}/wind-utils/bin/abl_mesh -i abl_mesh.yaml

For example, to access ``ncdump`` available in the ``netcdf`` module on any
system, the user can execute the following

.. code-block:: bash

   # Activate exawind environment
   source /projects/exawind/scripts/exawind-env-gcc.sh
   # load the NetCDF module or spack build
   exawind_load_deps netcdf

   # Now ncdump should be available in your PATH
   ncdump -h <exodus_file>

Within interactive sessions, you can *deactivate* the exawind environment that
was created by sourcing the environment file by executing ``exawind_purge_env``
command.

.. code-block:: bash

   # Deactivate exawind environment
   exawind_purge_env

.. warning::

   Note that it is not necessary to source the environment for building
   software. The build scripts will automatically source the environment. We
   strongly discourage sourcing exawind environment within ``.bash_profile`` and
   ``.bashrc`` scripts. Loading default environment will not allow you to switch
   compilers or change build options to support different types of builds (e.g.,
   using a different hypre library to link against your nalu-wind build).

To ease the process of quickly activating the user environment, we recommend
using functions within your ``.bashrc`` scripts. An example is shown below:

.. code-block:: bash

   # Helper function to load exawind environment in a bash shell
   # Execute `load_exawind_env intel` at prompt to load intel environment
   function load_exawind_env {
       # Absolute path to exawind project directory
       local exawind_project_dir=/projects/exawind

       # Parse argument to determine compiler type, default is gcc if none provided
       local compiler_type=${1:-gcc}

       source ${exawind_project_dir}/scripts/exawind-env-${compiler_type}.sh
   }

Example job submission script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This section shows an example of using the newly built executables within a job
script. The example assumes SLURM job manager.

.. code-block:: bash

   #!/bin/bash

   # Example job submission script
   #SBATCH --job-name=nalu-wind-exe
   #SBATCH --account=exawind
   #SBATCH --nodes=30
   #SBATCH --time=48:00:00
   #SBATCH --output=out.%x_%j

   # Path to exawind installation
   exawind_dir=/projects/exawind
   # Compiler build used
   compiler=gcc
   # Nalu-Wind exe location
   nalu_dir=${HOME}/exawind/source/nalu-wind/build-${compiler}
   nalu_exec=${nalu_dir}/naluX

   # Input and log files (assume current working directory)
   input_file=abl_neutral.yaml
   log_file=abl_neutral.log

   # Copy the exawind-config if present so that we recreate the exact environment
   if [ -f ${nalu_dir}/exawind-config.sh ] ; then
     cp ${nalu_dir}/exawind-config.sh .
   fi
   # Purge all modules to ensure a clean environment
   module purge
   # Source exawind environment
   source ${HOME}/exawind/scripts/exawind-env-gcc.sh

   ranks_per_node=36
   mpi_ranks=$(expr $SLURM_JOB_NUM_NODES \* $ranks_per_node)
   export OMP_NUM_THREADS=1  # Max hardware threads = 4
   export OMP_PLACES=threads
   export OMP_PROC_BIND=spread


   echo "Job name       = $SLURM_JOB_NAME"
   echo "Num. nodes     = $SLURM_JOB_NUM_NODES"
   echo "Num. MPI Ranks = $mpi_ranks"
   echo "Num. threads   = $OMP_NUM_THREADS"
   echo "Working dir    = $PWD"

   srun -n ${mpi_ranks} -c 1 --cpu-bind=cores ${nalu_exec} -i ${input_file} -o ${log_file}

.. _tut-build-script-tasks:

Specifying tasks with build scripts
-------------------------------------------------

Often during code, commit, build, debug cycle, it is necessary to control the
steps executed using the build scripts. For example, after fixing minor typos,
it is not necessary to execute the CMake configure step and only ``make`` needs
to be executed. Similarly, after changes to CMake configuration files, it might
be desirable to purge the CMake cache and execute a fresh configure. Finally,
the user might want to run the unit/regression tests and or execute the
executable in the same environment that was used to build the code.
Exawind-builder scripts take additional arguments that can be used to control
the tasks executed as show below.

.. code-block:: bash

   ./nalu-wind-gcc.sh [TASK] [ARGUMENTS]

You can use the ``-h`` flag to request a brief help message as shown below

::

  Exawind build script

  Usage:
      ./nalu-wind-gcc.sh <task> <arguments>

  With no tasks provided, the script will configure the project and compile the code

  Available tasks:
      cmake       - configure the project
      cmake_full  - configure project after removing CMakeCache
      make        - compile the code
      ctest       - run tests (if available)
      run         - run arbitrary command using the environment used to compile the code


The available **tasks** are:

- ``cmake``: Configure the project using CMake and generate build files.
  Exawind-builder can generate both GNU Makefiles as well as Ninja build
  scripts. This capability is controlled by the variable
  :envvar:`EXAWIND_MAKE_TYPE`.

- ``cmake_full``: Remove :file:`CMakeCache.txt` and :file:`CMakeFiles` before
  executing CMake configuration step.

- ``make``: Build the project libraries and executables. Note that ``make`` is
  used regardless of whether GNU Makefile or Ninja build system is used.

- ``ctest``: Execute CTest for this project, if available.

- ``run``: Run arbitrary shell command within the same environment (modules and
  dependencies loaded) as when the project was compiled.


User can control the behavior of these
tasks by passing extra ``[ARGUMENTS]`` that are passed directly to the task
invoked. Some examples are shown below

.. code-block:: bash

   # Change CMake build type to DEBUG and turn on shared library build
   ./nalu-wind-gcc.sh cmake -DCMAKE_BUILD_TYPE=DEBUG -DBUILD_SHARED_LIBS=ON

   # Turn on verbose output with make and only build naluX (and not unittestX)
   ./nalu-wind-gcc.sh make VERBOSE=1 naluX

   # Only execute one regression test and enable output on failure
   ./nalu-wind-gcc.sh ctest --output-on-failure -R ablNeutralEdge

   # Run the unit test executable from within exawind environment
   ./nalu-wind-gcc.sh run ./unittestX


.. warning::

   Even though Makefiles are present in the build directory and can be invoked
   through ``make``, we recommend that you always execute the make step through
   the build script. This will avoid inconsistencies between the build and the
   configuration environment that could lead to build or runtime errors.

.. note::

   - Replace :program:`nalu-wind-gcc.sh` with :program:`amr-wind-gcc.sh` when
     working on AMR-Wind. Similarly use :program:`nalu-wind-intel.sh` when
     building with Intel compiler suite.

   - By default, ``make`` will execute several jobs in parallel. Users can
     control the maximum number of parallel jobs by either setting the
     environment variable :envvar:`EXAWIND_NUM_JOBS`, or
     using ``./nalu-wind-gcc.sh make -j 12`` to override the defaults.

   - ``cmake_full`` accepts all valid CMake arguments that ``cmake`` command does.

   - The :file:`cmake_output.log` within the build directory contains the output
     of the last `cmake` command that was executed. This output is also echoed
     to the screen.

   - The :file:`make_output.log` contains the output from the last invocation of
     ``make``. This output is also simultaneously echoed to the screen.


.. _build-custom:

Customizing exawind-builder
---------------------------

The previous section showed how the execution of CMake and Make can be
customized to a limited extent by passing command line arguments with specific
tasks. However, for more complex customizations it is recommended that the user
use the :ref:`configuration file <exawind_config>` to control the build process.
This approach allows the user to consolidate common build options, e.g.,
enabling/disabling OpenMP/CUDA, release/debug builds across all projects
consistently through the :file:`exawind-config.sh` and fine tuning options from
the config file within the current working directory. This will allow the user
to repeat the build process consistently during development and aid in debugging
when things don't work as expected. The various customizations possible are
described below. The code examples shown below must be added to
:file:`exawind-config.sh` within the current working directory (either the build
directory or the directory from which an HPC job is executed).

Customizing build options
~~~~~~~~~~~~~~~~~~~~~~~~~~~

See project-specific documentation in :ref:`reference` to see what variables can
be used to enable/disable various options for different projects.

.. code-block:: bash

   # Control accelerator device options
   ENABLE_OPENMP=OFF
   ENABLE_CUDA=ON
   ENABLE_HIP=OFF
   ENABLE_DPCPP=OFF

   # Set debug/release options
   BUILD_TYPE=RELEASE

   # Disable TIOGA and OpenFAST, but enable HYPRE as TPLs
   ENABLE_TIOGA=OFF
   ENABLE_OPENFAST=OFF
   ENABLE_HYPRE=ON

   # Switch build system
   EXAWIND_MAKE_TYPE=ninja # Valid options are auto, make, ninja

   # Set number of parallel jobs to execute during make step
   EXAWIND_NUM_JOBS=18

Customizing installation location
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, exawind-builder will setup ``CMAKE_INSTALL_PREFIX`` such that ``make
install`` step will install at
:file:`${EXAWIND_PROJECT_DIR}/${EXAWIND_EXEC_TARGET}/${EXAWIND_CODE}` directory.
If you have installed exawind-builder yourself and are not using a shared
installation you will not need to change this location. However, when using an
upstream exawind-builder you might not have write permissions to that
installation location. In this situation you can instruct exawind-builder to
choose a custom installation location for when executing ``make install``.

In this example we will assume that you are using an upstream exawind-builder
installation at :file:`/projects/exawind` and you are building your development
versions in :file:`${HOME}/exawind`. By default, :envvar:`EXAWIND_INSTALL_DIR`
will point to a directory within :envvar:`EXAWIND_PROJECT_DIR` (which in this
case is within :file:`/projects/exawind/`). To override this when building
trilinos, for example, you can use the variable `TRILINOS_INSTALL_PREFIX` to
provide the installation location. Next section shows how this installed
trilinos libraries can be used to link against codes that depend on trilinos.

.. code-block:: bash

   # Custom install location for trilinos with date timestamp
   export TRILINOS_INSTALL_PREFIX=${HOME}/exawind/install/gcc8-cuda10/trilinos-$(date %Y-%m-%d)

Customizing dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

During development, the user might desire to use a different branch of a
dependency than what the default system-wide installation provides. For example,
the user might want to use a different branch of OpenFAST when developing
advanced FSI capability within Nalu-Wind. The user can bypass the module
search/load process by defining :envvar:`ROOT_DIR <PROJECTNAME_ROOT_DIR>`
variable for the corresponding dependency. The following example shows how to
customize the TPLs used for building nalu-wind

.. code-block:: bash

   # Override TPLs used to build nalu-wind
   export OPENFAST_ROOT_DIR=${EXAWIND_INSTALL_DIR}/openfast-dbg
   export HYPRE_ROOT_DIR=${EXAWIND_INSTALL_DIR}/hypre-cuda

   # Example using trilinos from nightly-testing build
   export TRILINOS_ROOT_DIR=/projects/exawind-nightly-testing/install/trilinos

   # Example using trilinos from custom install location (see previous section)
   export TRILINOS_ROOT_DIR=${HOME}/exawind/install/gcc8-cuda10/trilinos-2020-10-08

.. tip::

   To specify the installation location use :envvar:`PROJECT_INSTALL_PREFIX` and
   to use an installed version of the code as a depencency in another project
   use :envvar:`PROJECTNAME_ROOT_DIR` variable.

Customizing build environment init process
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The builder provides two options that allows the user to further configure the
default environment that is enabled for a given system/compiler combination.

#. To load additional modules, the user can use
   :envvar:`EXAWIND_EXTRA_USER_MODULES` variable to provide the list of modules
   (in module or spack syntax as appropriate) and have them loaded after the
   base modules have been loaded.

   .. code-block:: bash

      # Example showing how to always load HDF5 and NetCDF modules
      EXAWIND_EXTRA_USER_MODULES=( hdf5 netcdf-c )

#. Fine-grained customization is achieved by defining by overriding the function
   :func:`exawind_env_user_actions` in the :file:`exawind-config.sh` configuration
   file.

   .. code-block:: bash

      # Load additional modules and print out some variables
      exawind_env_user_actions ()
      {
        # You can inject additional module paths
        module use /opt/hpc_system/modules

        # load additional modules
        module load paraview

        # manipulate environment variables seen by exawind-builder
        echo ${CXX}
        echo ${TRILINOS_ROOT_DIR}
      }

.. _cfg-module-load:

Customizing module load
~~~~~~~~~~~~~~~~~~~~~~~

exawind-builder provides a default list of modules on most systems that work for
most use cases. However, the user might desire to use different modules for
their custom builds. This is achieved by configuring the modules to be loaded in
the :envvar:`EXAWIND_MODMAP` variable. The following example shows how the user
might switch to a different versions of GCC, MPI, and CUDA modules for building code

.. code-block:: bash

   EXAWIND_MODMAP[gcc]=gcc/8.4.0
   EXAWIND_MODMAP[mpi]=mpich/3.3.1
   EXAWIND_MODMAP[cuda]=cuda/10.2.89

Similarly, `EXAWIND_MODMAP` can also be used to select from multiple versions of
software installed via spack. For example, if :envvar:`EXAWIND_DEP_LOADER` is
set to ``spack`` then you can provide custom versions to load

.. code-block:: bash

   EXAWIND_MODMAP[trilinos]=trilinos@2020-12-01 +cuda
   EXAWIND_MODMAP[hypre]=hypre@develop+mpi~int64+cuda+curand

.. warning::

   :envvar:`PROJECTNAME_ROOT_DIR` variables take precedence over modules/spack
   packages listed in :envvar:`EXAWIND_MODMAP`. You should verify that the right
   package is loaded. See :ref:`build-output` on more details on how to detect
   the packages that are used during the build process.

Swapping Spack installations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To aid testing/debugging, exawind-builder has the ability to switch to a
different spack installation, e.g., nightly-testing spack installation, using
the :envvar:`SPACK_ROOT` variable.

.. code-block:: bash

   # Switch spack installation to the one used for nightly-testing
   SPACK_ROOT=/projects/exawind/nightly-testing/spack

   # (Optional) customize spack packages in case there are multiple versions
   EXAWIND_MODMAP[trilinos]=trilinos@develop%gcc@7.4.0 +cuda+cuda_rdc+wrapper
   EXAWIND_MODMAP[hypre]=hypre@develop%gcc@7.4.0

.. note::

   When using a different spack installation, you should not attempt to link to
   codes built against the old spack install that are in
   :envvar:`EXAWIND_INSTALL_DIR`. You should unset all
   :envvar:`PROJECTNAME_ROOT_DIR` and use packages from spack install, or
   rebuild new versions of the packages.

Customizing CMake configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Previously command line arguments were provided to ``cmake`` task to customize
the CMake configuration step. While that is suitable for one off modifications,
a more robust way to customize the configuration step is to provide a custom
CMake function from within the ``exawind-config.sh`` script. The following
example shows a real-world use case to pass ``jsrun`` arguments to CTest when
executing regression tests on ORNL Summit system.

.. code-block:: bash

   # Customize CMake behavior by permanently passing extra arguments
   function exawind_cmake {
       # Still allow user to pass arguments through command line
       local extra_args="$@"
       # Pass GPU arguments to CUDA-aware MPI
       local jsrun_args=$'--smpiargs=\x22-gpu\x22'

       exawind_cmake_base \
           -DMPIEXEC_EXECUTABLE='"$(which jsrun) ${jsrun_args}"' \
           -DMPIEXEC_NUMPROC_FLAG="-n" \
           -DMPIEXEC_PREFLAGS='"-a 1 -c 1 -g 1"' \
           ${extra_args}
   }

.. _exawind_config:

Exawind-builder configuration files
-----------------------------------

During execution, exawind-builder reads configuration from various files that
provide fine-grained control of the build process. The default name for the
configuration file is ``exawind-config``, but this can be configured by
modifying the :envvar:`EXAWIND_CFGFILE` variable. exawind-builder will load the
following files in the specified order

.. code-block:: bash

   ${EXAWIND_PROJECT_DIR}/exawind-config-${EXAWIND_SYSTEM}      # Common system settings
   ${EXAWIND_PROJECT_DIR}/exawind-config-${EXAWIND_EXEC_TARGET} # Execution target settings
   ${EXAWIND_CONFIG}                                            # File pointed to by the variable
   $(pwd)/exawind-config.sh                                     # File in the local working directory

The configuration variables in the subsequent files will override the default
values as well as configuration variables set in the previous files. Please
replace the path appropriately (:envvar:`EXAWIND_PROJECT_DIR`), if you used a
non-standard location for installation. See also :envvar:`EXAWIND_CONFIG`.

On systems with a shared installation of exawind-builder, please look at the
``exawind-config-*.sh`` files within :envvar:`EXAWIND_PROJECT_DIR`. The
:envvar:`EXAWIND_EXEC_TARGET` is typically just the compiler name, e.g.,
``gcc``. For CUDA builds, it is either ``cuda`` or ``gcc9-cuda11``.

.. note::

   #. It is recommended that the user use local configuration files within build
      directories to set variables instead of modifying the build scripts within
      the `exawind/scripts` directory.

   #. If you are using a shared instance of exawind-builder (e.g., on NREL),
      then please use :file:`exawind-config.sh` within your build directory to
      override common configuration parameters.


Tutorial: Custom build of Trilinos and Nalu-Wind
------------------------------------------------

This tutorial presents a complete walkthrough of the steps involved in building
custom versions of trilinos and nalu-wind to target execution on NVIDIA GPUs. We
will assume that the default system build targets host and doesn't activate CUDA
support by default. In this tutorial we will activate CUDA within the
exawind-builder environment, compile Trilinos first with CUDA support, and then
build nalu-wind to link to this custom trilinos build.

**Create ``exawind-config.sh``**

#. (Option 1 -- the quick way): You can use this method on systems where Exawind
   team has already created the necessary configuration for CUDA builds.

   .. code-block:: bash

      # Set the exawind build target type
      EXAWIND_EXEC_TARGET=gcc8-cuda10

      # Install path for trilinos
      TRILINOS_INSTALL_PREFIX=${MY_EXAWIND_DIR}/install/gcc8-cuda10

      # Trilinos lookup path for building Nalu-Wind
      TRILINOS_ROOT_DIR=${TRILINOS_INSTALL_PREFIX}

   See :envvar:`EXAWIND_PROJECT_DIR` to see the available configurations.

#. (Option 2 -- the hard way): Provides more control

   .. code-block:: bash

      ENABLE_CUDA=ON
      EXAWIND_MODMAP[gcc]=gcc/8.4.0
      EXAWIND_MODMAP[cuda]=cuda/10.2.89

      # Install path for trilinos
      TRILINOS_INSTALL_PREFIX=${MY_EXAWIND_DIR}/install/gcc8-cuda10/trilinos-2020-10-08

      # Trilinos lookup path for building Nalu-Wind
      TRILINOS_ROOT_DIR=${TRILINOS_INSTALL_PREFIX}

Build Trilinos
~~~~~~~~~~~~~~

#. Build and install trilinos (see :ref:`tut-basic-compilation` for more details)

   .. code-block:: bash

      cd ${MY_EXAWIND_DIR}/source/trilinos/
      mkdir build-gcc8-cuda10
      cd build-gcc8-cuda10

      # Copy exawind-config file
      cp ${HOME}/exawind-config.sh .

      # link build script
      ln -s ${EXAWIND_PROJECT_DIR}/scripts/trilinos-gcc.sh

      # Configure and build
      ./trilinos-gcc.sh
      # Install to destination directory
      ./trilinos-gcc.sh make install

If CUDA support was activated, the scripts will print out message similar to
what is shown below. You can also look at :file:`cmake_output.log` to make sure
that Trilinos/Kokkos CUDA support was activated.

::

  ==> cuda/10.2.89 = /nopt/nrel/ecom/hpacf/compilers/2020-07/spack/opt/spack/linux-centos7-skylake_avx512/gcc-8.4.0/cuda-10.2.89-rmccd4tpc5gxbbrjeeohphuuujb4cz2o
  ==> Activated Eagle CUDA programming environment

Build Nalu-Wind
~~~~~~~~~~~~~~~

#. Build nalu-wind (see :ref:`tut-basic-compilation` for more details)

   .. code-block:: bash

      cd ${MY_EXAWIND_DIR}/source/nalu-wind/
      mkdir build-gcc8-cuda10
      cd build-gcc8-cuda10

      # Copy exawind-config file
      cp ${HOME}/exawind-config.sh .

      # link build script
      ln -s ${EXAWIND_PROJECT_DIR}/scripts/nalu-wind-gcc.sh

      # Configure and build
      ./nalu-wind-gcc.sh
      # Install to destination directory
      ./nalu-wind-gcc.sh make install

The script should output the expected path of the tilinos build that is being used

::

  ==> trilinos = ${HOME}/install/gcc8-cuda10/trilinos-2020-10-08


..
  Overriding default behavior
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~

  In rare circumstances, it will be necessary for the user to create a copy of the
  build script and edit it manually to customize the build. A build script with
  default parameters is shown below:

  .. literalinclude:: files/trilinos-gcc.sh
     :language: bash
     :linenos:

  The struture of the build script is the same regardless of the machine,
  compiler, or the project that is being built. Lines 14-36 setup the variables
  and functions necessary to detect dependencies and build the software, please do
  not edit these lines unless you know what you are doing. Lines 45-49 should not
  be modified either, and must always be the end of the script. Lines added to the
  script after this section will not affect the configure and build process. User
  specific configuration and customization should occur within the block indicated
  by lines 40-42. User might want to configure the
  :envvar:`PROJECTNAME_INSTALL_PREFIX` (line 38) when building different
  configurations (e.g., release/debug versions, with and without OpenMP, etc.) so
  as to have different builds side by side. It is, however, recommended that the
  user customize this variable in the :file:`exawind-config.sh` local to the build
  directory.

  A good example of what should go in the build script and not the configuration
  file is described in the next section. Since bash functions are often project
  specific they should be overridden in the build script and not the configuration
  file.

  Customizing CMake configuration phase
  `````````````````````````````````````

  To always pass certain variables, the user can customize the ``exawind_cmake``
  function with their own version that adds the extra options permanently every
  time ``cmake`` is executed. For example, to build ``nalu-wind`` with ParaView
  Catalyst support:

  .. code-block:: bash

     ########## BEGIN user specific configuration ###########

     # Customize cmake with extra arguments
     exawind_cmake ()
     {
         local extra_args="$@"

         exawind_cmake_base \
             -DENABLE_PARAVIEW_CATALYST:BOOL=ON \
             -DPARAVIEW_CATALYST_INSTALL_PATH:PATH=${PV_CATALYST_PATH} \
             ${extra_args}
     }

     ########## END user specific configuration   ###########

  With the above changes, ParaView Catalyst support will always be enabled during
  builds. The user still has the option to pass additional parameters through the
  command line also for a one-off customization.

..
  Compiling Software
  ------------------

  If you followed the *bootstrap* method described in :ref:`installation`, then
  you should have build scripts for the different projects installed in
  :file:`exawind/scripts` directory. The scripts are named
  ``$PROJECT-$COMPILER.sh``. For example, the build script for ``nalu-wind``
  project on a system using GCC compiler suite will be called
  :file:`nalu-wind-gcc.sh`. With no arguments provided, the script will load all
  necessary modules for compiling the code, execute CMake configuration step
  followed by ``make``.

  Compiling software, therefore, consists of the following steps (see detailed
  examples of trilinos and nalu-wind in the code snippets below that demonstrate
  these steps):

  #. Clone the appropriate software repository into :file:`exawind/source`
     directory, e.g., ``nalu-wind``. See note below on ``trilinos`` status for
     certain systems.

  #. Create a CMake build directory. We recommend out-of-source builds for all software.

  #. Create a symbolic link to the apporpriate build script from
     :file:`exawind/scripts` directory.

  #. Create :file:`exawind/source/$project/build/exawind-config.sh`, if necessary,
     and set custom variables for this build. Examples include switching to debug
     builds, or using different version of dependencies. If the configuration is
     applicable to multiple codes that you are building, then consolidate the
     common options in :file:`exawind/exawind-config.sh` to avoid duplication.

  #. Add an entry in :ref:`configuration file <exawind_config>` to override the
     default version of software with your custom build version when compiling
     other software, e.g., overriding the default version of HYPRE or OpenFAST --
     see :envvar:`PROJECTNAME_ROOT_DIR` for more details.

  #. Execute the build script (assuming you've all prerequisites, see note on
     Trilinos below).


  .. note::

     On most systems, users will have to install Trilinos and Nalu-Wind manually.
     For these systems, users must install Trilinos before attempting to build
     ``nalu-wind`` and set :envvar:`TRILINOS_ROOT_DIR <PROJECTNAME_ROOT_DIR>` in
     their :ref:`configuration file <exawind_config>`. Exceptions to this
     requirement are NREL Peregrine, Eagle, and Rhodes systems where Trilinos is
     installed and maintained by the ExaWind team (Jon Rood).

  For convenience, the list of commands necesssary to compile trilinos and
  nalu-wind are provided below.

  .. code-block:: bash

     # Preliminary setup
     # Adjust these variables apporpriately
     export EXAWIND_PROJECT_DIR=${HOME}/exawind/
     export COMPILER=gcc

     #
     # Build trilinos first (if necessary)
     #
     # Clone trilinos
     cd ${EXAWIND_PROJECT_DIR}/source
     # Clone the repo
     git clone https://github.com/trilinos/trilinos.git
     # Create a build directory
     mkdir trilinos/build-${COMPILER}
     # Switch to build directory
     cd trilinos/build-${COMPILER}
     # link the build script (change gcc appropriately)
     ln -s ${EXAWIND_PROJECT_DIR}/scripts/trilinos-${COMPILER}.sh
     # Execute the script
     ./trilinos-${COMPILER}.sh
     # Install on successful build
     ./trilinos-${COMPILER}.sh make install
     # Instruct nalu-wind to use the new Trilinos location
     echo 'export TRILINOS_ROOT_DIR=${EXAWIND_INSTALL_DIR}/trilinos' >> ${EXAWIND_PROJECT_DIR}/exawind-config.sh

     #
     # Build nalu-wind
     #
     # Clone nalu-wind
     cd ${EXAWIND_PROJECT_DIR}/source
     git clone https://github.com/exawind/nalu-wind.git
     # Create a build directory
     mkdir nalu-wind/build-${COMPILER}
     # Switch to build directory
     cd nalu-wind/build-${COMPILER}
     # link the build script (change gcc appropriately)
     ln -s ${EXAWIND_PROJECT_DIR}/scripts/nalu-wind-${COMPILER}.sh
     # Execute the script
     ./nalu-wind-${COMPILER}.sh
     # Install on successful build
     ./nalu-wind-${COMPILER}.sh make install

