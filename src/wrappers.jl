countprimes(stop::Expr; tuplet::Int = 1) = countprimes(conv128(stop),tuplet)
countprimes(stop::Expr) = countprimes(conv128(stop))
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

# countprimes{T<:FloatingPoint}(start::Expr, stop::T; tuplet::Int = 1) = countprimes(conv128(start),stop,tuplet)
# countprimes{T<:FloatingPoint}(start::T, stop::Expr; tuplet::Int = 1) = countprimes(start,conv128(stop),tuplet)
# countprimes{T<:FloatingPoint}(start::Expr, stop::T) = countprimes(conv128(start),stop)
# countprimes{T<:FloatingPoint}(start::T, stop::Expr) = countprimes(start,conv128(stop))
countprimes(start::Expr, stop::Expr; tuplet::Int = 1) = countprimes(conv128(start),conv128(stop),tuplet)
countprimes(start::Expr, stop::Expr) = countprimes(conv128(start),conv128(stop))
function countprimes(start,stop; tuplet::Int = 1)
    if tuplet == 1
        _countprimes(start,stop)
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

scountprimes(stop::Expr; tuplet::Int = 1) = scountprimes(conv128(stop),tuplet)
scountprimes(stop::Expr) = scountprimes(conv128(stop))
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

# scountprimes{T<:FloatingPoint}(start::Expr, stop::T; tuplet::Int = 1) = scountprimes(start,conv128(stop),tuplet)
# scountprimes{T<:FloatingPoint}(start::T, stop::Expr; tuplet::Int = 1) = scountprimes(start,conv128(stop),tuplet)
# scountprimes{T<:FloatingPoint}(start::Expr, stop::T) = scountprimes(conv128(start),stop)
# scountprimes{T<:FloatingPoint}(start::T, stop::Expr) = scountprimes(start,conv128(stop))
scountprimes(start::Expr, stop::Expr; tuplet::Int = 1) = scountprimes(conv128(start),conv128(stop),tuplet)
scountprimes(start::Expr, stop::Expr) = scountprimes(conv128(start),conv128(stop))
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

printprimes(stop::Expr; tuplet::Int = 1) = printprimes(conv128(stop),tuplet)
printprimes(stop::Expr) = printprimes(conv128(stop))
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

# printprimes{T<:FloatingPoint}(start::Expr, stop::T; tuplet::Int = 1) = printprimes(start,conv128(stop),tuplet)
# printprimes{T<:FloatingPoint}(start::T, stop::Expr; tuplet::Int = 1) = printprimes(start,conv128(stop),tuplet)
# printprimes{T<:FloatingPoint}(start::Expr, stop::T) = printprimes(conv128(start),stop)
# printprimes{T<:FloatingPoint}(start::T, stop::Expr) = printprimes(start,conv128(stop))
printprimes(start::Expr, stop::Expr; tuplet::Int = 1) = printprimes(conv128(start),conv128(stop),tuplet)
printprimes(start::Expr, stop::Expr) = printprimes(conv128(start),conv128(stop))
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
