import Base: getindex, length, eltype
export primetables, primelookup, primetableinfo, primetablefilename
export primetabletype, primesievetype

# A single table of π(x) with constant increment between values of x
immutable PrimeTable
    data::Array{Int128,1}  # values of π(x)
    incr::Int128           # increment to x for successive elements
    maxn::Int128           # largest value in data. (The last element)
    expn::Int              # log10(incr), an integer
end    

const Zero = zero(Int128)

length(t::PrimeTable) = length(t.data)
getindex(t::PrimeTable,i) = (t.data)[i]
eltype(t::PrimeTable) = eltype(t.data)
getindex(t::Array{PrimeTable}, i,j) = t[i][j]
primetabletype() = eltype(primetables[1])
primesievetype() = Uint64

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
    for i in 1:length(primetables) x <= primetables[i].maxn && (j = i; break) end
    j == 0 && error("x is too large!")
    piandrem(primetables[j],x)
end

function primelookup(x)
    x = conv128(x)
    j = 0
    for i in 1:length(primetables) x < primetables[i].maxn && (j = i ; break) end
    j == 0 && error("x is too large!")
   (j,piandrem(primetables[j],x))
end

# Look up prime pi in table, compute remaining primes
function _countprimes(stop)
    (count,i,rem) = piandrem(int128(stop))
    return (rem == Zero) ? convert(Int128,count) :
    convert(Int128,count+ntcountprimes(i,i+rem))
end

function _countprimes(start,stop)
    (count1,i1,rem1) = piandrem(int128(start))
    (count2,i2,rem2) = piandrem(int128(stop))
    n1 = rem1 == Zero ? Zero : ntcountprimes(i1,i1+rem1)
    n2 = rem2 == Zero ? Zero : ntcountprimes(i2,i2+rem2)
    convert(Int128, count2 - count1 + n2 - n1)
end    

const _primetablefilename = Pkg.dir("PrimeSieve") * "/data/primetables128bin.dat"
primetablefilename() = _primetablefilename

# Read the tables from a binary data file.  First Int is number of
# tables.  Second Int is number of elements in first table.  Next come
# all the elements in the table, then the number of elements for the
# next table, etc.
function _readbintables()
    fn = primetablefilename()
    if stat(fn).inode == 0
        error("Can't find file containing prime tables, $fn\n"
              * "Maybe your package installation is corrupt.")
    end
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
    base = int128(10)
    for i in 1:length(bintables)
        data = bintables[i]
        expn = i
        incr = base^expn
        maxn = incr * length(data)
        pt = PrimeTable(data,incr,maxn,expn)
        tables[i] = pt
    end
    tables
end

function primetableinfo()
    dtype = eltype(primetables[1])
    println("Tables of π(x). element type: $dtype. Listed are: table number, increment in x (and first value of x),")
    println("number of entries in the table, largest x in table.\n")
    println("table  incr    tab len  max x")
    for i in 1:length(primetables)
        t = primetables[i]
        l = length(t)
        ip = rpad("$i",6)
        incr = rpad("10^$i",7)
        ll = int(log10(l))
        len = rpad("10^$ll",8)
        maxn = "10^$(ll+i)"
        println("$ip $incr $len $maxn")    
    end
end

# Read the tables now.
const primetables = loadprimetables();
