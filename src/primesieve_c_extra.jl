export apopcount

# count the number of ones in the binary representation of a
# the function operates on 8 bytes at a time, so we truncate if necessary.
# From the libprimesieve comment:
# The 64-bit tree merging popcount algorithm is due to
# Cédric Lauradoux, it is described in his paper:
# http://perso.citi.insa-lyon.fr/claurado/ham/overview.pdf
# http://perso.citi.insa-lyon.fr/claurado/hamming.html
function apopcount(a::Array)
    sz = div(sizeof(a),8)
    ret = ccall((:primesieve_popcount,libccountname), UInt64, (Ptr{Void}, UInt64), a, sz)
    convert(Int,ret)
end
