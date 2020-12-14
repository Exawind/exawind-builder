# ExaWind Code Builder

[Documentation](https://exawind.github.io/exawind-builder)

ExaWind Builder is a collection of bash scripts to configure and compile the
codes used within the [ExaWind](https://github.com/exawind) project on various
high-performance computing (HPC) systems. The builder provides the following

- **Platform configuration**: Provides the minimal set of modules that must be
  loaded when compiling with different compilers and MPI libraries on different
  HPC systems.

- **Software configuration**: Provides baseline CMake configuration that can be
  used to configure the various options when building a *project*, e.g.,
  enable/disable optional modules, automate specification of paths to various
  libraries, configure release vs. debug builds.

- **Build script generation**: Generates an executable end-user script for a
  combination of *system*, *compiler*, and *project*.

- **Exawind environment generation**: Generates a source-able, platform-specific
  script that allows the user to recreate the exact environment used to build
  the codes during runtime.

The build scripts are intended for developers who might want to compile the
codes with different configuration options, build different branches during
their development cycle, or link to a different development version of a library
that is currently not available in the standard installation on the system. Please see the
[documentation](https://exawind.github.io/exawind-builder) for
details on how to use this to build ExaWind software.

## Installation and usage

### Using exawind-builder with pre-installed ExaWind environment

ExaWind Builder is already installed and setup on OLCF Summit, NREL
Eagle/Rhodes, and NERSC Cori systems. On these systems, you can proceed directly
to using build scripts from the central installation. Please consult [user
manual](https://exawind.github.io/exawind-builder/basic.html#basic-usage) to
learn how to use the scripts.

### Bootstrapping exawind-builder with pre-configured system definitions
ExaWind builder has [pre-built
configurations](https://exawind.github.io/exawind-builder/introduction.html#pre-configured-systems)
for several systems. On these systems you can use the `bootstrap` script to
quickly get up and running. Please consult [installation
manual](https://exawind.github.io/exawind-builder/installation.html). The
relevant steps are shown below.

```bash
# Download bootstrap script
curl -fsSL -o bootstrap.sh https://raw.githubusercontent.com/exawind/exawind-builder/master/bootstrap.sh

# Make it executable
chmod a+x bootstrap.sh

# Execute bootstrap and provide system/compiler combination
./bootstrap.sh -s [SYSTEM] -c [COMPILER]

# Examples
./bootstrap.sh -s spack -c clang       # On MacOS with homebrew
./bootstrap.sh -s ornl-summit -c gcc   $ Oakridge Summit system
./bootstrap.sh -s eagle -c gcc         # NREL Eagle
./bootstrap.sh -s cori -c intel        # NERSC Cori
./bootstrap.sh -s snl-ascicgpu -c gcc  # SNL GPU development machine
```

### Creating new system configuration

You can add new system definitions to exawind-builder for use on new systems
that are not used by ExaWind team. Please see [manual
installation](https://exawind.github.io/exawind-builder/advanced.html) and
[adding a new system](https://exawind.github.io/exawind-builder/newsys.html)
sections in the user manual.

## Links 

- [ExaWind](https://www.exawind.org)
- [ExaWind GitHub Organization](https://github.com/exawind)
- [A2e HFM](https://a2e.energy.gov/about/hfm)
