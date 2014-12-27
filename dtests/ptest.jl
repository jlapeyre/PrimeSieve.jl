# Test relative speed of Deleglise Rivat and tabsieve
function tprimepi(n)
    tdr = @elapsed primepi(n, alg = :dr)
    primesieve_num_threads(8)
    tts = @elapsed primepi(n, alg = :tabsieve)
    return tdr/tts
end

# Test function above m times with random numbers
# between n and 2n. Report how many times one or
# the other is faster.
# On 
function tprimepia(n0,n1,m)
    c1 = 0
    c2 = 0
    for i in 1:m
        nr = int(n1 * rand()) + n0
        res = tprimepi(nr)
        res > 1 ? c1 += 1 : c2 += 1
    end
    return (c1/m,c2/m)
end

tprimepia(n,m) = tprimepia(n,n,m)

function print_tprimepia()
    for (n,m) in ((1,10^5), (2, 10^5),(3, 10^4),
                  (4, 10^4),(5, 10^4),(6, 10^4),
                  (7, 10^4),(8, 10^4),(9, 10^3),
                  (10, 10^3),(11, 10^3),(12, 5*10^2),
                  (13, 10^2))
        println("10^$n: ", tprimepia(10^n,m))
    end
end

function print_tprimepia1()
    m = 10^2
    for n in (1,2,3,4,5,6,7,8,9,10)
        println("$n * 10^11: ", tprimepia(n*10^11,m))
    end
end

function ts0(n,n1)
    for i in 1:n1
        nextprimea(n)
    end
end

function ts1(n,n1)
    for i in 1:n1
        PrimeSieve.nextprime(n)
    end
end

function ps0(n,n1)
    for i in 1:n1
        prevprimea(n)
    end
end

function ps1(n,n1)
    for i in 1:n1
        PrimeSieve.prevprime(n)
    end
end

function ts0b(n,n1)
    for i in 1:n1
        nextprimeb(n)
    end
end




# function ts2(n,n1)
#     for i in 1:n1
#         PrimeSieve.nextprime2(n)
#     end
# end

function trat(n,n1)
    t0 = @elapsed ts0(n,n1)
    t1 = @elapsed ts1(n,n1)
    t0/t1
end

function prat(n,n1)
    t0 = @elapsed ps0(n,n1)
    t1 = @elapsed ps1(n,n1)
    t0/t1
end

function trata(n,n1)
    t1 = @elapsed ts1(n,n1)    
    t0 = @elapsed ts0(n,n1)
    t0/t1
end

function tratb(n,n1)
    t1 = @elapsed ts1(n,n1)    
    t0 = @elapsed ts0(n,n1)
    t0/t1
end
