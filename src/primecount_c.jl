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

for (f,c) in ( # (:primepi, :(:pi_int64)), use function with keyword
               (:pi_deleglise_rivat, :(:pi_deleglise_rivat)),
              (:pi_legendre, :(:pi_legendre)), (:pi_lehmer, :(:pi_lehmer)),
              (:pi_meissel, :(:pi_meissel)), (:pi_lmo, :(:pi_lmo)),
              (:piprimesieve, :(:pi_primesieve)), (:nthprimecount, :(:nth_prime)),
              (:primeLi, :(:prime_Li)), (:primeLiinv, :(:prime_Li_inverse)))
    @eval begin
        # function ($f){T<:Real}(n::T)   # try-catch not preventing segfaults
        #     res = try
        #         ccall(($c, libccountname), Ptr{Int64}, (Int64,), convert(Int64,n))
        #     catch
        #         throw(InterruptException())
        #     end
        #     return convert(T,res)
        # end
        ($f){T<:Real}(n::T) = ccall(($c, libccountname), Int64, (Int64,), convert(Int64,n))
        ($f){T<:String}(n::T) = ($f)(conv128(n))
    end
end

function legendrephi(x,a)
    ccall((:prime_phi, libccountname), Int64, (Int64, Int64), convert(Int64,x), convert(Int64,a))
end

function nthprime(x; alg::Symbol = :count)
    if alg == :count
        return nthprimecount(x)
    elseif alg == :sieve
        return nthprimea(x)
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

# :auto is not perfect, fails often
# Tables or interpolation, or a crude fit for both methods is a better way.
# The two parameters are x and rem, the distance to the previous table value.
function primepi(x; alg::Symbol = :auto)
    if alg == :auto
        if (x < 7*10^11)  # This is a fairly sharp crossover
            return countprimes(x)
        else
            rem = piandrem(x)[3]
            rem == 0 && return countprimes(x)
            if rem <= 10^9 || x/rem >= 10^7  # this gets a lot of cases correctly.
                return countprimes(x)
            else
                return pi_deleglise_rivat(x)
            end
        end
    elseif alg == :deleglise_rivat || alg == :dr
        pi_deleglise_rivat(x)
    elseif alg == :tabsieve
        countprimes(x)    
    elseif alg == :lehmer   # The remaining are of academic interest (... well all are, really)
        pi_lehmer(x)
    elseif alg == :meissel
        pi_meissel(x)  
    elseif alg == :lmo
        pi_lmo(x)
    elseif alg == :legendre
        pi_legendre(x)
    elseif alg == :sieve
        piprimesieve(x)
    else
        error("Algorithm must be one of :auto, :deleglise_rivat (:dr), :tabsieve, :legendre, " *
               ":lehmer, :meissel, :lmo, :sieve.")
    end
end

primepi_xmax() = int128(bytestring(ccall((:pi_xmax, libccountname), Ptr{Uint8}, ())))
const PRIMEPI_XMAX = primepi_xmax()
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
