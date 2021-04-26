unit class TinyFloats:auth<zef:japhb>:api<0>:ver<0.0.1>;


=begin pod

=head1 NAME

TinyFloats - Convert to/from tiny float formats

=head1 SYNOPSIS

=begin code :lang<raku>

use TinyFloats;

my $bin16 = bin16-from-num(1e0);     # 0x3C00
my $num   = num-from-bin16(0xFBFF);  # -65504e0


=end code

=head1 DESCRIPTION

TinyFloats is a collection of simple conversion routines to help with storing
floating point data in tiny float formats.

This very first version supports only conversion between native nums and the
IEEE 754 binary16 format, AKA `_Float16` in C, `float16` in CDDL, and `7.25`
in CBOR.


=head1 AUTHOR

Geoffrey Broadwell <gjb@sonic.net>

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
