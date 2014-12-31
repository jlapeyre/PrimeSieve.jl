# This loop was causing all memory to be allocated. It stopped,
# but all I did was add a println and then remove it.
for (typef, ptype) in ((:int32, :Int32), (:int64 ,:Int64), (:uint64 ,:Uint64))
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
@test typeof(genprimes("10")[1]) == Uint64
@test countprimes(a,b) == ntcountprimes(a,b)
@test genprimes(c) == Base.primes(c)
@test typeof(nprimes("10")[1]) == Uint64
@test ntcountprimes("10^9") == 50847534

@test countprimes(:(10^19)) == 234057667276344607
@test countprimes("10^20") == 2220819602560918840
@test typeof(primelookup("2^63")) == (Int64,(Int128,Int128,Int128))

@test apopcount(zeros(10)) == 0
@test apopcount([])
@test apopcount([typemax(Uint64)]) == 64
@test apopcount([convert(Uint64,true)]) == 1
@test apopcount([true]) == 0
