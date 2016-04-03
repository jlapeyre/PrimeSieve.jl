typealias ConvT Union{Expr,AbstractString}

const stoplimit = convu64( :(2^64 - 2^32 * 10) )
const startlimit = convu64( :(2^64 - 2^32 * 11) )

checkstop(val) = val <= stoplimit ? true : error("stop value ", val, " is greater than limit: ", val)
checkstart(val) = val <= startlimit ? true : error("start value ", val, " is greater than limit: ", val)

# libprimesieve also uses all cores by default.
# We store the number of threads because libprimecount will always set
# it to 1 and manage threads itself.
PRIMESIEVENUMTHREADS = CPU_CORES

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

const libname = "libprimesieve.so.4"

# Copy the returned array, and free C array
function primescopy(res,n)
    retv = pointer_to_array(res,n,false)
    nretv = copy(retv)
    ccall((:primesieve_free, libname), Void, (Ptr{Void},), res)
    nretv
end

# return array of primes between start and stop
genprimes_sieve(start::ConvT, stop::ConvT) = genprimes(convu64(start),convu64(stop))
genprimes_sieve(stop::ConvT) = genprimes(one(typeof(convu64(stop))),convu64(stop))
genprimes_sieve(stop) = genprimes(one(typeof(stop)),stop)

function genprimes_sieve{T,V}(start::T,stop::V)
    checkstop(stop)
    n = Csize_t[0]
    res = try 
        ccall((:primesieve_generate_primes, libname),
                Ptr{T}, (UInt64, UInt64, Ptr{Csize_t}, Int),
                convert(UInt64,start),convert(UInt64,stop),n,primetype(T))
    catch
        throw(InterruptException())
    end      
    primescopy(res,n[1])
end

function genprimes(b; alg::Symbol = :sieve)
    if alg == :sieve
        return genprimes_sieve(b)
    elseif alg == :next
        return genprimesb(one(b),b)
    else
        error("algorithm must be :sieve or :next")
    end
end

function genprimes(a,b; alg::Symbol = :auto)
    if alg == :auto && b < stoplimit
        if b-a < 200  # this is crude; best depends on a and b, not just difference.
            return genprimesb(a,b)
        else
            return genprimes_sieve(a,b)
        end
    elseif alg == :next || b >= stoplimit
        return genprimesb(a,b)        
    elseif alg == :sieve
        return genprimes_sieve(a,b)
    else
        error("algorithm must be one of :auto, :sieve, or :next")
    end
end

nprimes(n::ConvT,start::ConvT) = nprimes(convu64(n),convu64(start))
nprimes(n,start::ConvT) = nprimes(n,convu64(start))
nprimes(n::ConvT,start) = nprimes(convu64(n),start)
nprimes(n::ConvT) = nprimes(convu64(n),one(UInt64))
# return array of the first n primes >= start
function nprimes{T}(n::T,start)
    checkstop(start) # not sure what he means here    
    res = try
        ccall((:primesieve_generate_n_primes, libname),
                    Ptr{T}, (UInt64, UInt64, Int),
                    convert(UInt64,n),convert(UInt64,start),primetype(T))
    catch # every so often, loading fails with ERROR: invalid base 10 digit '@' in "100000000000000000000000@\0\0\0"

        throw(InterruptException())        
    end        
    primescopy(res,n)
end
nprimes(start) = nprimes(one(typeof(start)),start)        
nprimes(n) = nprimes(n,one(typeof(n)))

# return the nth prime
for (cname,jname) in ((:(:primesieve_nth_prime), :snthprimea),
                      (:(:primesieve_parallel_nth_prime), :nthprimea))
    @eval begin
        function ($jname){T}(n,start::T)
            checkstart(start)
            res = try
                ccall(( $cname, libname),
                         Ptr{UInt64}, (Int64, UInt64),
                      convert(Int64,n),convert(UInt64,start))
            catch
                throw(InterruptException())
            end
            convert(T,res)
        end
        ($jname)(start) = ($jname)(one(typeof(start)),start)        
        ($jname)(n) = ($jname)(n,1)
    end
end

for (cname,jname) in (
                      (:(:primesieve_count_primes), :_scountprimes),
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
                      (:(:primesieve_parallel_count_sextuplets), :countprimes6))

    @eval begin
        function ($jname){T,V}(start::T, stop::V)
            checkstop(stop)
            (start,stop) = promote(start,stop)
            reset_primesieve_num_threads()
            res = try
                ccall(($cname,libname),
                        Ptr{UInt64}, (UInt64, UInt64),
                      convert(UInt64,start), convert(UInt64,stop))
            catch
                throw(InterruptException())
            end                
            convert(typeof(start),res)
        end
        ($jname)(stop::ConvT) = ($jname)(one(typeof(convu64(stop))),convu64(stop))
        ($jname)(start::ConvT, stop::ConvT) = ($jname)(convu64(start),convu64(stop))
        ($jname)(stop) = ($jname)(one(typeof(stop)),stop)
    end
end

for (cname,jname) in (
                      (:(:primesieve_print_primes), :_printprimes),
                      (:(:primesieve_print_twins), :printprimes2),
                      (:(:primesieve_print_triplets), :printprimes3),
                      (:(:primesieve_print_quadruplets), :printprimes4),
                      (:(:primesieve_print_quintuplets), :printprimes5),
                      (:(:primesieve_print_sextuplets), :printprimes6))
    @eval begin
        function ($jname){T,V}(start::T, stop::V)
            checkstop(stop)
            (start,stop) = promote(start,stop)
            try
                ccall(($cname,libname),
                      Void, (UInt64, UInt64),
                      convert(UInt64,start), convert(UInt64,stop))
            catch
                throw(InterruptException())
            end                
        end
        ($jname)(stop::ConvT) = ($jname)(one(typeof(convu64(stop))),convu64(stop))
        ($jname)(start::ConvT, stop::ConvT) = ($jname)(convu64(start),convu64(stop))
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

# libprimecount always sets this to 1. So we reset
function reset_primesieve_num_threads()
    ccall((:primesieve_set_num_threads, libname), Void, (Int,), convert(Int,PRIMESIEVENUMTHREADS))
end

function primesieve_num_threads(n)
    ccall((:primesieve_set_num_threads, libname), Void, (Int,), convert(Int,n))
    global PRIMESIEVENUMTHREADS = n
    n
end

primesieve_num_threads() = ccall((:primesieve_get_num_threads, libname), Int, ())
primetest() = ccall((:primesieve_test, libname), Void, ())
primemaxstop() = ccall((:primesieve_get_max_stop, libname), UInt, ())
