unit class TinyFloats:auth<zef:japhb>:api<0>:ver<0.0.1>;


# * bin16 is storage-only, and represented as a uint16 formatted as IEEE 754 binary16
# * num is a native float, represented during processing as a uint32 formatted as
#   IEEE 754 binary32


sub bin16-from-num($num) is export {
    my $uint = buf8.write-num32(0, $num).read-uint32(0);
    my $sign = ($uint +& 0x80000000) +> 16;
    my $exp  =  $uint +& 0x7F800000;

    # Below bin16 subnormal; drop to (signed) zero
    if    $exp < 0x33800000 {  # 2 ** -24
        $sign
    }
    # Below bin16 normal; drop to subnormal
    elsif $exp < 0x38800000 {  # 2 ** -14
        my $mant = ($uint +& 0x7FE000) +| 0x800000;
        ($mant +> (23 - (($exp - 0x33800000) +> 23))) +| $sign
    }
    # Normal range; bitpack
    elsif $exp < 0x47800000 {
        ((($exp - 0x38000000) +| ($uint +& 0x7FE000)) +> 13) +| $sign
    }
    # 32-bit Inf or NaN
    elsif $exp == 0x7F800000 {
        my $inf-nan = (($uint +& 0x7FE000) +> 13) +| 0x7C00;
        # Use sign bit for Inf only, not NaN due to Windows incompatibility
        $inf-nan +& 0x3FF ?? $inf-nan !! $inf-nan +| $sign
    }
    # 16-bit Inf
    else {
        0x7C00 +| $sign
    }
}


sub num-from-bin16($bin16) is export {
    # Algorithm:
    # * Separate the sign bit
    # * If exponent is non-zero:
    #   * Shift exponent and mantissa into proper bit position
    #   * Rebias exponent
    #   * Fix up Inf/NaN bit patterns
    #   * Bring back sign bit, shifted into proper place
    #   * Convert from bit pattern to native num
    # * Else if exponent is zero:
    #   * Absolute value is mantissa divided by 1024e0
    #   * Use correct sign

    my $sign = $bin16 +& 0x8000;

    # Non-zero exponent: Normal, NaN, or Inf
    if $bin16 +& 0x7C00 {
        my $rest = ($bin16 +& 0x7FFF) +< 13 + 0x38000000;
        $rest = $rest +| 0x38000000 if $rest >= 0x47800000;
        buf8.write-uint32(0, $rest +| ($sign +< 16)).read-num32(0)
    }
    # Zero exponent: Zero or subnormal
    else {
        my $abs = ($bin16 +& 0x03FF) / 16777216e0;
        $sign ?? -$abs !! $abs
    }
}


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
