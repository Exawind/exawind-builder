.. _new-system:

Adding new system configuration
===============================

This section documents the process of adding a new system configuration to
``exawind-builder``. Currently, ``exawind-builder`` has two major modes of
operation: the *bootstrap mode*, and the *software configuration and build*
mode. The *bootstrap mode* sets up the basic :ref:<exawind_dir_layout>,
configures spack (if necessary), and builds all the dependencies required to
compile Trilinos. In the *software build mode* the it allows users to configure
(using CMake) and build Trilinos and Nalu-Wind. The basic steps can be
summarized as follows

*Preparation*

- Determine a unique name for the system. The recommended naming system is
  ``org-system``. For example, to create a configuration for ORNL's Summit
  system, we will use ``ornl-summit`` as the system name in ``exawind-builder``.
  The convention within ``exawind-builder`` is to use this system name
  consistently to name things: directories containing system-specific
  configuration, filenames for system specific environment functions, etc. This
  will be described in detail in the later sections of this documentation. The
  system specific name will be assigned to :envvar:`EXAWIND_SYSTEM` and will be
  referred to as ``${EXAWIND_SYSTEM}`` in the following sections.

- Collect necessary data to create a system configuration

*Configuration for bootstrap mode*

- Create the minimal build environment necessary for running bootstrap mode,
  i.e., building dependencies with Spack.

- Create a Spack configuration allowing use of as many of the available
  system modules but building the rest within Spack.

*Configuration for build mode*

- Create necessary system environment functions to allow users to build
  Nalu-Wind using different compiler configurations and, optionally, with GPU
  support.

.. note::

   - **Important:** It must be noted that the configuration steps for *bootstrap
     mode* are **optional**. Users can use ``-s spack`` for system and have
     Spack build the entire dependency stack on a new system. The disadvantage
     of this approach is the long build time for dependencies (particularly MPI)
     and not being able to use the libraries that have been optimized for the
     target system (again MPI that might be build with Infiniband, SLURM
     support, etc.)

   - ``exawind-builder`` currently doesn't follow the recommended system naming
     convention for several legacy systems (NREL Peregrine and Eagle, NERSC
     Cori, etc.). The builder evolved from several one-off build scripts and
     the old names have been retained to preserve backwards compatibility.

   - Nalu-Wind tracks the ``develop`` branch of Trilinos for its latest version.
     This is necessary because ExaWind project has performance and scalability
     as its primary objectives, and this often requires the latest improvements
     to Trilinos solvers and Sierra Toolkit (STK) packages.

   - The ``exawind-builder`` documentation often only mentions Trilinos as a
     prerequisite for building Nalu-Wind. However, the process described for
     building Trilinos and Nalu-Wind should be used to build other prerequisites
     such as HYPRE, OpenFAST, and TIOGA.


Determine system configuration
------------------------------

#. Determine what compiler suites you want to support/use on the system, e.g.,
   GCC, Intel, LLVM/Clang, IBM XL, etc.

#. Determine what software is already available on the system that can be used
   and what we will need to build ourselves. It is strongly recommended that the
   user build HDF5, NetCDF, and parallel NetCDF (pNetCDF) through Spack always
   regardless of whether these modules are available on the system. The Exawind
   team has experienced a lot of issues with these libraries that lead to
   runtime errors when loading Exodus files in parallel.

#. Determine whether you want to build shared or static libraries. Ensure that
   the libraries available on the login or compute nodes used to build the codes
   are also available on the nodes where the runs will be performed. When in
   doubt opt for static library builds, this will increase the size of the
   executable but is the most robust for the end user.

#. Determine whether you will be able to download packages (during bootstrap
   phase) through :program:`curl` or :program:`wget`, or if you will have issues
   with SSL certificates or need proxy servers.

#. Determine how many parallel builds you are allowed to execute on your system.
   We will use this to limit the launch of parallel jobs by ``spack`` and
   ``exawind-builder``. When in doubt, 4-8 parallel jobs is a safe number.

Create skeleton directory structure
-----------------------------------

We will create a minimal exawind structure to clone ``exawind-builder`` and add
the necessary system files.

.. code-block:: bash

   # Create top-level exawind directory structure
   mkdir -p ${HOME}/exawind/{scripts,install,source}
   cd ${HOME}/exawind
   git clone git@github.com:exawind/exawind-builder.git

Change the protocol from ``git`` to `https://`` if you have issues cloning using
``git`` transport over SSH. For the rest of this documentation,
``exawind-builder`` will refer to the path
:file:`${HOME}/exawind/exawind-builder`, please adjust appropriately if you are
using a non-standard installation location for ``exawind``.


Create minimal bootstrap environment
------------------------------------

This step involves loading the necessary compiler, MPI, and CMake modules for
use with Spack when running the bootstrap script. **This step is optional** and
is only necessary if the login environment on a system does not correspond to
what the user intends to use to build the software. If a specific environment
must be setup before running :ref:`bootstrap <installation>`, then we will create a
system specific file :file:`${EXAWIND_SYSTEM}.bash` in
:file:`exawind-builder/etc/boostrap` directory. The following example shows the
contents of :file:`nrel-eagle.bash` that loads modules necessary to execute
bootstrap command on NREL's Eagle cluster.

.. code-block:: bash

   #!/bin/bash

   # Remove any user modules that might conflict
   module purge

   # Default build is using GCC compilers
   module load gcc/7.3.0
   # Load the latest OpenMPI version (build with CUDA support)
   module load openmpi/3.1.3

.. tip::

   - To avoid strange linking errors during the *build mode*, it is recommended
     that the bootsrap environment match the final environment you will use in
     the system environment specification.

   - If your system is behind a firewall, it might be necessary to configure
     appropriate proxies for HTTP and HTTPS (e.g., SNL systems), look at
     :file:`etc/bootstrap/snl-ghost.bash` for examples.

   - If you experience spurious build errors, you might need to configure the
     temporary directory used by the build systems by configuring the ``TMPDIR``
     variable to point to a scratch directory.

Create Spack configuration
--------------------------

In this step we will create exact specifications for the compilers spack will
use, pin the package versions for all the dependencies, instruct spack which
pre-installed dependencies on the system we will use, and (optionally) tell
spack about insecure SSL transport requirements and/or limits on the parallel
jobs. A system-specific spack configuration is generated by creating a
subdirectory :file:`exawind-builder/etc/spack/${EXAWIND_SYSTEM}/`. We will always
create two files :file:`compilers.yaml` and :file:`packages.yaml` and an
optional :file:`config.yaml` within this directory based on specific
requirements for the system.

Spack compiler configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The easiest way to determine the compiler configurations available is to load
the necessary modules on your system and run spack's compiler detection command
as shown below:

.. code-block:: bash

   # Load all necessary modules
   # Clone a throwaway spack repo if necessary
   cd ${HOME}/tmp
   git clone https://github.com/spack/spack.git
   # Activate the spack environment (assuming bash shell)
   source spack/share/spack/setup-env.sh

   # Let spack detect compilers
   spack compiler find

The above step creates a file :file:`${HOME}/.spack/$(spack arch
-p)/compilers.yaml` that can be used as the basis for creating your compiler
configuration. This YAML file contains a list of compilers that was detected by
``spack``. Please edit this file and keep only the compilers you want to add to
``exawind-builder``. We recommend removing older versions of GCC etc. that you
don't plan to use. If your desired compiler is not found/detected, you will need
to add entries manually. In this case, you should note and reuse the variables
``operating_system`` and ``target`` from the spack output. Copy the completed
file over to :file:`exawind-builder/etc/spack/${EXAWIND_SYSTEM}/compilers.yaml`

See `Spack compilers configuration docs
<https://spack.readthedocs.io/en/latest/getting_started.html#compiler-config>`_
for more details.

.. note::

   Make sure you backup and remove the :file:`${HOME}/.spack/$(spack arch -p)`
   directory as the settings lurking here will take precendence over the ones we
   will set up using ``exawind-builder``.

Spack package configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~

In this step, we will inform spack the modules/paths of pre-built system
libraries we will want to use and the compilers we want spack to be aware of
when building packages. Start with
:file:`exawind-builder/etc/spack/spack/packages.yaml` as the basis for building
your ``packages.yaml`` file. Take a look at other ``packages.yaml`` examples in
the :file:`exawind-builder/etc/spack/` sub-directories to see examples of using
system libraries. The general steps involve updating the ``version``, setting
``buildable: false`` and providing the list of modules or paths where the
library is located. The steps are:

- Set the order and precendence of compilers

- Set default package providers for ``mpi`` (OpenMPI, MPICH, Intel-MPI, etc.),
  ``blas``, ``lapack``

- Set default variants, use ``~shared`` here to enforce static libraries for all
  packages spack builds. A good default value is ``+mpi build_type=Release``.

Also see `Spack build customization
<https://spack.readthedocs.io/en/latest/build_settings.html>`_ for more
information.

Spack config.yaml
~~~~~~~~~~~~~~~~~

This file is optional and is necessary when you want to change some of the
default behaviors of spack. The variables that often require changing are:

- ``build_jobs`` -- Set this to the number of maximum parallel build jobs you
  are allowed to run on the system.

- ``verify_ssl`` -- On some systems, you might have to set this to ``false`` to
  be able to download packages.

Please see `Spack docs
<https://spack.readthedocs.io/en/latest/config_yaml.html#config-yaml>`_ for
other variables that can be configured for your system.

Create system environment configuration
---------------------------------------

In this step we will create the files necessary to recreate the build
environment when building the software. The system-specific configuration is
implemented as bash functions stored in the file
:file:`exawind-builder/envs/${EXAWIND_SYSTEM}.bash`. This file must implement at
least one function ``exawind_env_${EXAWIND_COMPILER}`` where
:envvar:`EXAWIND_COMPILER` is the default compiler option supported for this
system. A barebones environment file for a system with only GCC compiler support
is shown here:

.. code-block:: bash

   #!/bin/bash

   # Source the default spack functionality
   source ${__EXAWIND_CORE_DIR}/envs/spack.bash

   # Set the maximum parallel build jobs we can execute
   export EXAWIND_NUM_JOBS_DEFAULT=8
   # Set the default compiler to GCC
   export EXAWIND_COMPILER_DEFAULT=gcc

   exawind_env_gcc ()
   {
       module purge
       module load gcc/7.3.0
       module load openmpi/3.1.3

       # Load other dependencies
       exawind_load_deps cmake netlib-lapack
   }

   exawind_env_clang ()
   {
       echo "ERROR: No CLANG environment set up for ${EXAWIND_SYSTEM}"
       exit 1
   }

   exawind_env_intel ()
   {
       echo "ERROR: No Intel environment set up for ${EXAWIND_SYSTEM}"
   }


.. note::

   - Please consult the :ref:`variable reference <reference>` to see other variables
     that can be configured for a system. **Do not** set the following variables
     within a system environment file: ``EXAWIND_SYSTEM, EXAWIND_COMPILER,
     EXAWIND_CODE, EXAWIND_SRCDIR, EXAWIND_PROJECT_DIR, EXAWIND_INSTALL_DIR,
     EXAWIND_CONFIG, EXAWIND_CFGFILE, SPACK_ROOT``.

   - For more complicated build environment support, take a look at the `NREL
     Eagle
     <https://github.com/exawind/exawind-builder/blob/master/envs/eagle.bash>`_
     environment file.


Run bootstrap
-------------

At this point, ``exawind-builder`` has all the information necessary for your
system. Run ``bootstrap`` to tell ``exawind-builder`` to fetch spack and install
all the dependencies.

.. code-block:: console

   # Run bootstrap
   cd ${HOME}
   # Run bootstrap from your local exawind-builder
   exawind/exawind-builder/bootstrap.sh -c gcc -s ${EXAWIND_SYSTEM}

In case you run into errors and want to tweak the configuration, please delete
the spack directory :file:`${HOME}/exawind/spack` and start a fresh build to
ensure that the final configuration in ``exawind-builder`` for your system will
execute without any errors for other users.

If *bootstrap* succeeds, you should have build scripts in
:file:`${HOME}/exawind/scripts` for the compiler of your choice. Proceed to
:ref:`tut-basic-compilation` to build Trilinos and Nalu-Wind.

Once you have successfully built Nalu-Wind and executed regression tests on the
new system, please consider submitting a pull request to allow other users to
benefit from this configuration when using ``exawind-builder``.
