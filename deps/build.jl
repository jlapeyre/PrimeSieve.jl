using BinDeps
@BinDeps.setup
include("../src/compatibility.jl")

primesieve = library_dependency("primesieve", aliases = ["libprimesieve"])
primecount = library_dependency("primecount", aliases = ["libprimecount"], depends = [primesieve])
cprimecount = library_dependency("cprimecount", aliases = ["libcprimecount"], depends = [primecount])

provides(Sources, URI("http://dl.bintray.com/kimwalisch/primesieve/primesieve-5.4.1.tar.gz"), primesieve)
provides(Sources, URI("http://dl.bintray.com/kimwalisch/primecount/primecount-1.4.tar.gz"), primecount)

csrcdir = BinDeps.srcdir(cprimecount)
#println("csrcdir is $csrcdir")
#provides(Sources, ("",), cprimecount)

provides(BuildProcess, Autotools(libtarget = ".libs/libprimesieve."*BinDeps.shlib_ext), primesieve)
provides(BuildProcess, Autotools(libtarget = ".libs/libprimecount."*BinDeps.shlib_ext), primecount)
provides(BuildProcess, Autotools(libtarget = "libcprimecount."*BinDeps.shlib_ext), cprimecount)

@BinDeps.install Dict([(:primecount, :primecount), (:primesieve, :primesieve),
                       (:cprimecount, :cprimecount)
                      ])
