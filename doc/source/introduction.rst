.. _introduction:

.. _basic_usage:

Basic Usage
===========

On certain systems, the ``exawind-builder`` has already been installed in a
common project location and build scripts are provided in
:file:`exawind/scripts` directory. This section describes the usage of such
scripts to configure and build ExaWind projects. If you want to setup your own
independent :file:`exawind` directory structure see :ref:`advanced_usage` section.

The build scripts by default are typically named ``$PROJECT-$COMPILER.sh``, so
for example when compiling ``nalu-wind`` with the GCC compiler suite, the
default script is :file:`nalu-wind-gcc.sh`. With no arguments, the script will
load all necessary modules and execute CMake configuration step followed by
``make``. However, the user can control which tasks are executed by providing
additional parameters to the script upon invocation as shown below:

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

Lines 1-37 should not be modified by the user, they are automatically generated
by ``exawind-builder``. It is recommended that all user customizations be added
within the block indicated by lines 48--50. User might want to customize
:envvar:`install directory <PROJECTNAME_INSTALL_DIR>` when building different
variants (e.g., release, debug, etc.).

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
function with their own that adds the extra options permanently every time
``cmake`` is executed. For example, to build ``nalu-wind`` with ParaView Catalyst support:

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

.. note::

   All configuration parameters described here can also be consolidated in the
   :file:`${EXAWIND_PROJECT_DIR}/exawind-config.sh` file for use across several
   projects. For example, user can specify their own build of Trilinos across
   Nalu-Wind and Nalu-Wind-Utils by adding ``TRILINOS_ROOT_DIR`` to the
   configuration file.


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
  │   └── trilinos
  ├── scripts
  │   ├── hypre-clang.sh
  │   ├── nalu-wind-clang.sh
  │   ├── tioga-clang.sh
  │   └── trilinos-clang.sh
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
