# Tests that take more time to run

@test ntcountprimes("10^19", "10^19+10^6") == 23069

# fixed overflow bugs
@test countprimes(int128(10)^19,int128(10)^19+10^3) == 28
@test countprimes(int128(10)^19+10^9) == int128(234057667299198865)
@test countprimes("10^19 + 10^9") == 234057667299198865
