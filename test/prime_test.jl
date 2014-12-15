for (typef, ptype) in ((:int32, :Int32), (:int64 ,:Int64), (:uint64 ,:Uint64))
    @eval begin
        p = primes($typef(1000))
        @test length(p) == 168
        @test eltype(p) == $ptype 
    end
end


a = 2423842346
b = 7392340328
c = 100000
@test countprimes(b) == ntcountprimes(b)
@test countprimes(a,b) == ntcountprimes(a,b)
@test primes(c) == Base.primes(c)
