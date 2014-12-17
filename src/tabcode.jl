println("Tables of π(x). Listed are: table number, increment in x (and first entry),")
println("length of table, largest x in table.\n")
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
