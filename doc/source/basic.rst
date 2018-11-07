.. _basic_usage:

Basic Usage
===========

On certain systems, the ``exawind-builder`` has already been installed in a
common project location and build scripts are provided in
:file:`exawind/scripts` directory. This section describes the usage of such
scripts to configure and build ExaWind projects. If you want to setup your own
independent :file:`exawind` directory structure see :ref:`advanced_usage` section.

Compiling software
------------------

The build scripts by default are typically named ``$PROJECT-$COMPILER.sh``, so
for example when compiling ``nalu-wind`` with the GCC compiler suite, the
default script is :file:`nalu-wind-gcc.sh`. With no arguments, the script will
load all necessary modules and execute CMake configuration step followed by
``make``.

On systems that have all dependencies installed, building a certain project
(e.g., nalu-wind) requires the following steps:

#. Clone the repository

   .. code-block:: bash

      git clone git@github.com:exawind/nalu-wind.git

#. Create a build directory and copy the build script

   .. code-block:: bash

      cd nalu-wind
      mkdir build-release # Create an optimized executable
      cd build-release
      cp <path_to_build_script> .
      # Edit script if necessary

      # Run CMake and make
      ./nalu-wind-gcc.sh

Available tasks
~~~~~~~~~~~~~~~

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

Recreate build environment for job submission
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The user can recreate the same environment in job submission or during
interactive work by simply sourcing the build script from within the job
submission script.

.. code-block:: bash

   # Example for nalu-wind execution
   export EXAWIND_PROJECT_DIR=[PATH_TO_EXAWIND_DIR]
   source ${EXAWIND_PROJECT_DIR}/scripts/nalu-wind-gcc.sh

   # Example for OpenFAST execution
   export EXAWIND_PROJECT_DIR=[PATH_TO_EXAWIND_DIR]
   source ${EXAWIND_PROJECT_DIR}/scripts/openfast-intel.sh


.. _build-customization:

Customizing the build process
-----------------------------

The execution of CMake and Make can be customized to a limited extend by passing
command line arguments as described in the previous section. However, for more
complex customizations it is recommended that the user copy and customize the
parameters within the build script. This will allow the user to consistently
repeat the build process during development and will serve as a reference to the
configuration that is being used currently. A build script with default
parameters is shown below:

.. literalinclude:: files/trilinos-intel.sh
   :language: bash
   :linenos:

The structure of the build script is same regardless of machine, compiler, or
project that is being built. Lines 13-17 initializes several variables required
by ``exawind-builder``, lines 22-24 load the core, machine-specific, and
project-specific functions. Lines 46-51 will have the appropriate :ref:`project
variables <ref-project-vars>` defined. Don't modify lines 13-42 unless you know
what you are doing.

It is recommended that all user customizations be added within the block
indicated by lines 53--55. User might want to customize :envvar:`install
directory <PROJECTNAME_INSTALL_DIR>` when building different variants (e.g.,
release, debug, etc.). In the following sections, only the modifications that
must be entered between lines 53--55 are shown. See :ref:`Using configuration
files` for alternate approach to editing the build scripts.

Customizing module load
~~~~~~~~~~~~~~~~~~~~~~~

``exawind-builder`` provides a default list of modules on most systems that work
for most use cases. However, the user might desire to use different modules for
their custom builds. This is achieved by configuring the modules to be loaded in
the :envvar:`EXAWIND_MODMAP` variable. For example, on NREL Peregrine the
default Trilinos build does not enable OpenMP support. In this case, the user
can replace the default ``trilinos/develop`` module by specifying the following
in the nalu-wind build script

.. code-block:: bash

   ########## BEGIN user specific configuration ###########

   # Use OpenMP version of the module on Peregrine
   EXAWIND_MODMAP[trilinos]=trilinos/develop-omp

   ########## END user specific configuration   ###########

Enabling/Disabling TPLs
~~~~~~~~~~~~~~~~~~~~~~~

See project-specific documentation in :ref:`reference` to see what variables can
be used to enable/disable various options for different projects. For example,
to disable TIOGA and OpenFAST when compiling nalu-wind

.. code-block:: bash

   ########## BEGIN user specific configuration ###########

   # Disable TIOGA and OPENFAST
   export ENABLE_TIOGA=OFF
   export ENABLE_OPENFAST=OFF

   ########## END user specific configuration   ###########

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

   ########## BEGIN user specific configuration ###########

   # Override TPLs used to build nalu-wind
   export OPENFAST_ROOT_DIR=${EXAWIND_INSTALL_DIR}/openfast-dbg
   export HYPRE_ROOT_DIR=${EXAWIND_INSTALL_DIR}/hypre-omp

   ########## END user specific configuration   ###########


Customizing CMake configuration phase
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Using configuration files
~~~~~~~~~~~~~~~~~~~~~~~~~

The configuration options described above can be consolidated in configuration
files that provided various levels of control. The following files are loaded in
the specified order and options in later files will override the options defined
previously. Thus, user can set generic options and refine them for specific projects.

The files loaded are::

.. code-block:: bash

   ${HOME}/.exawind-config   # User configuration file
   ${EXAWIND_CONFIG}         # File pointed to by the variable ${EXAWIND_CONFIG}
   $(pwd)/exawind-config.sh  # File in the local build directory

The default value of :envvar:`${EXAWIND_CONFIG}` is
:file:`${EXAWIND_PROJECT_DIR}/exawind-config.sh`

.. note::

   - Since bash functions are project specific, they must be customized only in
     the build script and not in the configuration file.
