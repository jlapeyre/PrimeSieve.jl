# Primes

This package provides functions related to prime numbers,
mostly for efficiently generating and counting primes.

See [LICENSE.md](../master/LICENSE.md) for links to the authors of the tables and the libraries
used in this package.

I am unaware of binaries of libprimesieve and libprimecount for Windows and OSX, so these
are not installed automatically.

This is not a registered package, and it has a non-registered dependency. You can install it
(at least on Unix) with

```julia
Pkg.clone("https://github.com/jlapeyre/DeepConvert.jl")
Pkg.clone("https://github.com/jlapeyre/PrimeSieve.jl")
Pkg.build("PrimeSieve")
```

Some functions in this package

* ```genprimes(a,b)```               generate array of primes between ```a``` and ```b```
* ```primepi(n)```               the prime counting function
* ```countprimes(a,b)```          count primes between a and b
* ```nextprime```, ```prevprime```  
* ```someprimes(n1,n2)```, ```allprimes(n)```  iterators
* ```nthprime(n)```   
* ```nprimes(n,start)```     generate array of n primes




This package uses the following tables and libraries.

### Tables

http://www.ieeta.pt/~tos/primes.html

### libprimesieve and libprimecount

http://primesieve.org/

https://github.com/kimwalisch/primecount

### Data types

The tables are encoded in Int128. The native type of the sieve (libprimesieve) is
Uint64. The input/output type of the fastest primepi algorithm in libprimecount, the Deleglise Rivat
algorithm, is Int128. There is a risk of overflow when constructing and giving
arguments to functions in this package. The easiest way to avoid this
is to put arguments in quotes: eg ```countprimes("10^19","10^19+100")```.
Also available are ```@bigint``` and ```@int128``` from DeepConvert.

## Functions

### genprimes

```julia
genprimes(start,stop)
```
Return an array of all primes ```>= start``` and ```<= stop```.

```julia
genprimes(stop)
```
Return an array of all primes between 1 and ```stop```

```julia
genprimes(start,stop; alg = algorithm)
```
Generate primes using a specified algorithm. The algorithm must be
either ```:sieve``` (the default) or ```:next```.  Which algorithm is
more efficient depends on the parameters. In general, ```:sieve``` is
better for larger intervals, and ```:next``` is better for larger values
of ```start```. The keyword ```:sieve``` uses a very fast sieve (libprimesieve), and
```:next``` uses the function ```nextprime```.

If you exceed the upper limit for argument to the sieve, then ```:next```
is chosen automatically.
```julia
julia> @bigint genprimes(10^20, 10^20+1000)
24-element Array{BigInt,1}:
 100000000000000000039 ...
```

This could also have been written ```genprimes(bi"10^20", bi"10^20+1000")```

### primepi

Computes the [prime counting function](http://en.wikipedia.org/wiki/Prime-counting_function).

```julia
primepi(x; alg = algorithm)
```

The efficient algorithms (or methods) are :auto (the default), :dr,
and :tabsieve. The default, :auto, tries to choose the faster between
:dr and :tabsieve (but it is not perfect!). The other algorithms are
slower in all cases. They are: :legendre, :lehmer, :meissel, :lmo,
:sieve.  The algorithm :dr uses an efficient parallel Deleglise Rivat
method. The algorithm :tabsieve uses a combination of tables and a
sieve and is more efficient when x is not too much greater than a
table entry. (Note: Below, 10^14+10^8 is not too much greater than
10^14.) For example

```julia
julia> @time primepi(10^14+10^10; alg = :tabsieve)
elapsed time: 6.622672664 seconds (216 bytes allocated)
3205251958942

julia> @time primepi(10^14+10^10; alg = :dr)            # Deleglise Rivat is faster
elapsed time: 0.495413145 seconds (208 bytes allocated)
3205251958942

julia> @time primepi(10^14+10^8; alg = :dr)
elapsed time: 0.505796298 seconds (208 bytes allocated)
3204944853481

julia> @time primepi(10^14+10^8; alg = :tabsieve)       # Table and sieve is faster
elapsed time: 0.08235147 seconds (216 bytes allocated)
3204944853481
```

### countprimes

Count the number of primes (or
[prime tuplets](http://en.wikipedia.org/wiki/Prime_k-tuple) in an interval. This
looks up the largest value in the table that is smaller than the
requested value and computes the remaining values. Note that ```primepi``` is
logically equivalent to countprimes with ```start=1```. For ```start=1```,
The function ```primepi``` is often much faster than, and is never slower than ```countprimes``` 

```julia
countprimes(stop)            # count the number of primes less than or equal to stop
countprimes(start,stop)      # count the number of primes >= start and <= stop
countprimes([start], stop, tuplet=n) # Count prime n-tuplets
countprimes(start, stop, alg = algorithm) # Count prime n-tuplets
```

The default value of start is 1.  The optional keyword argument
'tuplet' may take values between 1 and 6, that is primes, through
prime sextuplets. Tables are implemented only for 'tuplet' equal to
one, that is for primes, but not tuplets.

The optional keyword argument alg may be one of :tabsieve (the default),
:next, :nexta, or :sieve (:sieve will always be slower than :tabsieve).
As above, ```:tabsieve``` uses a combination of tables and a fast sieve.
:next and :nexta are two different variants of ```next_prime```.

Examples
```julia
countprimes(100,1000)  # the number of primes x satisfying  100 <= x <= 1000
143
countprimes(100,tuplet=3)  # the number of prime triplets between 1 and 100
8
countprimes(10,1000,tuplet=6)  # the number of prime sextuplets between 100 and 1000
1     
```

If you quote the arguments (either as an expression or a string),
they will be converted to Int128. This prevents overflow.
```
countprimes("10^19+10^9")
234057667299198865
```

If you use BigInt's, then the method :nexta will be chosen automatically. For example
```julia
julia> @bigint countprimes(10^50, 10^50+1000)
7
```

### nextprime, prevprime

```nextprime(n)``` returns the smallest prime greater than n.
```prevprime(n)``` returns the largest prime less than n.

Several algorithms are used. Finding the optimal one (of the
available) is partially automated. nextprime1 and prevprime1 use an
alternate algorithm coded by H W Borcher.

### Iterators

```someprimes(n2)``` All primes n, 2 <= n <= n2

```someprimes(n1,n2)``` All primes n, n1 <= n <= n2

```allprimes(n1)``` All primes n, n > n1

```allprimes()``` All primes

For example, here is the [primorial](http://en.wikipedia.org/wiki/Primorial) function defined using an iterator:

```julia
julia> primorial(n) = prod(someprimes(n))
julia> @bigint primorial(100)
2305567963945518424753102147331756070
```

### nthprime()

Returns the nth prime using a fast algorithm from libprimecount.
The argument is converted to Int64.

```nthprime(n; alg = :sieve)``` uses the older algorithm from
libprimesieve, which is much slower.

### nprimes

Return an array of the first ```n``` primes ```>= start```.

Usage
```julia
nprimes(n,[start=1])
```
### single threaded versions

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

### legendrephi

The [legendre sum or phi function](http://mathworld.wolfram.com/LegendresFormula.html)

```julia
legendre(x,a)
```

The arguments are converted to Int64.

### primeLi

The [offset logarithmic integral](http://en.wikipedia.org/wiki/Logarithmic_integral_function).
The argument is converted to Int64.

### PrimeLiinv

The inverse Li function.
The argument is converted to Int64.

### primesievesize

Get, set the sieve size in kilobytes. (setting does not seem to work)
```sz``` must satisfy  ```1 <= sz <= 2048```

Usage
```julia
primesievesize()
primesievesize(sz)
```

### primesieve_num_threads

Get, set the number of threads used in the parallel sieve. By default, the
number of cores is used.

Usage
```julia
primesieve_num_threads()
primesieve_num_threads(numthreads)
```

### primepi_num_threads

Get, set the number of threads used in the parallel primepi. By default, the
number of cores is used.

Usage
```julia
primepi_num_threads()
primepi_num_threads(numthreads)
```

### primemaxstop

Return the largest value (as a ```Uint64```) that can be passed as the parameter
stop in the sieve.

Usage
```julia
primemaxstop()
```

### primepi_xmax()

Function that returns the largest allowed argument to ```primepi``` when using the :dr algorithm.

### primetest

Run a test of the sieve algorithm.

Usage
```julia
primetest()
```

### primepi_test

Run a test of the primepi algorithms

## Tables of prime pi function

The tables work like this:

```julia
julia> @time countprimes(10^17 + 10^14 + 10^10)
elapsed time: 3.729049749 seconds (168 bytes allocated)
2626112053757377
```

To see what happened, we can look in the tables:

```julia
julia> primelookup(10^17 + 10^14 + 10^10)
(14,(2626111798288135,100100000000000000,10000000000))
```

The 14th table was used. The value of prime pi for ```10^17+10^14```,
```2626111798288135``` is in the table, and the primes in an
interval of length ```10^10``` must be found with the sieves.

### primetableinfo

Print information about the prime pi tables.

```julia
julia> primetableinfo()
Tables of π(x). Listed are: table number, increment in x (and first value of x),
number of entries in the table, largest x in table.

table  incr    tab len  max x
1      10^1    10^4     10^5
2      10^2    10^4     10^6
3      10^3    10^4     10^7
4      10^4    10^4     10^8
5      10^5    10^4     10^9
6      10^6    10^4     10^10
7      10^7    10^4     10^11
8      10^8    10^4     10^12
9      10^9    10^4     10^13
10     10^10   10^4     10^14
11     10^11   10^4     10^15
12     10^12   10^4     10^16
13     10^13   10^4     10^17
14     10^14   10^4     10^18
15     10^15   10^4     10^19
16     10^16   10^4     10^20
17     10^17   10^3     10^20
18     10^18   10^2     10^20
19     10^19   10^2     10^21
20     10^20   10^2     10^22
21     10^21   10^2     10^23
22     10^22   10^1     10^23
```

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

### primetables

The array of type ```Array{PrimeTable,1}``` containing the prime tables.
See tables.jl for the format.

Example
```julia
show(map(length,primetables)) # see the number of tables and their lengths
```

### primetablefilename

Function returning the path to the file containing the prime pi tables.
The tables are loaded when the package is loaded.

## Other details

For ```x>typemax(Int)```, you need to explicitly ask for a bigger data type.
For instance,

```julia
julia> countprimes(int128(10)^23)
1925320391606803968923
```

This example returned a value from the table.
The argument was larger than than primemaxstop().


With any of the routines, you can quote the arguments and they will be converted
to the appropriate type.

```julia
julia> countprimes(:(10^23))
1925320391606803968923
julia> countprimes("10^19 + 10^9")
234057667299198865
```

Routines that use the tables will convert the arguments to Int128. This is because
some indices in the tables are greater than ```typemax(Uint64)```.  Routines that
only use the sieve will be converted to ```Uint64```, which is the data type that
the sieve routines use.


The largest stop value that may be given is ```2^64 - 10 * 2^32```.
The largest start value that may be given is ```2^64 - 11 * 2^32```.
The sieve works with the ```Uint64``` data type. But conversions are done depending
on the types of start, stop, and n.

```countprimes``` returns ```Int128```, because it uses tables and sieves
The other routines only support smaller data types.

### primetabletype()

Return data type of tables. This should be Int128. The largest values cannot
be used together with the sieve.

### primesievetype()

Return the native prime sieve type. This should be Uint64. libprimesieve
returns the data in various integer formats. These are chosen by the Julia
interface by the type of the ```start``` parameter.

### eltype(t::PrimeTable)

Return element type of values in table

## Bugs

Interrupting a call to the sieves usually does not cause a memory error.
But, libprimesieve apparently has some static state, such that,
after the interrupt, subsequent sieving runs much slower, and may not
give correct results.

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
<!--  LocalWords:  primemaxstop primetest primetables PrimeTable incr
 -->
<!-- LocalWords:  Oliveira primetableinfo len primetablefilename eltype eg
LocalWords:  primetabletype primesievetype typemax-->
