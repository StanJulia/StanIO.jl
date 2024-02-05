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
        res = reshape(Array(ndf), (nsamples, nchains))
    end
    if nested
        return res
    else
        if typeof(ndf[1, var]) == Matrix{Tuple}
            @warn "Non-nested tuples not supported in `extract_reshape()`."
            return nothing
        end
        a = combinedims(res)
        a = permutedims(a, (3, 4, 1, 2))
        return a
    end
end

"""

Read .csv output files created by Stan's cmdstan executable
and extract a (possibly nested) variable.

$(SIGNATURES)

### Required arguments
```julia
* `a3d` : Array n_samples x n_variables x n_chains
* `col_names` : Vector of names
* `var` : requested (nested) column
```

### Keyword arguments
```julia
* `nested` : If true, return nsamples x nchains matrices, else a single matrix
```

Exported
"""
function extract_reshape(a3d, col_names, var::Union{String, Symbol}; nested=true)
    df = convert_a3d(a3d, col_names, Val(:dataframe))
    nsamples, nvars, nchains = size(a3d)
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
        res = reshape(Array(ndf), (nsamples, nchains))
    end
    if nested
        return res
    else
        if typeof(ndf[1, var]) == Matrix{Tuple}
            @warn "Non-nested tuples not supported in `extract_reshape()`."
            return nothing
        end
        a = combinedims(res)
        a = permutedims(a, (3, 4, 1, 2))
        return a
    end
end
