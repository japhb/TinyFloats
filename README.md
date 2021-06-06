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

my $bf16  = bf16-from-num(1e0);      # 0x3F80
my $num2  = num-from-bf16(0xFF7F);   # -3.3895313892515355e+38
```

DESCRIPTION
===========

TinyFloats is a collection of simple conversion routines to help with storing floating point data in tiny float formats.

This version supports only conversion between native nums and the following 16-bit floating point storage formats:

  * `bin16` IEEE 754 binary16 format, AKA `_Float16` in C, `float16` in CDDL, and `7.25` in CBOR

  * `bf16` Google Brain bfloat16 format (IEEE 754 binary32 with truncated mantissa)

`bin16` attempts to balance the reduction in exponent and mantissa bits, is fairly slow to convert, is used most often in graphics formats, and is commonly converted to native binary32 internally by modern graphics hardware.

`bf16` reduces *only* the mantissa bits, is relatively quick to convert, is used most often in machine learning systems, and is usually used directly by the ML hardware.

AUTHOR
======

Geoffrey Broadwell <gjb@sonic.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

