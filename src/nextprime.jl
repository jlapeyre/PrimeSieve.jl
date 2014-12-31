export nextprime, nextprime1, prevprime, prevprime1, genprimesb, genprimesc
export countprimesb, countprimesc

# Translated with small edits from ifactor.lisp by John Lapeyre (2014)
# ifactor.lisp: Copyright: 2005-2008 Andrej Vodopivec, Volker van Nek
#               Licence  : GPL

# First values of nextprime, prevprime
const next_prime_array = [0, 2, 3, 5, 5, 7, 7]
const prev_prime_array = [0, 0, 0, 2, 3, 3, 5, 5, 7, 7, 7, 7]

# gaps between numbers that are not multiples of 2,3,5,7
const deltaprimes_next =
    [1, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 2, 1, 4, 3, 2, 1, 2, 1, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 2,
     1, 6, 5, 4, 3, 2, 1, 4, 3, 2, 1, 2, 1, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 2, 1,
     6, 5, 4, 3, 2, 1, 4, 3, 2, 1, 2, 1, 6, 5, 4, 3, 2, 1, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 8, 7, 6,
     5, 4, 3, 2, 1, 4, 3, 2, 1, 2, 1, 4, 3, 2, 1, 2, 1, 4, 3, 2, 1, 8, 7, 6, 5, 4, 3, 2, 1, 6, 5,
     4, 3, 2, 1, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 2, 1, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 2, 1, 6, 5, 4,
     3, 2, 1, 6, 5, 4, 3, 2, 1, 4, 3, 2, 1, 2, 1, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 2, 1, 6, 5, 4, 3,
     2, 1, 4, 3, 2, 1, 2, 1, 4, 3, 2, 1, 2, 1, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 2]

const deltaprimes_prev = 
  [-1, -2, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -1, -2, -1, -2, -3, -4, -1, -2,
    -1, -2, -3, -4, -1, -2, -3, -4, -5, -6, -1, -2, -1, -2, -3, -4, -5, -6, -1, -2, -3,
    -4, -1, -2, -1, -2, -3, -4, -1, -2, -3, -4, -5, -6, -1, -2, -3, -4, -5, -6, -1, -2,
    -1, -2, -3, -4, -5, -6, -1, -2, -3, -4, -1, -2, -1, -2, -3, -4, -5, -6, -1, -2, -3,
    -4, -1, -2, -3, -4, -5, -6, -1, -2, -3, -4, -5, -6, -7, -8, -1, -2, -3, -4, -1, -2,
    -1, -2, -3, -4, -1, -2, -1, -2, -3, -4, -1, -2, -3, -4, -5, -6, -7, -8, -1, -2, -3,
    -4, -5, -6, -1, -2, -3, -4, -1, -2, -3, -4, -5, -6, -1, -2, -1, -2, -3, -4, -1, -2,
    -3, -4, -5, -6, -1, -2, -1, -2, -3, -4, -5, -6, -1, -2, -3, -4, -5, -6, -1, -2, -3,
    -4, -1, -2, -1, -2, -3, -4, -1, -2, -3, -4, -5, -6, -1, -2, -1, -2, -3, -4, -5, -6,
    -1, -2, -3, -4, -1, -2, -1, -2, -3, -4, -1, -2, -1, -2, -3, -4, -5, -6, -7, -8, -9,
    -10]

const small_primes = primes(100000)

#product of primes in [59..2897]
function makebigprimemultiple ()
    a = primes(2897);
    n = BigInt(1)
    @inbounds for i in 17:length(a)
        n *= a[i]
    end
    n
end

const bigprimemultiple = makebigprimemultiple()

# Deterministic. Only works up to a limit (see below)
function next_prime_det(n, deltaprimes)
    @inbounds n += deltaprimes[mod(n,210) + 1]
    while true
        @inbounds for p in small_primes
            mod(n,p) == 0 && break
            p*p >= n  && return n
        end
        @inbounds n += deltaprimes[mod(n,210) + 1]
    end
    n
end


# Probabalistic. Used for larger primes.
# In Maxima, a single miller_rabin test is done.
# Choice of which gcd's to check could be more fine grained.
# Using bigprimemultiple only seems to slow down the algorithm
function next_prime_prob(n, deltaprimes)
    T = typeof(n)  # all this converting does nothing, apparently. As expected.
    @inbounds n += deltaprimes[mod(n,convert(T,210))+one(T)]
    while true
        if
            gcd(n,convert(T,955049953)) == one(T) &&
            gcd(n,convert(T,162490421)) == one(T) &&
#            gcd(n,bigprimemultiple) == 1 &&  # Maxima uses this
#            miller_rabin(n)   # Maxima uses this
            isprime(n)
            return n
        end
        @inbounds n += deltaprimes[mod(n,convert(T,210))+one(T)]
    end
end


# Crossover point between deterministic and probabilistic algorithm
const NEXTCROSSOVER = 10^6  # empirical approximate crossover in speed
#const NEXTCROSSOVER = 99460722   # largest that gives correct results
#const NEXTCROSSOVER = 10^4  # value from Maxima

function nextprime{T<:Integer}(n::T)
    mtwo = convert(T,2)
    n < mtwo && return mtwo
    n <= convert(T,6) && return convert(T,next_prime_array[n+1])
    n < NEXTCROSSOVER && return next_prime_det(n,deltaprimes_next)
    next_prime_prob(n,deltaprimes_next)
end

function prevprime(n)
    n <= 11 && return prev_prime_array[n+1]
    n < NEXTCROSSOVER &&  return next_prime_det(n,deltaprimes_prev)
    next_prime_prob(n,deltaprimes_prev)
end

# nextprime1 and prevprime1
# These are usually slower:  1.5x, 3x, ...
# But for BigInts they seem to be uniformly faster
# code by Hans W Borchers https://github.com/hwborchers/Numbers.jl
function nextprime1(n::Integer)
    if n <= 1; return 2; end
    if n == 2; return 3; end
    if iseven(n)
        n += 1
    else
        n += 2
    end
    if isprime(n); return(n); end
    if mod(n, 3) == 1
        a = 4; b = 2
    elseif mod(n, 3) == 2
        a = 2; b = 4
    else
        n += 2
        a = 2; b = 4
    end
    p = n
    while !isprime(p)
        p += a
        if isprime(p); break; end
        p += b
    end
    return p
end

## Find prime number preceeding n
function prevprime1(n::Integer)
    if n <= 2
        return Array(typeof(n), 0)
    elseif n <= 3
        return 2
    end
    if iseven(n)
        n -= 1
    else
        n -= 2
    end    
    if isprime(n); return n; end

    if mod(n, 3) == 1
        a = 2; b = 4
    elseif mod(n, 3) == 2
        a = 4; b = 2
    else
        n -= 2
        a = 2; b = 4
    end
    p = n
    while !isprime(p)
        p -= a
        if isprime(p); break; end
        p -= b
    end
    return p
end

# These are nearly a factor of 2 faster for BigInt
nextprime(n::BigInt) = nextprime1(n)
prevprime(n::BigInt) = prevprime1(n)

# maybe we don't need genprimesc.
# Sometimes more efficient than libprimesieve wrapper genprimes, and
# has larger domain (eg BigInts, Int128)
for (f,fc) in ((:genprimesb, :nextprime), (:genprimesc, :nextprime1))
    @eval begin
        function ($f)(n1,n2)
            ret = Array(typeof(n2),0)
            v = n1
            while true
                v = ($fc)(v)
                v > n2 && break
                push!(ret,v)
            end
            return ret    
        end
        ($f)(n2) = ($f)(1,n2)
    end
end

# countprimesb nearly twice as fast as countprimesc for  Int64
for (f,fc) in ((:countprimesb, :nextprime), (:countprimesc, :nextprime1))
    @eval begin
        function ($f)(n1,n2)
            c = zero(n2)
            v = n1
            while true
                v = ($fc)(v)
                v > n2 && break
                c += one(n2)
            end
            return c
        end
        ($f)(n2) = ($f)(1,n2)
    end
end
