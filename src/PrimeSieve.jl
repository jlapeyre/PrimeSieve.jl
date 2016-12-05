## This must come before the "module" (until we find out why)
using DeepConvert

module PrimeSieve

using Compat
using Primes


import DeepConvert: @mkdeepconvert, @bigint

include("../deps/deps.jl")
import Base: convert, ccall

export genprimes, nprimes
export snthprimea
export ntcountprimes
export countprimes, scountprimes

export printprimes
export printprimes2
export printprimes3
export printprimes4
export printprimes5
export printprimes6

export primesievesize, primetest, primesieve_num_threads

##

# Convert numbers to Int128 or UInt64, hopefully the subexpressions
# have not overflowed.  Eg. 10^19.
# Unquoted expressions pass through
@mkdeepconvert(conv128,Int128)
@mkdeepconvert(convu64,UInt64)
@mkdeepconvert(convint,Int64)
macro i128_str(s) conv128(s) end

#include("deepconvert.jl")
include("nextprime.jl")
include("primesieve_c.jl")
include("primecount_c.jl")
include("tables.jl")
include("wrappers.jl")
include("tuples.jl")
include("primeit.jl")
include("randprime.jl")
include("msieve.jl")
include("primesieve_c_extra.jl")
include("gaussian.jl")
include("jacobi.jl")

end # module PrimeSieve
