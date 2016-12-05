using Compat

## FIXME: broken from bitrot
## This test used to work. Something changed in a library, or Julia, or something. Now it causes a segfault
#@test( mfactor( BigInt(2)^201-1)  == @compat Dict{BigInt,Int}(7=>1,761838257287=>1,87449423397425857942678833145441=>1,1609=>1,22111=>1,193707721=>1))
#@test( mfactor( @bigint(2^201-1))  == @compat Dict{BigInt,Int}(7=>1,761838257287=>1,87449423397425857942678833145441=>1,1609=>1,22111=>1,193707721=>1))

@test mfactor(10) ==  @compat Dict( 2 => 1, 5 => 1 )

@test mfactor(2^20 - 1) == factor(2^20 - 1)

