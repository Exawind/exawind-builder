# ExaWind Code Builder

A collection of bash scripts to build codes used within the ExaWind project on
different high-performance computing (HPC) systems.

## Usage 

```
bash$ ./new-script.sh -h
new-script.sh [options] [output_file]

Options:
  -h             - Show help message and exit
  -p <project>   - Select project (nalu-wind, openfast, etc)
  -s <system>    - Select system profile (spack, peregrine, cori, etc.)
  -c <compiler>  - Select compiler type (gcc, intel, clang)

Argument:
  output_file    - Name of the build script (default: '$project-$compiler.sh')
```

## Links 

- [ExaWind](https://www.exawind.org)
- [A2e HFM](https://a2e.energy.gov/about/hfm)
