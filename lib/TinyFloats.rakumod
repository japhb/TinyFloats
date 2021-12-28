unit class TinyFloats:auth<zef:japhb>:api<0>:ver<0.0.3>;


# * bin16 is storage-only, and represented as a uint16 formatted as IEEE 754 binary16
# * bf16 is storage-only, and represented as a uint16 formatted as Google bfloat16
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
        ($inf-nan +& 0x3FF) ?? $inf-nan !! $inf-nan +| $sign
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


sub bf16-from-num($num) is export {
    # bf16 is simply IEEE 754 binary32 with the bottom 16 bits chopped off
    my $bf16 = buf8.write-num32(0, $num).read-uint32(0) +> 16;
    # Force NaN sign bit off due to Windows incompatibility
    $bf16 == 0xFFC0 ?? 0x7FC0 !! $bf16
}

sub num-from-bf16($bf16) is export {
    # bf16 is simply IEEE 754 binary32 with the bottom 16 bits chopped off
    buf8.write-uint32(0, $bf16 +< 16).read-num32(0)
}


=begin pod

=head1 NAME

TinyFloats - Convert to/from tiny float formats

=head1 SYNOPSIS

=begin code :lang<raku>

use TinyFloats;

my $bin16 = bin16-from-num(1e0);     # 0x3C00
my $num   = num-from-bin16(0xFBFF);  # -65504e0

my $bf16  = bf16-from-num(1e0);      # 0x3F80
my $num2  = num-from-bf16(0xFF7F);   # -3.3895313892515355e+38


=end code

=head1 DESCRIPTION

TinyFloats is a collection of simple conversion routines to help with storing
floating point data in tiny float formats.

This version supports only conversion between native nums and the following
16-bit floating point storage formats:

=item C<bin16>
IEEE 754 binary16 format, AKA C<_Float16> in C, C<float16> in CDDL, and
C<7.25> in CBOR

=item C<bf16>
Google Brain bfloat16 format (IEEE 754 binary32 with truncated mantissa)

C<bin16> attempts to balance the reduction in exponent and mantissa bits,
is fairly slow to convert, is used most often in graphics formats, and is
commonly converted to native binary32 internally by modern graphics hardware.

C<bf16> reduces I<only> the mantissa bits, is relatively quick to convert,
is used most often in machine learning systems, and is usually used directly
by the ML hardware.


=head1 AUTHOR

Geoffrey Broadwell <gjb@sonic.net>

=head1 COPYRIGHT AND LICENSE

Copyright 2021 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
