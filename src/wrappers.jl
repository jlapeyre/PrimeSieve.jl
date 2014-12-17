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

function countprimes(stop,start; tuplet::Int = 1)
    if tuplet == 1
        _countprimes(stop,start)
    elseif tuplet == 2
        countprimes2(stop,start)
    elseif tuplet == 3
        countprimes3(stop,start)
    elseif tuplet == 4
        countprimes4(stop,start)
    elseif tuplet == 5
        countprimes5(stop,start)
    elseif tuplet == 6
        countprimes6(stop,start)
    else
        error("tuplet must be between 1 and 6")
    end
end

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

function scountprimes(stop,start; tuplet::Int = 1)
    if tuplet == 1
        _scountprimes(stop,start)
    elseif tuplet == 2
        scountprimes2(stop,start)
    elseif tuplet == 3
        scountprimes3(stop,start)
    elseif tuplet == 4
        scountprimes4(stop,start)
    elseif tuplet == 5
        scountprimes5(stop,start)
    elseif tuplet == 6
        scountprimes6(stop,start)
    else
        error("tuplet must be between 1 and 6")
    end
end

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

function printprimes(stop,start; tuplet::Int = 1)
    if tuplet == 1
        _printprimes(stop,start)
    elseif tuplet == 2
        printprimes2(stop,start)
    elseif tuplet == 3
        printprimes3(stop,start)
    elseif tuplet == 4
        printprimes4(stop,start)
    elseif tuplet == 5
        printprimes5(stop,start)
    elseif tuplet == 6
        printprimes6(stop,start)
    else
        error("tuplet must be between 1 and 6")
    end
end
