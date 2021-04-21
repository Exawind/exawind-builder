.. exawind-builder documentation master file, created by
   sphinx-quickstart on Fri Aug  3 18:08:02 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

#################################
ExaWind Builder User Manual
#################################

.. only:: html

   :Version: |release|
   :Date: |today|

`ExaWind Builder <https://github.com/exawind/exawind-builder>`_ is a collection
of bash scripts to configure and compile the codes used within the `ExaWind
<https://github.com/exawind>`_ project on various high-performance computing
(HPC) systems. The builder provides the following

- *Platform configuration*: Provides the minimal set of modules that must be
  loaded when compiling with different compilers and MPI libraries on different
  HPC systems.

- *Software configuration*: Provides baseline CMake configuration that can be
  used to configure the various options when building a *project*, e.g.,
  enable/disable optional modules, automate specification of paths to various
  libraries, configure release vs. debug builds.

- *Build script generation*: Generates an executable end-user script for a
  combination of *system*, *compiler*, and *project*.

- *Exawind environment generation*: Generates a source-able, platform-specific
  script that allows the user to recreate the exact environment used to build
  the codes during runtime.

The build scripts are intended for developers who might want to compile the
codes with different configuration options, build different branches during
their development cycle, or link to a different development version of a library
that is currently not available in the standard installation on the system.

**Contents**

.. toctree::
   :maxdepth: 4

   introduction
   basic
   installation
   newsys
   advanced
   reference


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
