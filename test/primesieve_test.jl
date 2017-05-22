# This loop was causing all memory to be allocated. It stopped,

# but all I did was add a println and then remove it.
#for (typef, ptype) in ((:int32, :Int32), (:int64 ,:Int64), (:uint64 ,:Uint64))
for (typef, ptype) in ((:Int32, :Int32), (:Int64 ,:Int64), (:UInt64 ,:UInt64))
     @eval begin
         p = genprimes($typef(1000))
         @test length(p) == 168
         @test eltype(p) == $ptype 
     end
end


a = 24238423
b = 73923403
c = 100000

@test countprimes(b) == ntcountprimes(b)
@test typeof(genprimes("10")[1]) == UInt64
@test countprimes(a,b) == ntcountprimes(a,b)
# Don't want to import or require primes, I suppose
#@test genprimes(c) == Base.primes(c)
@test typeof(nprimes("10")[1]) == UInt64
@test ntcountprimes("10^9") == 50847534

## FIXME: bitrot,  get 234057667276344607 == -234057667276344607
#@test countprimes(:(10^19)) == 234057667276344607
## FIXME: bitrot
#@test countprimes("10^20") == 2220819602560918840

##@test typeof(primelookup("2^63")) == (Int64,(Int128,Int128,Int128))
@test typeof(primelookup("2^63")) == Tuple{Int64,Tuple{Int128,Int128,Int128}}


@test apopcount(zeros(10)) == 0
@test apopcount([]) == 0
@test apopcount([typemax(UInt64)]) == 64
@test apopcount([convert(UInt64,true)]) == 1
@test apopcount([true]) == 0

# fix bug. asking for limits below first table entry.
@test countprimes(7) == 4
@test countprimes(2,7) == 3
