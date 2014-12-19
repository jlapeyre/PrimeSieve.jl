# Convert numbers to Int128 or Uint64, hopefully the subexpressions
# have not overflowed.  Eg. 10^19.
# Unquoted expressions pass through
for (f, xtype) in ( (:conv128, :int128), (:convu64, :uint64))
    @eval begin
        ($f)(ex::Expr) = eval(Expr(ex.head, map((x)->(typeof(x) == Expr ?
              ($f)(x) : typeof(x) <: Real ? ($xtype)(x) : x), ex.args)...))
    ($f)(x) = x
    end
end

const stoplimit = convu64( :(2^64 - 2^32 * 10) )
const startlimit = convu64( :(2^64 - 2^32 * 11) )

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

const libname = "libprimesieve.so.4"

# Copy the returned array, and free C array
function primescopy(res,n)
    retv = pointer_to_array(res,n,false)
    nretv = copy(retv)
    ccall((:primesieve_free, libname), Void, (Ptr{Void},), res)
    nretv
end

# return array of primes between start and stop
genprimes{T<:FloatingPoint}(start::Expr, stop::T) = genprimes(convu64(start),stop)
genprimes{T<:FloatingPoint}(start::T, stop::Expr) = genprimes(start,convu64(stop))
genprimes(start::Expr, stop::Expr) = genprimes(convu64(start),convu64(stop))

function genprimes{T,V}(start::T,stop::V)
    checkstop(stop)
    n = Csize_t[0]
    res = try 
        ccall((:primesieve_generate_primes, libname),
                Ptr{T}, (Uint64, Uint64, Ptr{Csize_t}, Int),
                convert(Uint64,start),convert(Uint64,stop),n,primetype(T))
    catch
        throw(InterruptException())
    end      
    primescopy(res,n[1])
end

# not really the Julia way...
# we should discourage floating point, anyway.
genprimes{T<:FloatingPoint,V<:FloatingPoint}(start::T,stop::V) = genprimes(int64(start),int64(stop))        
genprimes{T<:FloatingPoint}(stop::T) = genprimes(int64(1),int64(stop))
genprimes{T<:FloatingPoint}(start,stop::T) = genprimes(start,int64(stop))
genprimes{T<:FloatingPoint}(start::T,stop) = genprimes(int64(start),stop)

genprimes(stop::Expr) = genprimes(one(typeof(convu64(stop))),convu64(stop))
genprimes(stop) = genprimes(one(typeof(stop)),stop)

nprimes{T<:FloatingPoint}(n::Expr, stop::T) = nprimes(convu64(n),stop)
nprimes{T<:FloatingPoint}(n::T, stop::Expr) = nprimes(n,convu64(stop))
# return array of the first n primes >= start
function nprimes{T}(n::T,start)
    checkstop(start) # not sure what he means here    
    res = try
        ccall((:primesieve_generate_n_primes, libname),
                    Ptr{T}, (Uint64, Uint64, Int),
                    convert(Uint64,n),convert(Uint64,start),primetype(T))
    catch
        throw(InterruptException())        
    end        
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
        ($jname){T<:FloatingPoint}(n::Expr, stop::T) = ($jname)(convu64(n),stop)
        ($jname){T<:FloatingPoint}(n::T, stop::Expr) = ($jname)(n,convu64(stop))        
        function ($jname){T}(n,start::T)
            checkstart(start)
            res = try
                ccall(( $cname, libname),
                         Ptr{Uint64}, (Int64, Uint64),
                      convert(Int64,n),convert(Uint64,start))
            catch
                throw(InterruptException())
            end
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
        ($jname){T<:FloatingPoint}(n::Expr, stop::T) = ($jname)(convu64(n),stop)
        ($jname){T<:FloatingPoint}(n::T, stop::Expr) = ($jname)(n,convu64(stop))        
        function ($jname){T,V}(start::T, stop::V)
            checkstop(stop)
            (start,stop) = promote(start,stop)
            res = try
                ccall(($cname,libname),
                        Ptr{Uint64}, (Uint64, Uint64),
                      convert(Uint64,start), convert(Uint64,stop))
            catch
                throw(InterruptException())
            end                
            convert(typeof(start),res)
        end
        ($jname){T<:FloatingPoint,V<:FloatingPoint}(start::T,stop::V) = ($jname)(int64(start),int64(stop))        
        ($jname){T<:FloatingPoint}(stop::T) = ($jname)(int64(1),int64(stop))
        ($jname){T<:FloatingPoint}(start,stop::T) = ($jname)(start,int64(stop))
        ($jname){T<:FloatingPoint}(start::T,stop) = ($jname)(int64(start),stop)
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
        ($jname){T<:FloatingPoint}(n::Expr, stop::T) = ($jname)(convu64(n),stop)
        ($jname){T<:FloatingPoint}(n::T, stop::Expr) = ($jname)(n,convu64(stop))        
        function ($jname){T,V}(start::T, stop::V)
            checkstop(stop)
            (start,stop) = promote(start,stop)
            try
                ccall(($cname,libname),
                      Void, (Uint64, Uint64),
                      convert(Uint64,start), convert(Uint64,stop))
            catch
                throw(InterruptException())
            end                
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
