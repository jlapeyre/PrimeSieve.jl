export randprime

function randprime(a,b,lim)
    n = zero(b)
    i = 1
    while i < lim
        n = rand(a:b)
        isprime(n) && break
        i += 1
    end
    i == lim ? zero(b) : n
end

randprime(a,b) = randprime(a,b,10^4)
randprime(b) = randprime(convert(typeof(b),2),b)
