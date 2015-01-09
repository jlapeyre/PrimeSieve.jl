using BinDeps

# Find the directory with installed Julia libraries
julialibpath = dirname(Sys.dlpath(dlopen("libgmp")))

# Set link flags for Autotools external packages
# This is only needed for the ecm package
ENV["LDFLAGS"] = "-L$julialibpath"
# config.log shows that BinDeps also set the following as well.
# We have copied gmp.h from Julia source tree to this location.
# Maybe Julia should also copy it to the installation tree.
ENV["CPPFLAGS"] = "-I../../usr/include"

# -Wl... makes the libecm search for libgmp in the Julia installation rather than the system.
# (The  -lgmp should not be neccessary, but it is.
# The Makefile writes -lgmp multiple times in link commands. -lm occurs five times per link command.)
ENV["LIBS"] = "-lgmp -Wl,-rpath -Wl,$julialibpath"

@BinDeps.setup

gmpecm = library_dependency("gmpecm", aliases = ["libecm"])
primesieve = library_dependency("primesieve", aliases = ["libprimesieve"])
primecount = library_dependency("primecount", aliases = ["libprimecount"], depends = [primesieve])
cprimecount = library_dependency("cprimecount", aliases = ["libcprimecount"], depends = [primecount])
smsieve = library_dependency("smsieve", aliases = ["libsmsieve"], depends = [gmpecm])

provides(Sources, URI("http://dl.bintray.com/kimwalisch/primesieve/primesieve-5.4.1.tar.gz"), primesieve)
provides(Sources, URI("http://dl.bintray.com/kimwalisch/primecount/primecount-1.4.tar.gz"), primecount)
provides(Sources, URI("https://gforge.inria.fr/frs/download.php/file/32159/ecm-6.4.4.tar.gz"), gmpecm)
# Getting zip- or tarball from github with a predictable name is mysterious to me.
# But, pushing tags allows downloading this way...
provides(Sources, URI("https://github.com/jlapeyre/msieve-shared/archive/v0.0.3.tar.gz"), smsieve,unpacked_dir="msieve-shared-0.0.3")

# The Autotools BuildProcess will try to download the source using the data above.
# It would not be hard to modify BinDeps to allow skipping the download.
provides(BuildProcess, Autotools(libtarget = ".libs/libecm."*BinDeps.shlib_ext, configure_options =
                                 String["--enable-shared", "--enable-openmp","--with-gmp-lib=$julialibpath"]), gmpecm)
provides(BuildProcess, Autotools(libtarget = ".libs/libprimesieve."*BinDeps.shlib_ext), primesieve)
provides(BuildProcess, Autotools(libtarget = ".libs/libprimecount."*BinDeps.shlib_ext), primecount)

# BinDeps.depsdir(cprimecount) is /pathto/PackageName/deps
const cpcsrcdir = joinpath(BinDeps.depsdir(cprimecount),"src","cprimecount")
# This source for this library will not be downloaded; it is in this repo.
# BuildProcess and SimpleBuild may use the information in provides(Sources...
# Here, we need no such information, and so omit GetSources.
provides(SimpleBuild,
    (@build_steps begin
        ChangeDirectory(cpcsrcdir)
        `make`
        `make install`            
    end),cprimecount, os = :Unix)


# libsmsieve.so needs to know the location of libecm.so . Both are in deps/usr/lib .
# Since this is our own library, the hardcoded rpath is specified in the Makefile rather than
# passed via ENV as above.
smsrcdir = joinpath(BinDeps.depsdir(cprimecount),"src","msieve-shared-0.0.3")
provides(SimpleBuild,
         (@build_steps begin
             GetSources(smsieve)
             @build_steps begin
                 ChangeDirectory(smsrcdir)
                 `cp ../localmsieve/Makefile ../localmsieve/msieveshared.c .`
                 `make ECM=1  msieveshared`
                 `cp libsmsieve.so ../../usr/lib/libsmsieve.so`
             end
         end),smsieve, os = :Unix)

@BinDeps.install Dict([(:gmpecm, :gmpecm),(:primecount, :primecount), (:primesieve, :primesieve),
                       (:cprimecount, :cprimecount), (:smsieve, :smsieve) ])
