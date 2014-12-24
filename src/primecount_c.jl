export primepi, primepi_deleglsise

const libccountname = "libcprimecount.so"
const libcppcountname = "libprimecount.so.1"

function primepi(n)
#    res = ccall((:pi, libccountname), Int64, (Int64,), convert(Int64,n))
    res = ccall((:_ZN10primecount2piEl, libcppcountname), Int64, (Int64,), convert(Int64,n))    
end

function primepi_deleglsise(n)
    res = ccall((:_ZN10primecount18pi_deleglise_rivatEl, "libprimecount.so.1"),  Int64, (Int64,), convert(Int64,n))
#    res = ccall((:pi_deleglise_rivat, libccountname), Int64, (Int64,), convert(Int64,n))
end
