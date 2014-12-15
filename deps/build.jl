using BinDeps

@BinDeps.setup

primesieve = library_dependency("primesieve", aliases = ["libprimesieve"])

provides(Sources,URI("http://dl.bintray.com/kimwalisch/primesieve/primesieve-5.4.1.tar.gz"),primesieve)
provides(BuildProcess,Autotools(libtarget = ".libs/libprimesieve."*BinDeps.shlib_ext),primesieve)

# The windows and osx binaries do not contain the library, only the executable.

#@windows_only begin
#    provides(Binaries, {URI("http://dl.bintray.com/kimwalisch/primesieve/primesieve-5.4-win$WORD_SIZE.zip") => primesieve}, os = :Windows )
#end

#@osx_only begin
#    if Pkg.installed("Homebrew") === nothing
#        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")  end
#    using Homebrew
#    provides( Homebrew.HB, "zeromq32", primesieve, os = :Darwin )
#end

@BinDeps.install [:primesieve => :primesieve]
