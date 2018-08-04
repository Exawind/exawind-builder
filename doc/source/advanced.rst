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
