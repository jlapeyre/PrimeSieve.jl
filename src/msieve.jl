export mfactor

const smsievelib =  "libsmsieve.so"

# Send the string to msieve and return c struct msieve_obj
function runmsieve(n::String, d::Integer, logfile, deepecm)
    numcores = 1
    ecmflag = deepecm ? 1 : 0
    res = try
        if (logfile == "")
            ccall((:factor_from_string,smsievelib), Ptr{Void}, (Ptr{Uint8},Int,Int,Ptr{Uint8},Int),
                  n, numcores, d, C_NULL, ecmflag)
        else
            ccall((:factor_from_string,smsievelib), Ptr{Void}, (Ptr{Uint8},Int,Int,Ptr{Uint8},Int),
                  n, numcores, d, logfile, ecmflag)
        end
    catch
        error("factor_from_string failed")
    end
    res == C_NULL && throw(InterruptException())
    res
end

runmsieve(n::String) = runmsieve(n,0)

# Send ptr to msieve_obj and get ptr to struct factors
getfactors(obj) = ccall((:get_factors_from_obj,smsievelib), Ptr{Void}, (Ptr{Void},), obj)
# Sent ptr to struct factors and get number of factors
get_num_factors(factors) = ccall((:get_num_factors,smsievelib), Int, (Ptr{Void},), factors)
msieve_free(obj) =  ccall((:msieve_obj_free_2,smsievelib), Void, (Ptr{Void},), obj)

# Send ptr to struct factor and get string rep of one factor
# ptr to next struct factor, correponding to next factor, is returned.
function get_one_factor_value(factor)
    a = Array(Uint8,500) # max num digits input to msieve is 300
    nextfactor = ccall((:get_one_factor_value,smsievelib), Ptr{Void}, (Ptr{Void},Ptr{Uint8},Int),
                       factor,a,length(a))
    return(nextfactor,bytestring(convert(Ptr{Uint8},a)))
end

# Send ptr to first struct factor. Return all factors as array of strings 
function get_all_factor_values(factor)
    allf = Array(String,0)
    nfactor = factor
    n = get_num_factors(factor)
    for i in 1:n
        (nfactor,sfact) = get_one_factor_value(nfactor)
        push!(allf,sfact)
    end
    return allf
end

# Send n as string to msieve, return all factors as array of strings
function runallmsieve(n::String, deadline::Integer, logfile,ecm)
    obj = runmsieve(n,deadline, logfile,ecm)
    thefactors = getfactors(obj)
    sfactors = get_all_factor_values(thefactors)
    msieve_free(obj)
    sfactors
end

# input factors as Array of strings. Output Array of Integers (Usually of type Int)
function factor_strings_to_integers(sfactors::Array{String})
    m = length(sfactors)
    n1 = eval(parse(sfactors[m]))
    T = typeof(n1)
    arr = Array(T,m)
    arr[m] = n1
    @inbounds for i in 1:m-1
        arr[i] = parseint(T,sfactors[i])
    end
    arr    
end

# Send string to msieve. Return factors as list of Integers.
mfactorl(n::String, deadline::Integer,logfile,ecm) = factor_strings_to_integers(runallmsieve(n,deadline,logfile,ecm))

# Send string to msieve. Return factors in Dict, like Base.factor
function mfactor(n::String, deadline::Integer,logfile,ecm)
    arr = mfactorl(n,deadline,logfile,ecm)
    T = eltype(arr)
    d = (T=>Int)[]
    @inbounds for i in arr d[i] = get(d,i,0) + 1 end
    d
end

# Input Integer. Use msieve and return factors in Dict, like Base.factor
function mfactor(n::Integer, deadline::Integer,logfile,ecm)
    n > 0 || error("number to be factored must be positive")
    mfactor(string(n), deadline,logfile,ecm)
end

function mfactor{T<:Integer}(a::AbstractArray{T,1}, deadline::Integer,logfile,ecm)
    outa = Array(Any,0)
    for x in a push!(outa,mfactor(x,deadline,logfile,ecm)) end
    outa
end

function mfactor{T<:String}(a::AbstractArray{T,1}, deadline::Integer,logfile,ecm)
    outa = Array(Any,0)
    for x in a push!(outa,mfactor(x,deadline,logfile,ecm)) end
    outa
end

mfactor(x; deadline::Integer = 0, logfile::String = "", ecm::Bool = false) = mfactor(x,deadline,logfile,ecm)
