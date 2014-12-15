# PrimeSieve

[![Build Status](https://travis-ci.org/jlapeyre/PrimeSieve.jl.svg?branch=master)](https://travis-ci.org/jlapeyre/PrimeSieve.jl)

This package provides an interface to tables of primes and a sieve library.
It is very fast, in particular the prime pi function, which is complemented
by table lookup. There are multi-threaded and single-threaded versions of
most functions.

See LICENSE.md for links to the authors of the tables and the library

## countprimes

Count the number of primes in an interval. This looks up the nearest tabulated
value and computes the remaining values. This is the only function in the
package that uses tables.

Usage:
```julia
countprimes(stop)            # count the number of primes less than or equal to stop
countprimes(start,stop)      # count the number of primes >= start and <= stop
ntcountprimes([start],stop)  # Do not use table lookup, only sieving
```

## primes

Return an array of all primes >= start and <= stop

Usage
```julia
primes([start=1],stop)
```

## nprimes

Return an array of the first n primes >= start.

Usage
```julia
nprimes(n,[start=1])
```

## countprimes2, countprimes3, countprimes4, countprimes5, countprimes6

Count the number of prime twins, triplets, quadruplets, quintuplets, and sextuplets
that are >= start and <= stop

Usage
```julia
countprimes2([start=1],stop)
```

## single threaded versions

Prepending 's' to the function name of any of the above routines
calls a single-threaded version. There is no routine 'sntcountprimes'
and 'scountprimes' does not use tables.

Usage
```julia
scountprimes([start=1],stop)
```

## printprimes2, printprimes3, printprimes4, printprimes5, printprimes6

Print all prime twins, triplets, quadruplets, quintuplets, and sextuplets
that are >= start and <= stop

Usage
```julia
printprimes2([start=1],stop)
```


## primesievesize

Get, set the sieve size in kilobytes. (setting does not seem to work)
sz must satisfy  1 <= sz <= 2048

Usage
```julia
primesievesize()
primesievesize(sz)
```

## primenumthreads

Get, set the number of threads used in parallel routines. By default, the
OMP default is used.

Usage
```julia
primenumthreads()
primenumthreads(numthreads)
```

## primemaxstop

Return the largest value (as a Uint64) that can be passed as the parameter
stop.

Usage
```julia
primemaxstop()
```

## primetest

Run a test of the algorithms

Usage
```julia
primetest()
```

# Other details

The largest stop value that may be given is 2^64 - 10 * s^32.
The largest start value that may be given is 2^64 - 11 * s^32.
The sieve works with the Uint64 data type. But conversions are done depending
on the types of start, stop, and n.

'countprimes' returns Int128. The other routines only support smaller data types.
