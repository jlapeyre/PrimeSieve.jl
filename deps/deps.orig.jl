# This is an auto-generated file; do not edit

# Pre-hooks

# Macro to load a library
macro checked_lib(libname, path)
    (dlopen_e(path) == C_NULL) && error("Unable to load \n\n$libname ($path)\n\nPlease re-run Pkg.build(package), and restart Julia.")
    quote const $(esc(libname)) = $path end
end

# Load dependencies
@checked_lib primecount "/home/jlapeyre/.julia/v0.3/PrimeSieve/deps/usr/lib/libprimecount.so"
@checked_lib primesieve "/home/jlapeyre/.julia/v0.3/PrimeSieve/deps/usr/lib/libprimesieve.so"

# Load-hooks

