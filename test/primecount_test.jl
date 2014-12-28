@test typeof(primepi("10")) == Int128

@test nextprime(0) == 2
@test genprimes(10^6; alg = :sieve) == genprimes(10^6; alg = :next)
