import Base.convert
using OrderedCollections

function append_namedtuples(nts)
    dct = Dict()
    for par in keys(nts)
        if length(size(nts[par])) > 2
            r, s, c = size(nts[par])
            dct[par] = reshape(nts[par], r, s*c)
        else
            s, c = size(nts[par])
            dct[par] = reshape(nts[par], s*c)
        end
    end
    (;dct...)
end

"""

# convert_a3d

# Convert the output file(s) created by cmdstan to a NamedTuple. Append all chains

$(SIGNATURES)

"""
function convert(T, df)
    dct = OrderedDict()
    for col_name in names(df)
        dct[Symbol(col_name)] = df[:, col_name]
    end
    nt = (;dct...)
end
