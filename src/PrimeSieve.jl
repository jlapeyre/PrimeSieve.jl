module PrimeSieve

include("../deps/deps.jl")
import Base: convert, ccall

export primes, nprimes, nthprime, pnthprime
export countprimes, pcountprimes
export countprimes2, pcountprimes2
export countprimes3, pcountprimes3
export countprimes4, pcountprimes4
export countprimes5, pcountprimes5
export countprimes6, pcountprimes6
export primetest

##

const stoplimit = uint64(2)^64 - uint64(2)^32 * uint64(10)
const startlimit = uint64(2)^64 - uint64(2)^32 * uint64(11)

checkstop(val) = val <= stoplimit ? true : error("stop value ", val, " is greater than limit: ", val)
checkstart(val) = val <= startlimit ? true : error("start value ", val, " is greater than limit: ", val)

# Returned primes have this data type
const SHORT_PRIMES = 0
const USHORT_PRIMES = 1
const INT_PRIMES = 2
const UINT_PRIMES = 3
const LONG_PRIMES = 4
const ULONG_PRIMES = 5
const LONGLONG_PRIMES = 6
const ULONGLONG_PRIMES = 7

for (ctype,typecode) in ((:Cshort, :SHORT_PRIMES),(:Cushort, :USHORT_PRIMES),
                         (:Cint, :INT_PRIMES),(:Cuint, :UINT_PRIMES),
                         (:Clong, :LONG_PRIMES),(:Culong, :ULONG_PRIMES),
                         (:Clonglong, :LONGLONG_PRIMES),(:Culonglong, :ULONGLONG_PRIMES))
    @eval begin
        primetype(::Type{$ctype}) = $typecode
    end
end

const libname = "primesieve/.libs/libprimesieve.so.4"

# Copy the returned array, and free C array
function primescopy(res,n)
    retv = pointer_to_array(res,n,false)
    nretv = copy(retv)
    ccall((:primesieve_free, libname), Void, (Ptr{Void},), res)
    nretv
end

function primes{T,V}(start::T,stop::V)
    checkstop(stop)
    n = Csize_t[0]
    res = ccall((:primesieve_generate_primes, libname),
                Ptr{T}, (Uint64, Uint64, Ptr{Csize_t}, Int),
                convert(Uint64,start),convert(Uint64,stop),n,primetype(T))
    primescopy(res,n[1])
end

primes(stop) = primes(one(typeof(stop)),stop)

function nprimes{T}(n::T,start)
    checkstop(start) # not sure what he means here
    res = ccall((:primesieve_generate_n_primes, libname),
                Ptr{T}, (Uint64, Uint64, Int),
                convert(Uint64,n),convert(Uint64,start),primetype(T))
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
        function ($jname){T}(n,start::T)
            checkstart(start)
            res = ccall(( $cname, libname),
                         Ptr{Uint64}, (Int64, Uint64),
                        convert(Int64,n),convert(Uint64,start))
            convert(T,res)
        end
        ($jname)(n) = ($jname)(n,1)
    end
end

for (cname,jname) in (
                      (:(:primesieve_count_primes), :countprimes),
                      (:(:primesieve_count_twins), :countprimes2),
                      (:(:primesieve_count_triplets), :countprimes3),
                      (:(:primesieve_count_quadruplets), :countprimes4),
                      (:(:primesieve_count_quintuplets), :countprimes5),
                      (:(:primesieve_count_sextuplets), :countprimes6),

                      (:(:primesieve_parallel_count_primes), :pcountprimes),
                      (:(:primesieve_parallel_count_twins), :pcountprimes2),
                      (:(:primesieve_parallel_count_triplets), :pcountprimes3),
                      (:(:primesieve_parallel_count_quadruplets), :pcountprimes4),
                      (:(:primesieve_parallel_count_quintuplets), :pcountprimes5),
                      (:(:primesieve_parallel_count_sextuplets), :pcountprimes6))
    @eval begin
        function ($jname){T,V}(start::T, stop::V)
            checkstop(stop)
            (start,stop) = promote(start,stop)
            res = ccall(($cname,libname),
                        Ptr{Uint64}, (Uint64, Uint64),
                        convert(Uint64,start), convert(Uint64,stop))
            convert(typeof(start),res)
        end
        ($jname)(stop) = ($jname)(one(typeof(stop)),stop)
    end
end

primetest() = ccall((:primesieve_test, libname), Void, ())

end # module PrimeSieve
