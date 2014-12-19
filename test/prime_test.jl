for (typef, ptype) in ((:int32, :Int32), (:int64 ,:Int64), (:uint64 ,:Uint64))
    @eval begin
        p = genprimes($typef(1000))
        @test length(p) == 168
        @test eltype(p) == $ptype 
    end
end


a = 2423842346
b = 7392340328
c = 100000
@test countprimes(b) == ntcountprimes(b)
@test countprimes(a,b) == ntcountprimes(a,b)
@test genprimes(c) == Base.primes(c)

# fixed overflow bugs
@test countprimes(int128(10)^19,int128(10)^19+10^3) == 28
@test countprimes(int128(10)^19+10^9) == int128(234057667299198865)

@test countprimes(:(10^19)) == 234057667276344607
@test countprimes(:(10^19 + 10^9)) == 234057667299198865

@test length(genprimes(genprimes(:(10^19) , :(10^19+10^3)))) == 28
