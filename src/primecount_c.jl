export primepi
export legendrephi
export nthprime
export primeLi
export primeLiinv
export primepi_xmax
export primepi_num_threads
export primepi_num_threads
export prime_set_print_status
export primepi_test

const libccountname = "libcprimecount.so"

for (f,c) in ( (:primepi, :(:pi_int64)), (:pi_deleglise_rivat, :(:pi_deleglise_rivat)),
              (:pi_legendre, :(:pi_legendre)), (:pi_lehmer, :(:pi_lehmer)),
              (:pi_meissel, :(:pi_meissel)), (:pi_lmo, :(:pi_lmo)),
              (:piprimesieve, :(:pi_primesieve)), (:nthprimecount, :(:nth_prime)),
              (:primeLi, :(:prime_Li)), (:primeLiinv, :(:prime_Li_inverse)))
    @eval begin
        ($f){T<:Real}(n::T) = ccall(($c, libccountname), Int64, (Int64,), convert(Int64,n))
        ($f){T<:String}(n::T) = ($f)(conv128(n))
    end
end

function legendrephi(x,a)
    ccall((:prime_phi, libccountname), Int64, (Int64, Int64), convert(Int64,x), convert(Int64,a))
end

function nthprime(x; alg::Symbol = :count)
    if alg == :count
        nthprimecount(x)
    elseif alg == :sieve
        nthprimea(x)
    else error("algorithm must be one of :count, :sieve")
    end
end

# libprimecount has a member function converts a string to Int128, but we probably handle more cases this way
function primepi{T<:String}(s::T)
    n1 = conv128(s)
    s1 = string(n1)
    int128(bytestring(ccall((:pi_string,libccountname),Ptr{Uint8},(Ptr{Uint8},),s1)))
end

# Can't get access to Int128 routine, so we convert back and forth many times.
pi_deleglise_rivat(x::Int128) = primepi(string(x))

function primepi(x; alg::Symbol = :deleglise_rivat)
    if alg == :deleglise_rivat || alg == :dr
        pi_deleglise_rivat(x)
    elseif alg == :legendre
        pi_legendre(x)
    elseif alg == :lehmer
        pi_lehmer(x)
    elseif alg == :meissel
        pi_meissel(x)  
    elseif alg == :lmo
        pi_lmo(x)
    elseif alg == :sieve
        piprimesieve(x)
    elseif alg == :tabsieve
        countprimes(x)
    else
        error("Algorithm must be one of :deleglise_rivat (:dr), :legendre, " *
               ":lehmer, :meissel, :lmo, :sieve, :tabsieve.")
    end
end

primepi_xmax() = int128(bytestring(ccall((:pi_xmax, libccountname), Ptr{Uint8}, ())))
primepi_num_threads(n) = ccall((:prime_set_num_threads,libccountname),Void,(Int,), convert(Int,n))
primepi_num_threads() = ccall((:prime_get_num_threads,libccountname),Int,())
prime_set_print_status(stat::Bool) = ccall((:prime_set_num_threads,libccountname),Void,(Int,), stat ? 1 : 0)
primepi_test() = ccall((:prime_test,libccountname),Int,())

# libprimecount does not really set the number of threads until you ask.
# In primecount, the initial value returned by init_num_threads == num cores.
# In primesieve it was a huge integer. I am paranoid, so I check.
function init_num_threads()
    n = primepi_num_threads()
    n < 10000 && primepi_num_threads(n)
end

# Set multithreading now
init_num_threads()
