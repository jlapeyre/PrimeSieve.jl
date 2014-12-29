using BinDeps
@BinDeps.setup
include("../src/compatibility.jl")

primesieve = library_dependency("primesieve", aliases = ["libprimesieve"])
primecount = library_dependency("primecount", aliases = ["libprimecount"], depends = [primesieve])
cprimecount = library_dependency("cprimecount", aliases = ["libcprimecount"], depends = [primecount])

provides(Sources, URI("http://dl.bintray.com/kimwalisch/primesieve/primesieve-5.4.1.tar.gz"), primesieve)
provides(Sources, URI("http://dl.bintray.com/kimwalisch/primecount/primecount-1.4.tar.gz"), primecount)

provides(BuildProcess, Autotools(libtarget = ".libs/libprimesieve."*BinDeps.shlib_ext), primesieve)
provides(BuildProcess, Autotools(libtarget = ".libs/libprimecount."*BinDeps.shlib_ext), primecount)

srcdir = BinDeps.srcdir(cprimecount)
srcdir = joinpath(BinDeps.depsdir(cprimecount),"src","cprimecount")

provides(SimpleBuild,
    (@build_steps begin
        @build_steps begin
            ChangeDirectory(srcdir)
            `make`
            `make install`            
        end
    end),cprimecount, os = :Unix)


@BinDeps.install Dict([(:primecount, :primecount), (:primesieve, :primesieve),
                       (:cprimecount, :cprimecount)
                      ])
