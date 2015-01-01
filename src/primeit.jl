export someprimes, allprimes

type PrimeIt{T<:Integer}
    n1::T
    n2::T
end

type PrimeInfIt{T<:Integer}
    n1::T
end

someprimes(n::Integer) = PrimeIt(convert(typeof(n),2),n)
someprimes(n1::Integer, n2::Integer) = PrimeIt(promote(n1,n2)...)
allprimes(n1::Integer) = PrimeInfIt(n1)
allprimes() = PrimeInfIt(2)

Base.start(pri::PrimeIt) = pri.n1
Base.start(pri::PrimeInfIt) = pri.n1
Base.next(pri::PrimeIt, state)  = (state, nextprime(state))
Base.next(pri::PrimeInfIt, state) = (state, nextprime(state))
Base.done(pri::PrimeIt, state) = state > pri.n2
Base.done(pri::PrimeInfIt, state) = false
