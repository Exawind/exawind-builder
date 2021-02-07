# -*- coding: utf-8 -*-

"""\
Exawind paths
"""

import os
from llnl.util.filesystem import ancestor
import jinja2

_exw_bld_dir = ancestor(__file__, 3)
_templates_env = jinja2.Environment(
    loader=jinja2.PackageLoader('exwbld', 'templates'))

def exawind_dir():
    """Absolute path to exawind directory"""
    return os.getenv('EXAWIND_PROJECT_DIR',
                     os.path.dirname(_exw_bld_dir))

def exawind_builder_dir():
    """Absolute path to exawind-builder dir"""
    return os.getenv('EXAWIND_SRCDIR', _exw_bld_dir)

def exawind_scripts_dir():
    """Path to exawind/scripts"""
    return os.path.join(exawind_dir(), "scripts")

def exawind_install_dir():
    """Path to exawind/install"""
    return os.path.join(exawind_dir(), "install")

def exawind_source_dir():
    """Path to exawind/source"""
    return os.path.join(exawind_dir(), "source")

def get_template(fname):
    """Return a template"""
    return _templates_env.get_template(fname)
