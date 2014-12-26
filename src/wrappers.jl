countprimes(stop::ConvT; tuplet::Int = 1) = countprimes(conv128(stop),tuplet)
countprimes(stop::ConvT) = countprimes(conv128(stop))
function countprimes(stop; tuplet::Int = 1)
    if tuplet == 1
        _countprimes(stop)
    elseif tuplet == 2
        countprimes2(stop)
    elseif tuplet == 3
        countprimes3(stop)
    elseif tuplet == 4
        countprimes4(stop)
    elseif tuplet == 5
        countprimes5(stop)
    elseif tuplet == 6
        countprimes6(stop)
    else
        error("tuplet must be between 1 and 6")
    end
end

countprimes(start::ConvT, stop::ConvT; tuplet::Int = 1) = countprimes(conv128(start),conv128(stop),tuplet)
countprimes(start::ConvT, stop::ConvT) = countprimes(conv128(start),conv128(stop))
function countprimes(start,stop; tuplet::Int = 1, alg::Symbol = :tabsieve )
    if tuplet == 1
        if alg == :next || stop > stoplimit
            countprimesb(start,stop)
        elseif alg == :nexta 
            countprimesc(start,stop)
        elseif alg == :tabsieve
            _countprimes(start,stop)
        elseif alg == :sieve
            ntcountprimes(start,stop)            
        else
            error("algorithm must be one of :sieve, :next, :nexta, :tabsieve")
        end
    elseif tuplet == 2
        countprimes2(start,stop)
    elseif tuplet == 3
        countprimes3(start,stop)
    elseif tuplet == 4
        countprimes4(start,stop)
    elseif tuplet == 5
        countprimes5(start,stop)
    elseif tuplet == 6
        countprimes6(start,stop)
    else
        error("tuplet must be between 1 and 6")
    end
end

scountprimes(stop::ConvT; tuplet::Int = 1) = scountprimes(conv128(stop),tuplet)
scountprimes(stop::ConvT) = scountprimes(conv128(stop))
function scountprimes(stop; tuplet::Int = 1)
    if tuplet == 1
        _scountprimes(stop)
    elseif tuplet == 2
        scountprimes2(stop)
    elseif tuplet == 3
        scountprimes3(stop)
    elseif tuplet == 4
        scountprimes4(stop)
    elseif tuplet == 5
        scountprimes5(stop)
    elseif tuplet == 6
        scountprimes6(stop)
    else
        error("tuplet must be between 1 and 6")
    end
end

scountprimes(start::ConvT, stop::ConvT; tuplet::Int = 1) = scountprimes(conv128(start),conv128(stop),tuplet)
scountprimes(start::ConvT, stop::ConvT) = scountprimes(conv128(start),conv128(stop))
function scountprimes(start,stop; tuplet::Int = 1)
    if tuplet == 1
        _scountprimes(start,stop)
    elseif tuplet == 2
        scountprimes2(start,stop)
    elseif tuplet == 3
        scountprimes3(start,stop)
    elseif tuplet == 4
        scountprimes4(start,stop)
    elseif tuplet == 5
        scountprimes5(start,stop)
    elseif tuplet == 6
        scountprimes6(start,stop)
    else
        error("tuplet must be between 1 and 6")
    end
end

printprimes(stop::ConvT; tuplet::Int = 1) = printprimes(conv128(stop),tuplet)
printprimes(stop::ConvT) = printprimes(conv128(stop))
function printprimes(stop; tuplet::Int = 1)
    if tuplet == 1
        _printprimes(stop)
    elseif tuplet == 2
        printprimes2(stop)
    elseif tuplet == 3
        printprimes3(stop)
    elseif tuplet == 4
        printprimes4(stop)
    elseif tuplet == 5
        printprimes5(stop)
    elseif tuplet == 6
        printprimes6(stop)
    else
        error("tuplet must be between 1 and 6")
    end
end

printprimes(start::ConvT, stop::ConvT; tuplet::Int = 1) = printprimes(conv128(start),conv128(stop),tuplet)
printprimes(start::ConvT, stop::ConvT) = printprimes(conv128(start),conv128(stop))
function printprimes(start,stop; tuplet::Int = 1)
    if tuplet == 1
        _printprimes(start,stop)
    elseif tuplet == 2
        printprimes2(start,stop)
    elseif tuplet == 3
        printprimes3(start,stop)
    elseif tuplet == 4
        printprimes4(start,stop)
    elseif tuplet == 5
        printprimes5(start,stop)
    elseif tuplet == 6
        printprimes6(start,stop)
    else
        error("tuplet must be between 1 and 6")
    end
end
