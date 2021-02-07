# -*- coding: utf-8 -*-

"""\
Wrapper utilities for running Spack CLI commands

"""

import argparse
import shlex
from spack import cmd, main

def spack_cmd(name, cli_args, **kwargs):
    """Wrapper function to call spack commands from within python scripts

    Example: ``spack_cmd("compiler", ["find"])``

    Args:
        name (str): Name of the spack subcommand
        cli_args (list): A list of command line arguments for subcommand
    """
    parser = main.make_argument_parser()
    cmd_mod = cmd.get_module(name)
    parser.add_command(name)
    cargs = cli_args if isinstance(cli_args, list) else shlex.split(cli_args)
    args = parser.parse_args([name] + cargs)
    for k, v in kwargs.items():
        setattr(args, k, v)
    getattr(cmd_mod, name)(parser, args)
