# ExaWind Code Builder

A collection of bash scripts to build codes used within the ExaWind project on
different high-performance computing (HPC) systems. Please see the
[documentation](https://exawind-builder.readthedocs.io/en/latest/index.html) for
details on how to use this to build ExaWind software.

**Systems**

|System Name       |  Description
|----------------- |  --------------------------------------------------------------------------------------------|
|`spack`         |   [Spack](https:://github.com/LLNL/spack) (system agnostic)                                |
|`peregrine`     |   [NREL Peregrine](https://www.nrel.gov/hpc/peregrine-system.html)                         |
|`eagle`         |   [NREL Eagle](https://www.nrel.gov/hpc/eagle-system.html)                                 |
|`cori`          |   [NERSC Cori](http://www.nersc.gov/users/computational-systems/cori/)                     |
|`summitdev`     |   [OLCF SummitDev](https://www.olcf.ornl.gov/olcf-resources/compute-systems/summit/**       |
|`snl-ascicgpu`  |   Sandia ASC GPU development machines                                                        |
|`rhodes`        |   NREL nightly build and test system                                                         |

**Codes**

Code                 |  Repository
-------------------- |  -------------------------------------------------
Nalu-Wind            |  https://github.com/exawind/nalu-wind.git
Trilinos             |  https://github.com/trilinos/trilinos.git
OpenFAST             |  https://github.com/openfast/openfast.git
Nalu Wind Utilities  |  https://github.com/exawind/wind-utils.git
TIOGA                |  https://github.com/jsitaraman/tioga.git
TIOGA Utilities      |  https://github.com/sayerhs/tioga_utils.git
HYPRE                |  https://github.com/LLNL/hypre.git
hypre-mini-app       |  https://github.com/exawind/hypre-mini-app.git

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
