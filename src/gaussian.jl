# if VERSION <= v"0.5.0-"
#     import Base: isprime
# end

if isdefined(Base, :isprime)
    import Base: isprime
else
    import Primes: isprime
end

# Gaussian primes
function isprime{T<:Integer}(z::Complex{T})
    (x,y) = (real(z),imag(z))
    x == 0 && isprime(y) && y % 4 == 3 && return true
    y == 0 && isprime(x) && x % 4 == 3 && return true
    isprime(abs2(z))
end

#Base.@vectorize_1arg Complex isprime
