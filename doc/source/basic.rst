.. _basic_usage:

Using exawind-builder to build software
=======================================

This section describes the basic steps to configure exawind-builder and use the
scripts provided to build software used within the ExaWind project.

.. _exawind_config:

Configuring exawind-builder
---------------------------

During execution, exawind-builder reads user configuration from various files
that provide fine-grained control of the build process. The default name for the
configuration file is ``exawind-config``, but this can be configured by
modifying the :envvar:`EXAWIND_CFGFILE` variable. exawind-builder will load the
following files in the specified order

.. code-block:: bash

   ${HOME}/.exawind-config   # User configuration file
   ${EXAWIND_CONFIG}         # File pointed to by the variable ${EXAWIND_CONFIG}
   $(pwd)/exawind-config.sh  # File in the local build directory

The configuration variables in the subsequent files will override the default
values as well as configuration variables set in the previous files. The second
file :file:`${HOME}/exawind/exawind-config.sh` assumes that you followed the
standard :ref:`exawind_dir_layout`. Please replace the path appropriately
(:envvar:`EXAWIND_PROJECT_DIR`), if you used a non-standard location for
installation. See also :envvar:`EXAWIND_CONFIG`.

.. note::

   #. It is recommended that the user use local configuration files within build
      directories to set variables instead of modifying the build scripts within
      the `exawind/scripts` directory.

   #. If you are using a shared instance of exawind-builder (e.g., on NREL
      Peregrine), then please use :file:`exawind-config.sh` within your build
      directory to override common configuration parameters.


.. _compiling-software:

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

.. note::

   On NREL Peregrine and Eagle systems, the build scripts are pre-installed and
   configured in the project directory. Users do not have to install their own
   exawind-builder on these systems.

Compiling software, therefore, consists of the following steps:

#. Clone the apporpriate software repository into :file:`exawind/source` directory.

#. Create a CMake build directory. We recommend out-of-source builds for all software.

#. Create a symbolic link to the apporpriate build script from
   :file:`exawind/scripts` directory.

#. Create :file:`exawind/source/$project/build/exawind-config.sh`, if necessary,
   and set custom variables for this build. Examples include switching to debug
   builds, or using different version of dependencies. If the configuration is
   applicable to multiple codes that you are building, then consolidate the
   common options in :file:`exawind/exawind-config.sh` to avoid duplication.

#. Execute the build script

#. Add an entry in :ref:`configuration file <exawind_config>` to override the
   default version of software with your custom build version when compiling
   other software, e.g., overriding the default version of HYPRE or OpenFAST --
   see :envvar:`PROJECTNAME_ROOT_DIR` for more details.

On most systems, users will have to install Trilinos and Nalu-Wind manually.
Exceptions are NREL Peregrine, Eagle, and Rhodes systems where Trilinos is
installed and maintained by the ExaWind team. On these systems, users must
install Trilinos and set :envvar:`TRILINOS_ROOT_DIR <PROJECTNAME_ROOT_DIR>` in
their :ref:`configuration file <exawind_config>`.

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

Available tasks in the build script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The user can control which tasks are executed by providing additional parameters
to the script upon invocation as shown below:

.. code-block:: bash

   ./nalu-wind-gcc.sh [TASK] [ARGUMENTS]

The available **tasks** are:

- ``cmake``: Configure the project using CMake and generate build files. By
  default, it generates GNU Makefiles.

- ``cmake_full``: Remove :file:`CMakeCache.txt` and :file:`CMakeFiles` before
  executing CMake configuration step.

- ``make``:  Build the project libraries and executables.

- ``ctest``: Execute CTest for this project.

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

.. note::

   - By default, ``make`` will execute several jobs in parallel. Users can
     control the maximum number of parallel jobs by either setting the
     environment variable :envvar:`EXAWIND_NUM_JOBS` within the build script, or
     using ``./nalu-wind-gcc.sh make -j 12`` to override the defaults.

   - ``cmake_full`` accepts all valid CMake arguments that ``cmake`` command does.

   - The :file:`cmake_output.log` within the build directory contains the output
     of the last `cmake` command that was executed. This output is also echoed
     to the screen.

   - The :file:`make_output.log` contains the output from the last invocation of
     ``make``. This output is also simultaneously echoed to the screen.


.. _build_custom:

Customizing the build process
-----------------------------

The previous section showed how the execution of CMake and Make can be
customized to a limited extent by passing command line arguments with specific
tasks. However, for more complex customizations it is recommended that the user
use the :ref:`configuration file <exawind_config>` to control the build process.
This approach allows the user to consolidate common build options, e.g.,
enabling/disabling OpenMP/CUDA, release/debug builds across all projects
consistently through the :file:`exawind/exawind-config.sh` and fine tuning
options from the config file within the current working directory. This will
allow the user to repeat the build process consistently during development and
aid in debugging when things don't work as expected. The various customizations
possible are described below.

Customizing module load
~~~~~~~~~~~~~~~~~~~~~~~

`exawind-builder`` provides a default list of modules on most systems that work
for most use cases. However, the user might desire to use different modules for
their custom builds. This is achieved by configuring the modules to be loaded in
the :envvar:`EXAWIND_MODMAP` variable. For example, on NREL Peregrine the
default Trilinos build does not enable OpenMP support. In this case, the user
can replace the default ``trilinos/develop`` module by specifying the following
in the :ref:`configuration file <exawind_config>`.

.. code-block:: bash

   # Use OpenMP enabled version of trilinos module on Peregrine
   EXAWIND_MODMAP[trilinos]=trilinos/develop-omp

Enabling/Disabling TPLs
~~~~~~~~~~~~~~~~~~~~~~~

See project-specific documentation in :ref:`reference` to see what variables can
be used to enable/disable various options for different projects.

.. code-block:: bash

   # Control OpenMP and CUDA
   ENABLE_OPENMP=ON
   ENABLE_CUDA=OFF

   # Set debug/release options
   BUILD_TYPE=RELEASE

   # Disable TIOGA and OpenFAST, but enable HYPRE when building Nalu-Wind
   ENABLE_TIOGA=OFF
   ENABLE_OPENFAST=OFF
   ENABLE_HYPRE=ON

Using custom builds of libraries
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

During development, the user might desire to use a different branch of a
dependency than what the default system-wide installation provides. For example,
the user might want to use a different branch of OpenFAST when developing
advanced FSI capability within Nalu-Wind. The user can bypass the module
search/load process by defining :envvar:`ROOT_DIR <PROJECTNAME_ROOT_DIR>`
variable for the corresponding dependency. The following example shows how to
customize the TPLs used for building nalu-wind

.. code-block:: bash

   # Always provide our own Trilinos build
   export TRILINOS_ROOT_DIR=${EXAWIND_INSTALL_DIR}/trilinos

   # Override TPLs used to build nalu-wind
   export OPENFAST_ROOT_DIR=${EXAWIND_INSTALL_DIR}/openfast-dbg
   export HYPRE_ROOT_DIR=${EXAWIND_INSTALL_DIR}/hypre-omp

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

.. _exawind-env:

Activating ExaWind environment for job submissions
--------------------------------------------------

In addition to the build scripts, the *bootstrap* installation process also
creates a file called :file:`exawind/scripts/exawind-env-$COMPILER.sh` which can
be *sourced* to recreate the environment that was used to build the codes. User
can use this to setup the apporpriate environment in a job submission script, or
during interactive work, by simply sourcing this script.

.. code-block:: bash

   # Load the default modules (e.g., MPI)
   source ${HOME}/exawind/scripts/exawind-env-gcc.sh

In addition to loading the default modules, sourcing this file will also
introduce a bash command ``exawind_load_deps`` that can be used to load
additional modules within the bash environment. For example, to access
``ncdump`` available in the ``netcdf`` module on any system, the user can
execute the following

.. code-block:: bash

   # Activate exawind environment
   source ${HOME}/exawind/scripts/exawind-env-gcc.sh
   # load the NetCDF module or spack build
   exawind_load_deps netcdf

   # Now ncdump should be available in your PATH
   ncdump -h <exodus_file>
