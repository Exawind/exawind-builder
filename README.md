# ExaWind Code Builder

ExaWind Builder is a collection of bash scripts to configure and compile the
codes used within the [ExaWind](https://github.com/exawind) project on various
high-performance computing (HPC) systems. The builder provides the following

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
that is currently not available in the standard installation on the system. Please see the
[documentation](https://exawind-builder.readthedocs.io/en/latest/index.html) for
details on how to use this to build ExaWind software.

**Pre-configured systems**

|System |  Description
|----------------- |  --------------------------------------------------------------------------------------------|
|`spack`         |   [Spack](https:://github.com/LLNL/spack) (system agnostic)                                |
|`peregrine`     |   [NREL Peregrine](https://www.nrel.gov/hpc/peregrine-system.html)                         |
|`eagle`         |   [NREL Eagle](https://www.nrel.gov/hpc/eagle-system.html)                                 |
|`cori`          |   [NERSC Cori](http://www.nersc.gov/users/computational-systems/cori/)                     |
|`summitdev`     |   [OLCF SummitDev](https://www.olcf.ornl.gov/olcf-resources/compute-systems/summit/)      |
|`snl-ascicgpu`  |   Sandia ASC GPU development machines                                                        |
|`rhodes`        |   NREL nightly build and test system                                                         |

## Quick installation 

```bash
# Download bootstrap script
curl -fsSL -o bootstrap.sh https://raw.githubusercontent.com/sayerhs/exawind-builder/master/bootstrap.sh

# Make it executable
chmod a+x bootstrap.sh

# Execute bootstrap and provide system/compiler combination
./bootstrap.sh -s [SYSTEM] -c [COMPILER]

# Examples
./bootstrap.sh -s spack -c clang       # On OS X with homebrew
./bootstrap.sh -s peregrine -c gcc     # NREL Peregrine
./bootstrap.sh -s eagle -c gcc         # NREL Eagle
./bootstrap.sh -s cori -c intel        # NERSC Cori
./bootstrap.sh -s snl-ascicgpu -c gcc  # SNL GPU development machine
```

## Links 

- [ExaWind](https://www.exawind.org)
- [ExaWind GitHub Organization](https://github.com/exawind)
- [A2e HFM](https://a2e.energy.gov/about/hfm)
