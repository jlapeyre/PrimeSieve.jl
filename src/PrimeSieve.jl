module PrimeSieve

include("../deps/deps.jl")
import Base: convert, ccall

export countprimes, primes, nprimes, nthprime, pnthprime, primetest

##

# Returned primes have this data type
const LONG_PRIMES = 4
const ULONG_PRIMES = 5

const libname = "primesieve/.libs/libprimesieve.so.4"

# Copy the returned array, and free C array
function primescopy(res,n)
    retv = pointer_to_array(res,n,false)
    nretv = copy(retv)
    ccall((:primesieve_free, libname), Void, (Ptr{Void},), res)
    nretv
end

function countprimes{T,V}(start::T, stop::V)
    (start,stop) = promote(start,stop)
    res = ccall((:primesieve_count_primes,libname),
                Ptr{Uint64}, (Uint64, Uint64),
                convert(Uint64,start), convert(Uint64,stop))
    convert(typeof(start),res)
end

countprimes(stop) = countprimes(one(typeof(stop)),stop)

primetype(::Type{Int64}) = LONG_PRIMES
primetype(::Type{Uint64}) = ULONG_PRIMES

function primes{T,V}(start::T,stop::V)
    (start,stop) = promote(start,stop)
    NT = typeof(start)
    n = Csize_t[0]
    res = ccall((:primesieve_generate_primes, libname),
                Ptr{T}, (Uint64, Uint64, Ptr{Csize_t}, Int),
                convert(Uint64,start),convert(Uint64,stop),n,primetype(typeof(start)))
    primescopy(res,n[1])
end

primes(stop) = primes(one(typeof(stop)),stop)

function nprimes(nin,start)
    n = convert(Int,nin)
    res = ccall((:primesieve_generate_n_primes, libname),
                Ptr{Int64}, (Uint64, Uint64, Int),
                convert(Uint64,n),convert(Uint64,start),LONG_PRIMES)
    primescopy(res,n)
end

nprimes(n) = nprimes(n,one(typeof(n)))

#  @param n  if n = 0 finds the 1st prime >= start,
#            if n > 0 finds the nth prime > start,
#            if n < 0 finds the nth prime < start (backwards).
#  @pre   start <= 2^64 - 2^32 * 11.
for (cname,jname) in ((:(:primesieve_nth_prime), :nthprime),
                      (:(:primesieve_parallel_nth_prime), :pnthprime))
    @eval begin
        function ($jname)(n,start)
            res = ccall(( $cname, libname),
                         Ptr{Uint64}, (Int64, Uint64),
                        convert(Uint64,n),convert(Int64,start))
            convert(Int,res)
        end
        ($jname)(n) = ($jname)(n,one(typeof(n)))        
    end
end

primetest() = ccall((:primesieve_test, libname), Void, ())

end # module PrimeSieve
