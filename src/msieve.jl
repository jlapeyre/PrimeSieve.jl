export mfactor

const smsievelib =  "libsmsieve.so"

type Msieveopts
    n::AbstractString
    deadline::Int
    logfile::AbstractString
    deepecm::Bool
    info::Bool    
end

# Send the string to msieve and return c struct msieve_obj
function runmsieve(opts::Msieveopts)
    n = opts.n  # n is a string
    d = opts.deadline
    logfile = opts.logfile
    deepecm = opts.deepecm
    numcores = 1
    ecmflag = deepecm ? 1 : 0
    infoflag = opts.info ? 1 : 0    
    res = try
        if (logfile == "")
            ccall((:factor_from_string,smsievelib), Ptr{Void}, (Ptr{UInt8},Int,Int,Ptr{UInt8},Int,Int),
                  n, numcores, d, C_NULL, ecmflag, infoflag)
        else
            ccall((:factor_from_string,smsievelib), Ptr{Void}, (Ptr{UInt8},Int,Int,Ptr{UInt8},Int, Int),
                  n, numcores, d, logfile, ecmflag, infoflag)
        end
    catch
        error("factor_from_string failed")
    end
    res == C_NULL && throw(InterruptException())
    res
end

# Send ptr to msieve_obj and get ptr to struct factors.
getfactors(obj) = ccall((:get_factors_from_obj,smsievelib), Ptr{Void}, (Ptr{Void},), obj)
# Sent ptr to struct factors and get number of factors.
get_num_factors(factors) = ccall((:get_num_factors,smsievelib), Int, (Ptr{Void},), factors)
msieve_free(obj) =  ccall((:msieve_obj_free_2,smsievelib), Void, (Ptr{Void},), obj)

# Send ptr to struct factor and get string rep of one factor.
# A ptr to next struct factor, correponding to next factor, is returned.
function get_one_factor_value(factor)
    factorstring = Array{UInt8}(500) # max num digits input to msieve is 300    
    nextfactor = ccall((:get_one_factor_value,smsievelib), Ptr{Void}, (Ptr{Void},Ptr{UInt8},Int),
                       factor,factorstring,length(factorstring))
    factorstring[end] = 0
    return(nextfactor,unsafe_string(pointer(factorstring)))
end

# Send ptr to first struct factor. Return all factors as array of strings 
function get_all_factor_values(factor)
    allf = Array(AbstractString,0)
    nfactor = factor
    n = get_num_factors(factor)
    for i in 1:n
        (nfactor,sfact) = get_one_factor_value(nfactor)
        push!(allf,sfact)
    end
    return allf
end

# Send n as string to msieve, return all factors as array of strings
function runallmsieve(opts::Msieveopts)
    obj = runmsieve(opts)
    sfactors = get_all_factor_values(getfactors(obj))
    msieve_free(obj)
    sfactors
end

# input factors as Array of strings. Output Array of Integers (Usually of type Int)
function factor_strings_to_integers(sfactors::Array{AbstractString})
    m = length(sfactors)
    n1 = eval(parse(BigInt,sfactors[m]))  ## why eval ?
    T = typeof(n1)
    arr = Array(T,m)
    arr[m] = n1
    for i in 1:m-1
        arr[i] = parse(T,sfactors[i])
    end
    arr    
end

# Send string to msieve. Return factors as list of Integers.
mfactorl(opts::Msieveopts) = factor_strings_to_integers(runallmsieve(opts))

# Send string to msieve. Return factors in Dict, like Base.factor
function mfactor(opts::Msieveopts)
    arr = mfactorl(opts)
    T = eltype(arr)
    d = Dict{T,Int}()
    for i in arr d[i] = get(d,i,0) + 1 end
    d
end

function mfactor(x::Union{AbstractString,Integer}; deadline::Integer = 0, logfile::AbstractString = "", ecm::Bool = false,
                 info::Bool = false)
    mfactor(Msieveopts(string(x),deadline,logfile,ecm,info))
end

for (thetype) in ( :AbstractString, :Integer ) 
    @eval begin
        function mfactor{T<:$thetype}(a::AbstractArray{T,1}; dl::Integer=0, logfile::AbstractString = "",
                                      ecm::Bool = false, info::Bool = false)
            outa = Array(Any,0)
            for x in a
                res = mfactor(x; deadline=dl, logfile=logfile, ecm=ecm, info=info)
                push!(outa,res)
            end
            outa
        end
    end
end
