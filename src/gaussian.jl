import Base: isprime

# Gaussian primes
function isprime{T<:Integer}(z::Complex{T})
    (x,y) = (real(z),imag(z))
    x == 0 && isprime(y) && y % 4 == 3 && return true
    y == 0 && isprime(x) && x % 4 == 3 && return true
    isprime(x*x+y*y)
end
