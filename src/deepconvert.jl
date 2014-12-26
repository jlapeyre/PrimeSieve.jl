export @bi_str, @i128_str

# Copied this from my private repo SomeUtils

# Define a function that converts Reals in an expression
# to a given number type and evaluates the expression.
# It is meant to allow entering expressions for numbers
# without overflow.
# example:
# @mkdeepconvert(convuint, uint64)
# convuint( :( 2^63 ))
macro mkdeepconvert(ff, ccfunc)
    f = esc(ff)
    cfunc = esc(ccfunc)
    quote
        function ($f)(ex::Expr)
            if ex.args[1] == ://
                return ($cfunc)(eval(ex))
            else 
              eval(Expr(ex.head, map(
              (x) ->
                begin
                    tx = typeof(x)
                    if tx <: Real
                        return ($cfunc)(x)
                    elseif  tx == Expr
                        return ($f)(x)
                    else
                        return x
                    end
                end,
               ex.args)...))
            end 
        end
        ($f)(x::String) = ($f)(parse(x))
        ($f)(x) = ($cfunc)(x)
    end
end

# Convert numbers to Int128 or Uint64, hopefully the subexpressions
# have not overflowed.  Eg. 10^19.
# Unquoted expressions pass through
@mkdeepconvert(conv128,int128)
@mkdeepconvert(convu64,uint64)
@mkdeepconvert(convint,int64)
@mkdeepconvert(deepbigint,BigInt)
macro bi_str(s) deepbigint(s) end
macro i128_str(s) conv128(s) end
