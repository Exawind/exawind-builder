#!/bin/bash

exw_show_help ()
{
    cat <<EOF
$(basename ${BASH_SOURCE[0]}) [options]

Options:
  -h             - Show help message and exit
  -s <system>    - Select system profile (spack, cori, summitdev, etc.)
  -c <compiler>  - Select compiler type (gcc, clang, intel, etc.)
  -p <path>      - Root path for exawind project (default: ${HOME}/exawind)
  -n             - Configure exawind-builder to use ninja system
EOF
}

exw_check_system ()
{
    local envdir=${EXAWIND_PROJECT_DIR}/exawind-builder/envs
    local sys_file=${envdir}/${EXAWIND_SYSTEM}.bash

    if [ ! -f ${sys_file} ] ; then
       echo "ERROR! Unknown system provided. Valid options are"

       for fname in $(ls $envdir) ; do
           echo "  - $(basename $fname .bash)"
       done
       return 1
    fi
    return 0
}

exw_bstrap_env ()
{
    local basedir=${EXAWIND_PROJECT_DIR:-${HOME}/exawind}
    local exwblddir=${basedir}/exawind-builder
    local exwsys=${EXAWIND_SYSTEM:-spack}
    local env_file=${exwblddir}/etc/bootstrap/${exwsys}.bash

    if [ -f ${env_file} ] ; then
        echo "==> Sourcing bootstrap environment: ${env_file}"
        source ${env_file}
    fi
}

exw_init ()
{
    export EXAWIND_PROJECT_DIR=${EXAWIND_PROJECT_DIR:-${HOME}/exawind}
    local basedir=${EXAWIND_PROJECT_DIR}

    exw_bstrap_env

    if [ ! -d ${basedir} ] ; then
        echo "==> Creating project structure in ${EXAWIND_PROJECT_DIR}"
        mkdir -p ${basedir}
    fi
    mkdir -p ${basedir}/{install,scripts,source}


    cd ${basedir}
    if [ ! -d exawind-builder ] ; then
        git clone https://github.com/sayerhs/exawind-builder.git
    fi
}

exw_init_spack ()
{
    local basedir=${EXAWIND_PROJECT_DIR:-${HOME}/exawind}
    local ewblddir=${basedir}/exawind-builder
    local exwsys=${EXAWIND_SYSTEM:-spack}

    local check_homebrew="no"
    if [ "$(uname)" = "Darwin" ] ; then
       exwsys=osx

       # On OSX we will try to check if brew is installed in a non-standard
       # location and switch our paths accordingly.
       check_homebrew="yes"
    fi

    cd ${basedir}

    # Bail out if this is not our known directory structure
    if [ ! -d ${ewblddir} ] ; then
        echo "!!ERROR!! Please execute command from exawind project directory"
        exit 1
    fi

    local need_setup=no
    if [ ! -d spack ] ; then
        git clone https://github.com/spack/spack.git
        need_setup=yes
    fi

    if [ "${need_setup}" = "yes" ] ; then
        echo "==> Setting up spack compiler and package settings"
        local have_compiler_yaml=no
        local spackos=$(uname -s | tr "[:upper:]" "[:lower:]")

        if [ ! -d spack/etc/spack/${spackos} ] ; then
            mkdir spack/etc/spack/${spackos}
        fi

        if [ -d ${ewblddir}/etc/spack/${exwsys} ] ; then
            local cfgdir=${ewblddir}/etc/spack/${exwsys}

            # Copy the base packages.yaml common to all systems
            ln -s ${ewblddir}/etc/spack/spack/packages.yaml spack/etc/spack/packages.yaml

            if [ "${check_homebrew}" = "yes" ]; then
                local brew_prefix=$(brew config | awk -F: '/HOMEBREW_PREFIX/ {print $2;}')
                sed -e "s#/usr/local#${brew_prefix}#g" ${cfgdir}/packages.yaml > spack/etc/spack/${spackos}/packages.yaml
            elif [ -f ${cfgdir}/packages.yaml ] ; then
                ln -s ${cfgdir}/packages.yaml spack/etc/spack/${spackos}
            fi

            if [ -f ${cfgdir}/compilers.yaml ] ; then
                ln -s ${cfgdir}/compilers.yaml spack/etc/spack/
                have_compiler_yaml=yes
            fi

            if [ -f ${cfgdir}/config.yaml ] ; then
                ln -s ${cfgdir}/config.yaml spack/etc/spack
            fi
        fi
    fi

    source spack/share/spack/setup-env.sh

    if [ "${need_setup}" = "yes" -a "${have_compiler_yaml}" = "no" ] ; then
        spack compiler find
    fi
}

exw_install_deps ()
{
    local basedir=${EXAWIND_PROJECT_DIR}
    cd ${basedir}
    local exwcompiler=${EXAWIND_COMPILER}
    local spack_compiler=${SPACK_COMPILER:-$exwcompiler}

    spack install cmake %${spack_compiler}
    spack install mpi %${spack_compiler}
    spack install m4 %${spack_compiler}
    spack install zlib %${spack_compiler}
    spack install libxml2 %${spack_compiler}
    spack install boost %${spack_compiler}
    spack install superlu %${spack_compiler}
    spack install hdf5 %${spack_compiler}
    spack install netcdf-c %${spack_compiler}
    spack install yaml-cpp %${spack_compiler}
    spack install hypre %${spack_compiler}
    #spack install fftw %${spack_compiler}
}

exw_create_scripts ()
{
    local exwbld=${EXAWIND_PROJECT_DIR}/exawind-builder
    cd ${EXAWIND_PROJECT_DIR}/scripts

    echo "==> Creating build scripts for known projects"
    for fname in $(ls ${exwbld}/codes) ; do
        local prj=$(basename $fname .bash)
        ${exwbld}/new-script.sh -s ${EXAWIND_SYSTEM} -c ${EXAWIND_COMPILER} -p ${prj}
    done

    # Create the environment script
    ${exwbld}/create-env.sh -s ${EXAWIND_SYSTEM} -c ${EXAWIND_COMPILER}
}

exw_get_ninja ()
{
    local srcdir=${EXAWIND_PROJECT_DIR}/source
    cd ${srcdir}

    if [ ! -d ninja ] ; then
        git clone https://github.com/Kitware/ninja.git
    fi

    if [ ! -f ninja/ninja ] ; then
        cd ${srcdir}/ninja/
        ./configure.py --bootstrap
    fi
}

exw_create_config ()
{
    local cfgprefix=${EXAWIND_CFGFILE:-exawind-config}
    local cfgfile=${EXAWIND_PROJECT_DIR}/${cfgprefix}.sh
    if [ -f ${EXAWIND_PROJECT_DIR}/${cfgprefix}.sh ] ; then
        echo "==> Found previous configuration: ${EXAWIND_PROJECT_DIR}/${cfgprefix}.sh"
        return
    fi

    local use_ninja=${1:-no}
    local ninja_enable="#"
    if [ "${use_ninja}" = "yes" ] ; then
        ninja_enable=""
    fi

    echo "==> Creating default config file: ${EXAWIND_PROJECT_DIR}/${cfgprefix}.sh"
    cat <<EOF > ${EXAWIND_PROJECT_DIR}/${cfgprefix}.sh
#!/bin/bash
#
# Exawind-builder configuration file.
# Generated by bootstrap script at $(date "+%Y-%m-%d %H:%M:%S %Z")
# Documentation available at https://exawind-builder.readthedocs.io/en/latest/index.html
#
# Edit this to configure the build process with exawind-builder
#

#SPACK_ROOT=\${EXAWIND_PROJECT_DIR}/spack
#SPACK_COMPILER=\${SPACK_COMPILER:-\${EXAWIND_COMPILER}}

${ninja_enable}EXAWIND_MAKE_TYPE=ninja
${ninja_enable}export PATH=${EXAWIND_PROJECT_DIR}/source/ninja:\${PATH}

BUILD_TYPE=RELEASE     # [RELEASE, DEBUG, RELWITHDEBINFO]
ENABLE_OPENMP=ON       # [ON, OFF]

ENABLE_OPENFAST=OFF    # Enable OpenFAST TPL with Nalu-Wind
ENABLE_TIOGA=OFF       # Enable TIOGA for overset connectivity
ENABLE_HYPRE=ON        # Enable HYPRE linear solvers with Nalu-Wind
ENABLE_FFTW=OFF        # Enable FFTW for ABL simulations

#
# CUDA builds using Kokkos wrappers
#
#ENABLE_CUDA=OFF
#EXAWIND_CUDA_WRAPPER=\${EXAWIND_PROJECT_DIR}/source/trilinos/packages/kokkos/bin/nvcc_wrapper

# Customize module loads (when choosing from multiple options)
# EXAWIND_MODMAP[trilinos]=trilinos/develop-omp
# EXAWIND_MODMAP[hypre]=hypre/2.15.0

#
# Uncomment these lines to use custom builds of these packages
#
#TRILINOS_ROOT_DIR=\${EXAWIND_INSTALL_DIR}/trilinos
#HYPRE_ROOT_DIR=\${EXAWIND_INSTALL_DIR}/hypre
#TIOGA_ROOT_DIR=\${EXAWIND_INSTALL_DIR}/tioga
#OPENFAST_ROOT_DIR=\${EXAWIND_INSTALL_DIR}/openfast
#NALU_WIND_ROOT_DIR=\${EXAWIND_INSTALL_DIR}/nalu-wind

EOF

    echo "==> Please check auto-generated configuration file: ${cfgfile}"
}

exw_need_spack_setup ()
{
    local no_spack_machines=(peregrine eagle rhodes snl-waterman-atdm)
    local exwsys=${EXAWIND_SYSTEM:-spack}
    local out=0

    for sys in "${no_spack_machines[@]}" ; do
        if [[ "$exwsys" == "$sys" ]]; then
            out=1
            echo "==> Skipping Spack setup for this system"
            break
        fi
    done
    return $out
}

exw_main ()
{
    export EXAWIND_PROJECT_DIR=${EXAWIND_PROJECT_DIR:-${HOME}/exawind}
    export EXAWIND_SYSTEM=${EXAWIND_SYSTEM:-spack}
    local exwcomp=gcc
    if [ "$(uname)" = "Darwin" ] ; then
        exwcomp=clang
    elif [ "${EXAWIND_SYSTEM}" = "cori" ] ; then
        exwcomp=intel
    fi
    export EXAWIND_COMPILER=${EXAWIND_COMPILER:-$exwcomp}
    local use_ninja=no

    OPTIND=1
    while getopts ":s:c:p:hn" opt; do
        case "$opt" in
            h)
                exw_show_help
                exit 0
                ;;
            s)
                EXAWIND_SYSTEM=$OPTARG
                ;;
            c)
                EXAWIND_COMPILER=$OPTARG
                ;;
            p)
                EXAWIND_PROJECT_DIR=$OPTARG
                ;;
            n)
                use_ninja=yes
                ;;
            \?)
                echo "ERROR: Invalid argument provided"
                exw_show_help
                exit 1
                ;;
        esac
    done

    set -e
    exw_init
    exw_check_system || exit 1
    exw_need_spack_setup && exw_init_spack && exw_install_deps
    exw_create_scripts

    if [ "${use_ninja}" = "yes" ] ; then
        exw_get_ninja
    fi

    exw_create_config ${use_ninja}
}

exw_main "$@"
