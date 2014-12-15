import Base: getindex, length
export primetables

# A single table of π(x) with constant increment between values of x
immutable PrimeTable
    data::Array{Int128,1}  # values of π(x)
    incr::Int128           # increment to x for successive elements
    maxn::Int128           # largest value in data. (The last element)
    expn::Int              # log10(incr), an integer
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

# Find the table with finest increments such that
# x falls on or between incrments and look up value for x
function piandrem{T<:Real}(x::T)
    j = 0
    for i in 1:length(primetables)
        t = primetables[i]
        if x < t.maxn
            j = i
            break
        end
    end
    j == 0 && error("x is too large!")
    piandrem(primetables[j],x)
end

# Look up prime pi in table, compute remaining primes
function countprimes(stop)
    (count,i,rem) = piandrem(convert(Int128,stop))
    res = count + ntcountprimes(i,i+rem)
    convert(Int128,res)
end

function countprimes(start,stop)
    (count1,i1,rem1) = piandrem(convert(Int128,start))
    (count2,i2,rem2) = piandrem(convert(Int128,stop))
    n1 = ntcountprimes(i1,i1+rem1)
    n2 = ntcountprimes(i2,i2+rem2)
    convert(Int128, count2 - count1 + n2 - n1)
end    

# Read the tables from a binary data file.  First Int is number of
# tables.  Second Int is number of elements in first table.  Next come
# all the elements in the table, then the number of elements for the
# next table, etc.
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
