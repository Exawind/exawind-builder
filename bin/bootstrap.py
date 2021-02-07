# -*- coding: utf-8 -*-

"""\
ExaWind build bootstrap file
"""

import sys
import os
import glob
import json
import argparse
import subprocess
import shlex
import textwrap
from contextlib import contextmanager

def abspath(pname):
    """Return the absolute path of the directory.

    This function expands the user home directory as well as any shell
    variables found in the path provided and returns an absolute path.

    Args:
        pname (path): Pathname to be expanded
    Returns:
        path: Absolute path after all substitutions
    """
    pth1 = os.path.expanduser(pname)
    pth2 = os.path.expandvars(pth1)
    return os.path.normpath(os.path.abspath(pth2))

def ensure_directory(dname):
    """Check if directory exists, if not, create it.

    Args:
        dname (path): Directory name to check for
    Returns:
        Path: Absolute path to the directory
    """
    abs_dir = abspath(dname)
    if not os.path.exists(abs_dir):
        os.makedirs(abs_dir)
    return abs_dir

@contextmanager
def working_directory(dname, create=False):
    """A with-block to execute code in a given directory.

    Args:
        dname (path): Path to the working directory.
        create (bool): If true, directory is created prior to execution
    Returns:
        path: Absolute path to the execution directory
    """
    abs_dir = abspath(dname)
    if create:
        ensure_directory(abs_dir)

    orig_dir = os.getcwd()
    try:
        os.chdir(abs_dir)
        yield abs_dir
    finally:
        os.chdir(orig_dir)

def clone_repo(repo, basedir, extra_git_args="", recursive=False):
    """Clone a repository"""
    cmd = "git clone %s %s %s"%(
        '--recurse-submodules' if recursive else '',
        extra_git_args, repo)
    print("==> Cloning repo: %s"%cmd)
    cmd_lst = shlex.split(cmd)
    with working_directory(basedir, create=False):
        try:
            subprocess.check_call(cmd_lst)
            return True
        except subprocess.CalledProcessError:
            return False

class Bootstrap:
    """Bootstrap exawind-builder"""

    #: Description for command line help message
    description = "ExaWind Builder"

    #: Default location for installing exawind project
    default_location = os.path.join(os.path.expanduser('~'), "exawind")

    #: Default compiler option
    default_compiler = 'apple-clang' if sys.platform == 'darwin' else 'gcc'

    #: Default name for deps environment
    deps_env = "exawind-deps"

    #: Git repo for exawind-builder
    exw_bld_repo = "https://github.com/exawind/exawind-builder.git"

    #: Spack repo
    spack_repo = "https://github.com/spack/spack.git"

    def __init__(self, args=None):
        """Initialize"""
        self.parser = argparse.ArgumentParser(
            description=self.description)
        self.cli_options()
        if args is None:
            self.args = self.parser.parse_args()
        else:
            self.args = self.parser.parse_args(args)

    def cli_options(self):
        """Command options"""
        parser = self.parser
        parser.add_argument(
            '-p', '--path',
            default=os.getenv('EXAWIND_PROJECT_DIR', self.default_location),
            help="Directory where exawind project is installed")
        parser.add_argument(
            '-s', '--system', default='spack',
            help="System profile to configure (default: spack)")
        parser.add_argument(
            '-c', '--compiler', nargs='+',
            help="Compiler(s) to setup (default: %s)"%self.default_compiler)
        parser.add_argument(
            '--no-install-scripts', action='store_true',
            help="Skip installation of build scripts")
        tpls = parser.add_mutually_exclusive_group()
        tpls.add_argument(
            '--no-install-deps', action='store_true',
            help="Skip installation of dependencies")
        tpls.add_argument(
            '--spec-file', type=str, default=None,
            help="Use custom spack spec file for installing TPLs")
        parser.add_argument(
            '-j', '--num-jobs', type=int, default=0,
            help="Number of build jobs when installing deps")

    def __call__(self):
        self.init_project()
        self.check_system()
        self.setup_spack()
        self.activate_python_env()
        self.spack_setup_compilers()
        self.spack_apply_patch()

        # Handle dependency installation
        self.install_dependencies()
        self.create_build_scripts()

    def init_project(self):
        """Create a skeleton directory structure and fetch exawind-builder"""
        prjdir = abspath(self.args.path)
        if os.path.exists(prjdir):
            print("==> Reusing existing project dir: %s"%prjdir)
        else:
            print("==> Creating ExaWind project structure in %s"%prjdir)

        for pp in "install scripts source".split():
            ensure_directory(os.path.join(prjdir, pp))

        if not os.path.exists(os.path.join(prjdir, "exawind-builder", ".git")):
            success = clone_repo(self.exw_bld_repo, prjdir)
            if not success:
                print("==> ERROR: Cannot clone exawind-builder")
                self.parser.exit(1)
        else:
            print("==> Found exawind-builder in %s"%prjdir)

        self.exawind_dir = prjdir
        self.exw_builder_dir = os.path.join(prjdir, "exawind-builder")

    def check_system(self):
        """Check that the system is a valid system"""
        exw_sys = self.args.system

        with working_directory(os.path.join(self.exw_builder_dir, 'envs')):
            files = glob.glob('*.bash')
            systems = [os.path.splitext(ff)[0] for ff in files]
            if not exw_sys in systems:
                print("==> ERROR: Unknown system requested: %s. Valid options are"%exw_sys)
                for esys in sorted(systems):
                    print("    - %s"%esys)
                self.parser.exit(1)
        self.exw_system = exw_sys

    def setup_spack(self):
        """Clone the spack repository"""
        # User has provided a valid spack repo
        spack_path = os.getenv('SPACK_ROOT')
        valid_spack = (spack_path and
                       os.path.exists(spack_path + '/share/spack/setup-env.sh'))
        if valid_spack:
            print("==> Using spack from SPACK_ROOT: %s"%spack_path)
            self.spack_dir = spack_path
            return

        # Spack directory exists from a previous clone
        spack_path = os.path.join(self.exawind_dir, 'spack')
        if not os.path.exists(spack_path):
            success = clone_repo(self.spack_repo, self.exawind_dir,
                                 "-c advice.detachedHead=false --depth 1")
            if not success:
                print("==> ERROR: Cannot clone spack")
                self.parser.exit(1)
        else:
            print("==> Reusing spack instance: %s"%spack_path)
            self.spack_dir = spack_path
            return

        print("==> Setting up spack environment")
        ensure_directory(spack_path + "/etc/spack/" + sys.platform)

        cfg_files = "config compilers packages modules".split()
        src_base = os.path.join(self.exw_builder_dir, "etc/spack/spack")
        dst_base = os.path.join(spack_path, "etc/spack")

        repos_contents = """
        repos:
          - %s
        """%os.path.join(self.exw_builder_dir, "etc/repos/exawind")
        with open(os.path.join(spack_path, "etc/spack/repos.yaml"), 'w') as fh:
            fh.write(textwrap.dedent(repos_contents))

        for ff in cfg_files:
            fpath = os.path.join(src_base, ff + ".yaml")
            if os.path.exists(fpath):
                os.symlink(fpath, os.path.join(dst_base, ff + ".yaml"))

        sname = 'osx' if sys.platform == 'darwin' else self.exw_system
        cfg_src = os.path.join(self.exw_builder_dir, "etc/spack", sname)
        cfg_dst = os.path.join(spack_path, "etc/spack", sys.platform)
        if sname != "spack":
            for ff in cfg_files:
                fpath = os.path.join(cfg_src, ff + ".yaml")
                if os.path.exists(fpath):
                    os.symlink(fpath, os.path.join(cfg_dst, ff + ".yaml"))

        print("==> Using spack instance: %s"%spack_path)
        self.spack_dir = spack_path

    def activate_python_env(self):
        """Activate ExaWind builder and spack python modules"""
        print("==> Activating spack python modules")
        spack_prefix = self.spack_dir
        spack_lib_path = os.path.join(spack_prefix, "lib", "spack")
        sys.path.insert(0, spack_lib_path)
        spack_external_libs = os.path.join(spack_lib_path, "external")
        sys.path.insert(0, spack_external_libs)

        print("==> Activating ExaWind builder python modules")
        exwbld_bin = os.path.dirname(__file__)
        exwbld_dir = os.path.dirname(exwbld_bin)
        sys.path.insert(0, os.path.join(exwbld_dir, "python"))

    def spack_setup_compilers(self):
        """Ask spack to detect compilers if no pre-existing compilers exist"""
        import spack.config
        scopes = spack.config.scopes().values()
        if any(ff.get_section("compilers") for ff in scopes):
            print("==> Found compiler definitions, skipping 'compiler find'")
        else:
            print("==> No existing compilers, using 'spack compiler find'")
            from exwbld import spack_wrappers as spwrap
            spwrap.spack_cmd("compiler", ["find"])

    def spack_apply_patch(self):
        """Apply any necessary patches for spack on certain systems"""
        sname = 'osx' if sys.platform == 'darwin' else self.exw_system
        patch_path = os.path.join(
            self.exw_builder_dir, "etc", "spack", sname, "spack.patch")
        if not os.path.exists(patch_path):
            return

        from spack.util.executable import which
        with working_directory(self.spack_dir) as wdir:
            git = which("git", required=True)
            git_out = git('describe', '--tags', '--dirty', output=str)
            if (git.returncode == 0) and "dirty" in git_out:
                return

            print("==> Patching spack for machine: %s"%sname)
            patch = which("patch", required=True)
            patch('-s', '-p1', '-i', patch_path, '-d', wdir)

    def install_dependencies(self):
        """Create a spack environment for installing dependencies"""
        if self.args.no_install_deps:
            print("==> Skipping installation of dependencies")
            return

        import spack.environment as ev
        from exwbld import spack_wrappers as spwrap
        args = self.args
        env_name = self.deps_env
        default_deps_spec = os.path.join(
            self.exw_builder_dir, "etc", "spack", "spack", "spack.yaml")
        user_spec_file = abspath(args.spec_file) if args.spec_file else ""
        if user_spec_file and os.path.exists(user_spec_file):
            spec_file = user_spec_file
        else:
            spec_file = default_deps_spec

        if not ev.exists(env_name):
            print("==> Creating exawind deps environment: %s"%env_name)
            print("==> Using spec file: %s"%spec_file)
            spwrap.spack_cmd("env", [
                "create",
                "--without-view",
                env_name,
                spec_file
            ])
        os.environ['EXAWIND_SPACK_COMPILER'] = (
            ' '.join(args.compiler) if args.compiler else self.default_compiler)
        spwrap.spack_cmd("concretize", ['-f'], env=env_name)
        spwrap.spack_cmd("install", [], env=env_name)
        self.deps_env_name = env_name

    def create_build_scripts(self):
        """Create all shell scripts for building projects"""
        if self.args.no_install_scripts:
            print("==> Skipping installation of exawind build scripts")
            return

        from exwbld import paths
        args = dict(
            exawind_dir=self.exawind_dir,
            exawind_builder_dir=self.exw_builder_dir,
            system=self.exw_system)
        compiler = (self.args.compiler
                    if self.args.compiler
                    else [ self.default_compiler ])

        # Get a list of projects
        with working_directory(os.path.join(self.exw_builder_dir, 'codes')):
            files = glob.glob('*.bash')

        escript = paths.get_template("env_script.sh")
        bscript = paths.get_template("build_script.sh")
        codes = (os.path.splitext(ff)[0] for ff in sorted(files))
        with working_directory(os.path.join(self.exawind_dir, "scripts")):
            for cc in compiler:
                env_out = "exawind-config-%s.sh"%cc
                print("==> Creating environment script: %s"%env_out)
                with open(env_out, 'w') as efh:
                    efh.write(escript.render(**args))

                for prj in codes:
                    args['project'] = prj
                    fname = "%s-%s.sh"%(prj, cc)
                    print("==> Creating build script: %s"%fname)
                    with open(fname, 'w') as fh:
                        fh.write(bscript.render(**args))

if __name__ == "__main__":
    boot = Bootstrap()
    boot()
