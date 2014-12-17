# PrimeSieve

[![Build Status](https://travis-ci.org/jlapeyre/PrimeSieve.jl.svg?branch=master)](https://travis-ci.org/jlapeyre/PrimeSieve.jl)

This package provides an interface to tables of primes and a sieve library.
It is extremely fast, in particular the prime pi function, which is complemented
by table lookup. There are multi-threaded and single-threaded versions of
most functions.

See LICENSE.md for links to the authors of the tables and the library. All
the credit for the utility of this package goes to them.

I am unaware of binaries of libprimesieve for Windows and OSX, so these
are not installed automatically.

### Tables

http://www.ieeta.pt/~tos/primes.html

### Primesieve

http://primesieve.org/

### Example

```julia
julia> using PrimeSieve

julia> @time countprimes(10^17 + 10^10)
elapsed time: 3.76604437 seconds (152 bytes allocated)
2623557413135520
```

To see what happened, we can look in the tables:

```julia
julia> primelookup(10^17 + 10^10)
(14,(2623557157654233,100000000000000000,10000000000))
```

The 14th table was used. The value of prime pi for ```10^17```,
```2623557157654233``` is in the table, and the primes in an
interval of length ```10^10``` must be found with the sieves.

See the description of ```primelookup``` below.


### countprimes

Count the number of primes (or prime tuplets) in an interval. This
looks up the nearest tabulated value and computes the remaining
values. This is the only function in the package that uses tables.

Usage:
```julia
countprimes(stop)            # count the number of primes less than or equal to stop
countprimes(start,stop)      # count the number of primes >= start and <= stop
ntcountprimes([start],stop)  # Do not use table lookup, only sieving
countprimes([start], stop, tuplet=n) # Count prime n-tuplets
```

The default value of start is 1.
The optional keyword argument 'tuplet' may take values between 1 and 6, that is
primes, through prime sextuplets.

Examples
```julia
countprimes(100)  # the number of primes x such that  1 <= x <= 100
25
countprimes(100,tuplet=3)  # the number of prime triplets between 1 and 100
8
countprimes(10,1000,tuplet=6)  # the number of prime sextuplets between 100 and 1000
1     
```

### genprimes

Return an array of all primes ```>= start``` and ```<= stop```

Usage
```julia
genprimes([start=1],stop)
```

### nprimes

Return an array of the first ```n``` primes ```>= start```.

Usage
```julia
nprimes(n,[start=1])
```
### single threaded versions

Prepending 's' to the function name of any of the above functions
calls a single-threaded version. There is no routine ```sntcountprimes```
and ```scountprimes``` does not use tables.

Usage
```julia
scountprimes([start],stop, tuplets=1)
```

### printprimes

Print all primes (or prime n-tuplets) that are ```>= start``` and ```<= stop```

Usage
```julia
printprimes([start],stop, [tuplet=1])
```

The default value of 'start' is 1.
The optional keyword argument 'tuplet' may take values between 1 and 6.

### primelookup

Look up a value of the prime pi function in the tables. This is only provided
to aid in understanding the behavior of ```countprimes```.

Usage
```julia
primelookup(x)
```

A tuple of a single element and another tuple of three elements is returned:

```julia
(j,(p,y,rem))
```
* ```j``` is the number of the best table found
* ```y``` is the largest index satisfying ```y<x``` found.
* ```p``` is the value of prime pi at ```y```
* ```rem``` is ```x-y```


### primesievesize

Get, set the sieve size in kilobytes. (setting does not seem to work)
```sz``` must satisfy  ```1 <= sz <= 2048```

Usage
```julia
primesievesize()
primesievesize(sz)
```

### primenumthreads

Get, set the number of threads used in parallel routines. By default, the
OMP default is used.

Usage
```julia
primenumthreads()
primenumthreads(numthreads)
```

### primemaxstop

Return the largest value (as a ```Uint64```) that can be passed as the parameter
stop.

Usage
```julia
primemaxstop()
```

### primetest

Run a test of the algorithms

Usage
```julia
primetest()
```

### primetables

The array of type ```Array{PrimeTable,1}``` containing the prime tables.
See tables.jl for the format.

## Other details

The largest stop value that may be given is ```2^64 - 10 * 2^32```.
The largest start value that may be given is ```2^64 - 11 * 2^32```.
The sieve works with the ```Uint64``` data type. But conversions are done depending
on the types of start, stop, and n.

```countprimes``` returns ```Int128```. The other routines only support smaller data types.

<!--  LocalWords:  PrimeSieve lookup multi md libprimesieve OSX julia
 -->
<!--  LocalWords:  Primesieve countprimes primelookup th tuplets sz
 -->
<!--  LocalWords:  ntcountprimes tuplet genprimes nprimes Prepending
 -->
<!--  LocalWords:  sntcountprimes scountprimes printprimes tuple OMP
 -->
<!--  LocalWords:  primesievesize primenumthreads numthreads Uint jl
 -->
<!--  LocalWords:  primemaxstop primetest primetables PrimeTable
 -->
