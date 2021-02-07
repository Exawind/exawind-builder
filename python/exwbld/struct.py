# -*- coding: utf-8 -*-
# pylint: disable=too-many-ancestors,bad-continuation,signature-differs,no-else-return

"""\
Struct - an attribute dictionary
--------------------------------

"""

__all__ = ["Struct"]

from abc import ABCMeta
from collections import OrderedDict
from collections.abc import MutableMapping, Mapping
import json
import ruamel.yaml as yaml

def _merge(this, that):
    """Recursive merge from *that* mapping to *this* mapping

    A utility function to recursively merge entries. New entries are added, and
    existing entries are updated.

    Args:
        this (dict): Mapping that is updated
        that (dict): Mapping to be merged. Unmodified within the function
    """
    this_keys = frozenset(this)
    that_keys = frozenset(that)

    # Items only in 'that' dict
    for k in (that_keys - this_keys):
        this[k] = that[k]

    for k in (this_keys & that_keys):
        vorig = this[k]
        vother = that[k]

        if (isinstance(vorig, Mapping) and
            isinstance(vother, Mapping) and
            (id(vorig) != id(vother))):
            _merge(vorig, vother)
        else:
            this[k] = vother

def merge(a, b, *args):
    """Recursively merge mappings and return consolidated dict.

    Accepts a variable number of dictionary mappings and returns a new
    dictionary that contains the merged entries from all dictionaries. Note
    that the update occurs left to right, i.e., entries from later dictionaries
    overwrite entries from preceeding ones.

    Returns:
        dict: The consolidated map
    """
    out = a.__class__()
    _merge(out, a)
    _merge(out, b)

    for c in args:
        _merge(out, c)

    return out

def gen_yaml_decoder(cls):
    """Generate a custom YAML decoder with non-default mapping class

    Args:
        cls: Class used for mapping
    """
    def struct_constructor(loader, node):
        """Custom constructor for Struct"""
        return cls(loader.construct_pairs(node))

    class StructYAMLLoader(yaml.SafeLoader):
        """Custom YAML loader for Struct data"""

        def __init__(self, *args, **kwargs):
            yaml.Loader.__init__(self, *args, **kwargs)
            self.add_constructor(
                yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
                struct_constructor)

    return StructYAMLLoader

def gen_yaml_encoder(cls):
    """Generate a custom YAML dumper for Struct and subclasses.

    Args:
        cls: Class used for mappping
    """
    def struct_representer(dumper, data):
        """Convert Struct to YAML dictionary"""
        return dumper.represent_dict(list(data.items()))

    class StructYAMLDumper(yaml.SafeDumper):
        """Custom YAML dumper for Struct data"""

        def __init__(self, *args, **kwargs):
            yaml.Dumper.__init__(self, *args, **kwargs)
            self.add_representer(cls,
                                 struct_representer)

        def represent_data(self, data):
            return super(StructYAMLDumper, self).represent_data(data)

    return StructYAMLDumper

class _StructMeta(ABCMeta):
    """Custom YAML/JSON loader/dumper registration.

    Enable custom registration of YAML/JSON readers and writers before the
    class creation.
    """

    def __new__(mcls, name, bases, cdict):
        yload = cdict.pop("yaml_loader", None)
        ydump = cdict.pop("yaml_dumper", None)
        cls = super(_StructMeta, mcls).__new__(mcls, name, bases, cdict)
        cls.yaml_loader = yload or gen_yaml_decoder(cls)
        cls.yaml_dumper = ydump or gen_yaml_encoder(cls)
        return cls

class Struct(OrderedDict, MutableMapping, metaclass=_StructMeta):
    """An attribute dictionary

    A dictionary mapping data structure that allows both key and attribute
    access. The class is inspired by Matlab's ``struct`` data structure. The
    mapping has the following properties:

      #. Preserves ordering of members as initialized (subclassed from
         OrderedDict).

      #. Key and attribute access. Attribute access is limited to keys that are
         valid python variable names.

      #. Import/export from JSON and YAML formats.

    """

    @classmethod
    def from_yaml(cls, stream):
        """Initialize mapping from a YAML string.

        Args:
            stream: A string or valid file handle

        Returns:
            Struct: YAML data as a python object
        """
        return cls(yaml.load(stream, Loader=cls.yaml_loader))

    @classmethod
    def load_yaml(cls, filename):
        """Load a YAML file

        Args:
            filename (str): Absolute path to YAML file

        Returns:
            Struct: YAML data as python object
        """
        with open(filename, 'r') as fh:
            return cls.from_yaml(fh)

    @classmethod
    def from_json(cls, stream):
        """Initialize mapping from a JSON string/stream"""
        if isinstance(stream, str):
            obj = json.loads(stream, object_pairs_hook=cls)
        else:
            obj = json.load(stream, object_pairs_hook=cls)
        return obj

    @classmethod
    def load_json(cls, filename):
        """Initialize dictionary from JSON input file

        Args:
            filename (path): Absolute path to the JSON file
        """
        with open(filename, 'r') as fh:
            return cls.from_json(fh)

    @classmethod
    def load_file(cls, filename):
        """Load a file based on extension type

        Args:
            filename (path): A filename with one of the valid extension types
        """
        fmap = {
            ".yaml": cls.load_yaml,
            ".yml": cls.load_yaml,
            ".json": cls.load_json
        }
        _, ftype = os.path.splitext(filename)
        if ftype not in fmap:
            raise ValueError("Unknown filetype specified: %s"%ftype)
        return fmap[ftype](filename)

    @classmethod
    def as_struct(cls, obj):
        """Return as Struct object if not already a Struct"""
        if isinstance(obj, cls):
            return obj

        assert isinstance(obj, Mapping), "Cannot convert non-dictionary type"
        return cls(**obj)

    def _getattr(self, key):
        return super(Struct, self).__getattribute__(key)

    def _setattr(self, key, value):
        super(Struct, self).__setattr__(key, value)

    def __setitem__(self, key, value):
        if (isinstance(value, Mapping) and
            not isinstance(value, Struct)):
            out = self.__class__()
            _merge(out, value)
            super(Struct, self).__setitem__(key, out)
        else:
            super(Struct, self).__setitem__(key, value)

    def __setattr__(self, key, value):
        # Workaround for Python 2.7 OrderedDict
        if not key.startswith('_OrderedDict'):
            self[key] = value
        else:
            super(Struct, self).__setattr__(key, value)

    def __getattr__(self, key):
        if key not in self:
            raise AttributeError("No attribute named "+key)
        else:
            return self[key]

    def merge(self, *args):
        """Recursively update dictionary

        Merge entries from maps provided such that new entries are added and
        existing entries are updated.
        """
        for other in args:
            _merge(self, other)

    def to_yaml(self, stream=None, default_flow_style=False, **kwargs):
        """Convert mapping to YAML format.

        Args:
            stream (file): A file handle where YAML is output

            default_flow_style (bool):
                - False - pretty printing
                - True  - No pretty printing
        """
        return yaml.dump(self, stream=stream,
                         Dumper=self.__class__.yaml_dumper,
                         default_flow_style=default_flow_style,
                         **kwargs)

    def to_json(self, stream=None, indent=2, **kwargs):
        """Convert mapping to JSON format

        Args:
            stream (file): A file handle for output
            indent (int): Default indentation (use None for compressed)

        Returns:
            str or None: If stream is a file, returns None.
                Otherwise, returns the JSON structure as string
        """
        if stream:
            json.dump(self, stream, indent=indent, **kwargs)
        else:
            return json.dumps(self, indent=indent, **kwargs)

    def walk(self, _node=("root", )):
        """Yields (key, value) pairs by recursively iterating the mapping.

        The keys yielded are tuples containing the list of the keys necessary
        to access this particular entry in the dictionary hierarcy.

        Args:
            node (tuple): A tuple indicating the root mapping

        Examples:

            >>> mydict = Struct(a=1, b=2, c=Struct(x=[10, 20, 100]))
            >>> for k, v in mydict.walk():
            ...     print (k, v)
        """
        for key, value in self.items():
            node = _node + (key,) if _node else (key,)
            if isinstance(value, Struct):
                for kk, vv in value.walk(node):
                    yield kk, vv
            else:
                yield node, value

    def pget(self, path, sep="."):
        """Get value from a nested dictionary entry.

        A convenience method that serves various purposes:

          - Access values from a deeply nested dictionary if any of the keys
            are not valid python variable names.

          - Return None if any of the intermediate keys are missing. Does not
            raise AttributeError.

        By default, the method uses the ``.`` character to split keys similar
        to attribute access. However, this can be overridden by providing and
        extra ``sep`` argument.

        Args:
            path (str): The keys in individual dictionarys separated by sep
            sep (str): Separator for splitting keys (default: ".")

        Returns:
            Value corresponding to the key, or None if any of the keys
              don't exist.
        """
        key_clean = path.strip().strip(sep)
        key_list = key_clean.split(sep)

        rhs = self
        for k in key_list:
            rhs = rhs.get(k, None)
            if rhs is None:
                return None
        return rhs

    def pset(self, path, value, sep="."):
        """Set value for a nested dictionary entry.

        A convenience method to set values in a nested mapping hierarchy
        without individually creating the intermediate dictionaries. Missing
        intermediate dictionaries will automatically be created with the same
        mapping class as the class of ``self``.

        Args:
            path (str): The keys in individual dictionaries separated by sep
            value (object): Object assigned to innermost key
            sep (str): Separator for splitting keys (default: ".")

        Raises:
            AttributeError: If the object assigned to is a non-mapping type
              and not the final key.
        """
        key_clean = path.strip().strip(sep)
        key_list = key_clean.split(sep)
        cls = self.__class__
        lhs = self

        for k in key_list[:-1]:
            lhs = lhs.setdefault(k, cls())
        lval = lhs.get(key_list[-1], None)
        if hasattr(lval, "merge"):
            lval.merge(value)
        else:
            lhs[key_list[-1]] = value
