module PrimeSieve

include("../deps/deps.jl")
import Base: convert, ccall

export genprimes, nprimes
export snthprimea

export ntcountprimes
export countprimes, scountprimes
# export countprimes2, scountprimes2
# export countprimes3, scountprimes3
# export countprimes4, scountprimes4
# export countprimes5, scountprimes5
# export countprimes6, scountprimes6

export printprimes
export printprimes2
export printprimes3
export printprimes4
export printprimes5
export printprimes6

export primesievesize, primetest, primesieve_num_threads

##

include("deepconvert.jl")
include("nextprime.jl")
include("primesieve_c.jl")
include("primecount_c.jl")
include("tables.jl")
include("wrappers.jl")
include("tuples.jl")
include("primeit.jl")

end # module PrimeSieve
