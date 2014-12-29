using BinDeps

# BinDeps.debug("PrimeSieve") causes stack overflow here
# After build, and on cli, do:
# using BinDeps; BinDeps.debug("PrimeSieve")
julialibpath = dirname(Sys.dlpath(dlopen("libgmp")))
ENV["LDFLAGS"] = "-L$julialibpath"
# This should not be neccessary, but it is.
ENV["LIBS"] = "-lgmp"

include("../src/compatibility.jl")

@BinDeps.setup

gmpecm = library_dependency("gmpecm", aliases = ["libecm"])
primesieve = library_dependency("primesieve", aliases = ["libprimesieve"])
primecount = library_dependency("primecount", aliases = ["libprimecount"], depends = [primesieve])
cprimecount = library_dependency("cprimecount", aliases = ["libcprimecount"], depends = [primecount])
smsieve = library_dependency("smsieve", aliases = ["libsmsieve"], depends = [gmpecm])

provides(Sources, URI("http://dl.bintray.com/kimwalisch/primesieve/primesieve-5.4.1.tar.gz"), primesieve)
provides(Sources, URI("http://dl.bintray.com/kimwalisch/primecount/primecount-1.4.tar.gz"), primecount)
provides(Sources, URI("https://gforge.inria.fr/frs/download.php/file/32159/ecm-6.4.4.tar.gz"), gmpecm)
provides(Sources, URI("https://github.com/jlapeyre/msieve-shared/archive/v0.0.1.tar.gz"), smsieve,unpacked_dir="msieve-shared-0.0.1")

provides(BuildProcess, Autotools(libtarget = ".libs/libecm."*BinDeps.shlib_ext, configure_options = String["--enable-shared", "--enable-openmp","--with-gmp-lib=$julialibpath"
                                 ]), gmpecm)
provides(BuildProcess, Autotools(libtarget = ".libs/libprimesieve."*BinDeps.shlib_ext), primesieve)
provides(BuildProcess, Autotools(libtarget = ".libs/libprimecount."*BinDeps.shlib_ext), primecount)


#cpcsrcdir = BinDeps.cpcsrcdir(cprimecount)
cpcsrcdir = joinpath(BinDeps.depsdir(cprimecount),"src","cprimecount")
provides(SimpleBuild,
    (@build_steps begin
        @build_steps begin
            ChangeDirectory(cpcsrcdir)
            `make`
            `make install`            
        end
    end),cprimecount, os = :Unix)


smsrcdir = joinpath(BinDeps.depsdir(cprimecount),"src","msieve-shared-0.0.1")

provides(SimpleBuild,
         (@build_steps begin
             GetSources(smsieve)
             @build_steps begin
                 ChangeDirectory(smsrcdir)
                 `cp ../localmsieve/Makefile .`
                 `make ECM=1  msieveshared`
                 `cp libsmsieve.so ../../usr/lib/libsmsieve.so`
             end
         end),smsieve, os = :Unix)
         

@BinDeps.install Dict([(:gmpecm, :gmpecm),(:primecount, :primecount), (:primesieve, :primesieve),
                       (:cprimecount, :cprimecount), (:smsieve, :smsieve) ])
