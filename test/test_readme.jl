# Examples from README.md

@test length(@bigint(genprimes(10^20, 10^20+1000))) == 24
@test length(genprimes(bi"10^20", bi"10^20+1000")) == 24
@test primepi(10^14+10^10; alg = :tabsieve) == 3205251958942
@test primepi(10^14+10^10; alg = :dr) == 3205251958942
@test primepi(10^14+10^8; alg = :dr) == 3204944853481
@test primepi(10^14+10^8; alg = :tabsieve) == 3204944853481
@test countprimes(100,1000) == 143
@test countprimes(100,tuplet=3) == 8
@test countprimes(10,1000,tuplet=6) == 1
res = countprimes("10^19+10^9")
@test res == 234057667299198865
@test typeof(res) == Int128
@test @bigint(countprimes(10^50, 10^50+1000)) == 7
@test primelookup(10^17 + 10^14 + 10^10) == (14,(2626111798288135,100100000000000000,10000000000))
primorial(n) = prod(someprimes(n))
@test @bigint(primorial(100)) == 2305567963945518424753102147331756070
