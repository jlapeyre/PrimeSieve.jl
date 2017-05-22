export randprime

const RPLIM = 10^4

# not using keyword here is 5-10 percent faster in a quick check
@inline function _randprime(a,b,lim)
    n = zero(b)
    i = 1
    while i < lim
        n = rand(a:b)
        isprime(n) && break
        i += 1
    end
    i == lim ? zero(b) : n
end

randprime(a,b; lim::Int=RPLIM) = _randprime(a,b,lim)
randprime(b; lim::Int=RPLIM) = _randprime(convert(typeof(b),2),b,lim)

function randprime(a,b,dims...;lim::Int=RPLIM)
    arr = Array{typeof(a)}(dims...)
    @inbounds for i in 1:length(arr) arr[i] = _randprime(a,b,lim) end
    arr
end
