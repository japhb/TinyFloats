[![Actions Status](https://github.com/japhb/TinyFloats/workflows/test/badge.svg)](https://github.com/japhb/TinyFloats/actions)

NAME
====

TinyFloats - Convert to/from tiny float formats

SYNOPSIS
========

```raku
use TinyFloats;

my $bin16 = bin16-from-num(1e0);     # 0x3C00
my $num   = num-from-bin16(0xFBFF);  # -65504e0
```

DESCRIPTION
===========

TinyFloats is a collection of simple conversion routines to help with storing floating point data in tiny float formats.

This very first version supports only conversion between native nums and the IEEE 754 binary16 format, AKA `_Float16` in C, `float16` in CDDL, and `7.25` in CBOR.

AUTHOR
======

Geoffrey Broadwell <gjb@sonic.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

