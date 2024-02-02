"""

Read .csv output files created by Stan's cmdstan executable
and extract a (possibly nested) variable.

$(SIGNATURES)

### Required arguments
```julia
* `csvfiles` : Vector of file names
* `var` : requested (nested) column
```

### Keyword arguments
```julia
* `nested` : If true, return nsamples x nchains matrices, else a single matrix
```

Exported
"""
function extract_reshape(csvfiles, var::Union{String, Symbol}; nested=true)
    df = read_csvfiles(csvfiles, :dataframe)
    nchains = length(csvfiles)
    nsamples = Int(size(df, 1) / nchains)
    if !(String(var) in StanIO.find_nested_columns(df))
        if String(var) in names(df)
            return reshape(df[!, var], (nsamples, nchains))
        else
            @warn "Variable $var is not found the .csv files."
            return nothing
        end
    else
        df = StanIO.select_nested_column(df, var)
        dct = parse_header(names(df))
        ndf = stan_variables(dct, df)
    end
    if nested
        return reshape(Array(ndf), (nsamples, nchains))
    else
        if typeof(ndf[1, var]) == Matrix{Tuple}
            @warn "Non-nested tuples not supported in `extract_reshape()`."
            return nothing
        end
        dims = (nsamples, nchains, size(ndf[1, var])...)
        a = zeros(dims...)
        el = Array(StanIO.select_nested_column(df, :m))
        for i in 1:nsamples
            for j in 1:nchains
                for k = 1:size(ndf[1, var], 1)
                    for l = 1:size(ndf[1, var], 2)
                        a[i, j, k, l] = el[i + (j-1)*1000, :][k + (l-1)*4]
                    end
                end
            end
        end
        return a
    end
end
