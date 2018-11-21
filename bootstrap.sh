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

exw_init ()
{
    export EXAWIND_PROJECT_DIR=${EXAWIND_PROJECT_DIR:-${HOME}/exawind}
    local basedir=${EXAWIND_PROJECT_DIR}

    if [ ! -d ${basedir} ] ; then
        echo "==> Creating project structure in ${EXAWIND_PROJECT_DIR}"
        mkdir -p ${basedir}
        mkdir -p ${basedir}/{install,scripts,source}
    fi

    cd ${basedir}
    if [ ! -d exawind-builder ] ; then
        git clone git@github.com:sayerhs/exawind-builder.git
    fi
}

exw_init_spack ()
{
    local basedir=${EXAWIND_PROJECT_DIR:-$(pwd)}
    local ewblddir=${basedir}/exawind-builder
    local exwsys=${EXAWIND_SYSTEM:-spack}

    if [ "$(uname)" = "Darwin" ] ; then
       exwsys=osx
    fi

    cd ${basedir}

    # Bail out if this is not our known directory structure
    if [ ! -d ${ewblddir} ] ; then
        echo "!!ERROR!! Please execute command from exawind project directory"
        exit 1
    fi

    local need_setup=no
    if [ ! -d spack ] ; then
        git clone git@github.com:LLNL/spack.git
        need_setup=yes
    fi

    if [ "${need_setup}" = "yes" ] ; then
        echo "==> Setting up spack compiler and package settings"
        local have_packages_yaml=no
        local have_compiler_yaml=no

        if [ -d ${ewblddir}/etc/spack/${exwsys} ] ; then
            local cfgdir=${ewblddir}/etc/spack/${exwsys}
            if [ -f ${cfgdir}/packages.yaml ] ; then
                ln -s ${cfgdir}/packages.yaml spack/etc/spack/
                have_packages_yaml=yes
            fi

            if [ -f ${cfgdir}/compilers.yaml ] ; then
                ln -s ${cfgdir}/compilers.yaml spack/etc/spack/
                have_compiler_yaml=yes
            fi
        fi

        if [ "${have_packages_yaml}" = "no" ] ; then
            ln -s ${ewblddir}/etc/spack/spack/packages.yaml spack/etc/spack
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
    spack install netcdf %${spack_compiler}
    spack install yaml-cpp %${spack_compiler}
    spack install hypre %${spack_compiler}
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

exw_create_config ()
{
    local cfgprefix=${EXAWIND_CFGFILE:-exawind-config}
    local cfgfile=${EXAWIND_PROJECT_DIR}/${cfgprefix}.sh
    if [ -f ${EXAWIND_PROJECT_DIR}/${cfgprefix}.sh ] ; then
        echo "==> Found previous configuration: ${EXAWIND_PROJECT_DIR}/${cfgprefix}.sh"
        return
    fi

    echo "==> Creating default config file: ${EXAWIND_PROJECT_DIR}/${cfgprefix}.sh"
    cat <<EOF > ${EXAWIND_PROJECT_DIR}/${cfgprefix}.sh
#export SPACK_ROOT=${EXAWIND_PROJECT_DIR}/spack
#export SPACK_COMPILER=${SPACK_COMPILER:-${EXAWIND_COMPILER}}

#export EXAWIND_CUDA_WRAPPER=${EXAWIND_PROJECT_DIR}/source/trilinos/packages/kokkos/bin/nvcc_wrapper

#export TRILINOS_ROOT_DIR=${EXAWIND_INSTALL_DIR}/trilinos
#export TIOGA_ROOT_DIR=${EXAWIND_INSTALL_DIR}/tioga

BUILD_TYPE=RELEASE
ENABLE_OPENMP=ON

ENABLE_OPENFAST=OFF
ENABLE_TIOGA=OFF
ENABLE_HYPRE=ON

EOF

    echo "==> Please check auto-generated configuration file: ${cfgfile}"
}

exw_need_spack_setup ()
{
    local no_spack_machines=(peregrine eagle rhodes)
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

    OPTIND=1
    while getopts ":s:c:p:h" opt; do
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
    exw_create_config
}

exw_main "$@"
