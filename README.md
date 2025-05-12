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

TinyFloats is a collection of simple conversion routines to help with storing floating point data in tiny float formats. Raku **cannot** compute with these shorter formats directly; they must first be converted back to native floating point using one of the `num-from-*` routines.

This version supports *only* bidirectional conversion between Raku native floating point numbers (`num`/`num32`/`num64`) and the following shorter floating point storage formats from this table:

<table class="pod-table">
<caption>Formats and Bit Widths</caption>
<thead><tr>
<th>Name</th> <th>Total</th> <th>Exponent</th> <th>Mantissa</th> <th>Max Val</th> <th>±Inf?</th> <th>NaN?</th> <th>Notes</th>
</tr></thead>
<tbody>
<tr> <td>num64</td> <td>64</td> <td>11</td> <td>52</td> <td>~2e+308</td> <td>Y</td> <td>Y</td> <td>Raku native (= num)</td> </tr> <tr> <td>num32</td> <td>32</td> <td>8</td> <td>23</td> <td>~3e+38</td> <td>Y</td> <td>Y</td> <td>Raku native</td> </tr> <tr> <td>bin16</td> <td>16</td> <td>5</td> <td>10</td> <td>65504</td> <td>Y</td> <td>Y</td> <td>IEEE 754 binary16/half</td> </tr> <tr> <td>bf16</td> <td>16</td> <td>8</td> <td>7</td> <td>~3e+38</td> <td>Y</td> <td>Y</td> <td>bfloat16, truncated num32</td> </tr>
</tbody>
</table>

More details on the supported formats:

  * `num64`/`num`

IEEE 754 `binary64` ("double precision") format, AKA `double` in C, `float64` in CDDL, and `7.27` in CBOR. Natively handled in Raku; unless specified otherwise, all floating point computation in Raku is done in this format.

  * `num32`

IEEE 754 `binary32` ("single precision") format, AKA `float` in C, `float32` in CDDL, and `7.26` in CBOR. Natively handled in Raku, but used in Raku computations only if specifically requested. This is also used as an intermediate format when expanding the shorter formats using one of the `num-from-*` routines.

  * `bin16`

IEEE 754 `binary16` ("half precision") format, AKA `_Float16` in C, `float16` in CDDL, and `7.25` in CBOR. `bin16` attempts to balance the reduction in exponent and mantissa bits, is fairly slow to convert, is used most often in graphics formats, and is commonly converted to native binary32 internally by modern graphics hardware.

  * `bf16`

Google Brain `bfloat16` format, essentially IEEE 754 `binary32` ("single precision") with the least significant 16 bits truncated from the mantissa. `bf16` reduces *only* the mantissa bits, is relatively quick to convert, is used most often in machine learning systems, and is usually supported directly by the ML hardware.

AUTHOR
======

Geoffrey Broadwell <gjb@sonic.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2021,2025 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

