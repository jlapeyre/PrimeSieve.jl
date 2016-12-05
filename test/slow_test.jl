# Tests that take more time to run

## FIXME: bitrot, returns unsigned int, must be converted to int
## test passes, but we should not have to to conversion
@test convert(Int,ntcountprimes("10^19", "10^19+10^6")) == 23069

# fixed overflow bugs
@test countprimes(Int128(10)^19, Int128(10)^19+10^3) == 28
@test countprimes(Int128(10)^19+10^9) == Int128(234057667299198865)
## FIXME: bitrot, sign error
##@test countprimes("10^19 + 10^9") == 234057667299198865
