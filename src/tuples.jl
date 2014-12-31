export isadmtup

# Is sequence an admissible prime k-tuple.
function isadmtup(x)
    mx = sort(x % length(x))
    @inbounds for i in 0:length(x)-1
        mx[i+1] == i || return true
    end
    false
end
