import Base: getindex, length
export primetables, piandrem

immutable PrimeTable
    data::Array{Int128,1}
    incr::Int128
    maxn::Int128
    expn::Int
end    

length(t::PrimeTable) = length(t.data)
getindex(t::PrimeTable,i) = (t.data)[i]

#  Return a list (pi-tab, min, rem), where `pi-tab' is
#  the value of prime pi function at argument `min',
#  and `rem'= `x'-`min'"
function piandrem(t::PrimeTable, x)
    (q,rem) = divrem(x,t.incr)
   return ((t.data)[q], t.incr * q, rem)
end

# Find the finest increment table and look up value for x
function piandrem{T<:Real}(x::T)
    j = 0
    for i in 1:length(primetables)
        t = primetables[i]
        if x < t.maxn
            j = i
            break
        end
    end
    println("Using table $j")
    j == 0 && error("x is too large!")
    piandrem(primetables[j],x)
end

# Look up prime pi in table, compute remaining primes
function countprimes(stop)
    (count,i,rem) = piandrem(convert(Int128,stop))
    println("count $count, i $i, rem $rem")
    res = count + ntcountprimes(i,i+rem)
    convert(Int128,res)
end

# Read the tables from a binary data file.
function _readbintables()
    fn = Pkg.dir("PrimeSieve") * "/data/primetables128bin.dat"
    mystream = open(fn)
    buf = zeros(Int,1)
    read!(mystream,buf)
    numtables = buf[1]
    bintables = Array(Array{Int128,1},0)
    for itab in 1:numtables
        read!(mystream,buf)
        numprimes = buf[1]
        a = Array(Int128,numprimes)
        read!(mystream,a)
        push!(bintables,a)
    end
    close(mystream)
    return bintables
end

# Read binary tables and make table data structures.
function loadprimetables()
    bintables = _readbintables()
    tables = Array(PrimeTable,length(bintables))
    base = 10
    for i in 1:length(bintables)
        data = bintables[i]
        expn = i
        incr = 10^expn
        maxn = incr * length(data)
        pt = PrimeTable(data,incr,maxn,expn)
        tables[i] = pt
    end
    tables
end

# Read the tables now.
const primetables = loadprimetables();
