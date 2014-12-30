# Warning-free compatibility with 0.3 and 0.4
# Does not allow construction with Dict(...) in 0.3
# Bummer. Does not seem to be worth much.
# My test code is either illegal or deprecated in each of 0.3 and 0.4
if VERSION < v"0.4.0-dev+980"
    macro Dict(pairs...)
        Expr(:dict, pairs...)
    end
else
    macro Dict(pairs...)
        Expr(:call, :Dict, pairs...)
    end
end
