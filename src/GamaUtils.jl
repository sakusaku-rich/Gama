module GamaUtils
    export get_char, str_slice, find

    function get_char(s::String, n::Int64)::Char
        
        idx = 1
        for i in [1:n-1;]
            idx = nextind(s, idx) 
        end
        
        s[idx]
    end

    
    function str_slice(s::String, f::Int64, t::Int64)::String
        str = ""
        c = 0
        idx = 0
        
        while true
            idx = nextind(s, idx) 
            c += 1
            if f <= c <= t
                str *= s[idx]
            end
            if c == length(s)
                break
            end
        end
        
        str
    end

    
    function find(a::Vector{Int64}, v::Int64)::Int64
        
        for (i,x) in enumerate(a)
            if x == v
                return i
            end
        end
        
        -1
    end
end