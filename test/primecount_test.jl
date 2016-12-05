## FIXME: broke from bitrot.
#@test typeof(primepi("10")) == Int128

@test typeof(primepi(10)) == Int128

@test nextprime(0) == 2
@test nextprime(2) == 3
@test prevprime(3) == 2
@test prevprime(2) == 0
@test nextprime(prevprime(nextprime(@bigint 10^100))) == nextprime(@bigint 10^100)

## FIXME: broke from bitrot
##@test genprimes(10^6; alg = :sieve) == genprimes(10^6; alg = :next)

@test nextprime(2^20) == nextprime(BigInt(2^20))
@test prevprime(2^20) == prevprime(BigInt(2^20))
