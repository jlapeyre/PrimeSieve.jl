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

# return array of primes between start and stop
function primes{T,V}(start::T,stop::V)
    checkstop(stop)
    n = Csize_t[0]
    res = ccall((:primesieve_generate_primes, libname),
                Ptr{T}, (Uint64, Uint64, Ptr{Csize_t}, Int),
                convert(Uint64,start),convert(Uint64,stop),n,primetype(T))
    primescopy(res,n[1])
end

# not really the Julia way...
primes{T<:FloatingPoint,V<:FloatingPoint}(start::T,stop::V) = primes(int64(start),int64(stop))        
primes{T<:FloatingPoint}(stop::T) = primes(int64(1),int64(stop))
primes{T<:FloatingPoint}(start,stop::T) = primes(start,int64(stop))
primes{T<:FloatingPoint}(start::T,stop) = primes(int64(start),stop)
primes(stop) = primes(one(typeof(stop)),stop)

# return array of the first n primes >= start
function nprimes{T}(n::T,start)
    checkstop(start) # not sure what he means here
    res = ccall((:primesieve_generate_n_primes, libname),
                Ptr{T}, (Uint64, Uint64, Int),
                convert(Uint64,n),convert(Uint64,start),primetype(T))
    primescopy(res,n)
end

nprimes{T<:FloatingPoint,V<:FloatingPoint}(n::T,start::V) = nprimes(int64(n),int64(start))        
nprimes{T<:FloatingPoint}(start::T) = nprimes(int64(start),1)
nprimes{T<:FloatingPoint}(n,start::T) = nprimes(n,int64(start))
nprimes{T<:FloatingPoint}(n::T,start) = nprimes(int64(n),start)
nprimes(start) = nprimes(one(typeof(start)),start)        
nprimes(n) = nprimes(n,one(typeof(n)))

# return the nth prime
for (cname,jname) in ((:(:primesieve_nth_prime), :snthprime),
                      (:(:primesieve_parallel_nth_prime), :nthprime))
    @eval begin
        function ($jname){T}(n,start::T)
            checkstart(start)
            res = ccall(( $cname, libname),
                         Ptr{Uint64}, (Int64, Uint64),
                        convert(Int64,n),convert(Uint64,start))
            convert(T,res)
        end
        ($jname){T<:FloatingPoint,V<:FloatingPoint}(n::T,start::V) = ($jname)(int64(n),int64(start))        
        ($jname){T<:FloatingPoint}(start::T) = ($jname)(int64(start),1)
        ($jname){T<:FloatingPoint}(n,start::T) = ($jname)(n,int64(start))
        ($jname){T<:FloatingPoint}(n::T,start) = ($jname)(int64(n),start)
        ($jname)(start) = ($jname)(one(typeof(start)),start)        
        ($jname)(n) = ($jname)(n,1)
    end
end

for (cname,jname) in (
                      (:(:primesieve_count_primes), :scountprimes),
                      (:(:primesieve_count_twins), :scountprimes2),
                      (:(:primesieve_count_triplets), :scountprimes3),
                      (:(:primesieve_count_quadruplets), :scountprimes4),
                      (:(:primesieve_count_quintuplets), :scountprimes5),
                      (:(:primesieve_count_sextuplets), :scountprimes6),

                      (:(:primesieve_parallel_count_primes), :ntcountprimes),
                      (:(:primesieve_parallel_count_twins), :countprimes2),
                      (:(:primesieve_parallel_count_triplets), :countprimes3),
                      (:(:primesieve_parallel_count_quadruplets), :countprimes4),
                      (:(:primesieve_parallel_count_quintuplets), :countprimes5),
                      (:(:primesieve_parallel_count_sextuplets), :countprimes6),

                      (:(:primesieve_print_primes), :printprimes),
                      (:(:primesieve_print_twins), :printprimes2),
                      (:(:primesieve_print_triplets), :printprimes3),
                      (:(:primesieve_print_quadruplets), :printprimes4),
                      (:(:primesieve_print_quintuplets), :printprimes5),
                      (:(:primesieve_print_sextuplets), :printprimes6))
    @eval begin
        function ($jname){T,V}(start::T, stop::V)
            checkstop(stop)
            (start,stop) = promote(start,stop)
            res = ccall(($cname,libname),
                        Ptr{Uint64}, (Uint64, Uint64),
                        convert(Uint64,start), convert(Uint64,stop))
            convert(typeof(start),res)
        end
        ($jname){T<:FloatingPoint,V<:FloatingPoint}(start::T,stop::V) = ($jname)(int64(start),int64(stop))        
        ($jname){T<:FloatingPoint}(stop::T) = ($jname)(int64(1),int64(stop))
        ($jname){T<:FloatingPoint}(start,stop::T) = ($jname)(start,int64(stop))
        ($jname){T<:FloatingPoint}(start::T,stop) = ($jname)(int64(start),stop)
        ($jname)(stop) = ($jname)(one(typeof(stop)),stop)
    end
end

primesievesize() = ccall((:primesieve_get_sieve_size, libname), Int, ())
# following does not seem to work
function primesievesize(sz)
    isz = convert(Int,sz)
    1 <= sz <= 2048 || error("Sieve size (in Kb) must be between 1 and 2048")
    ccall((:primesieve_get_sieve_size, libname), Void, (Int,),isz)
    isz
end

primenumthreads(n) = (ccall((:primesieve_set_num_threads, libname), Void, (Int,), convert(Int,n)); n)
primenumthreads() = ccall((:primesieve_get_num_threads, libname), Int, ())
primetest() = ccall((:primesieve_test, libname), Void, ())
primemaxstop() = ccall((:primesieve_get_max_stop, libname), Uint, ())
