using .DataFrames
import .DataFrames: DataFrame

"""

# convert_a3d

# Convert the output file(s) created by cmdstan to a DataFrame.

$(SIGNATURES)

"""
function convert_a3d(a3d_array, cnames, ::Val{:dataframe})
    # Inital DataFrame
    df = DataFrame(a3d_array[:, :, 1], Symbol.(cnames))

    # Append the other chains
    for j in 2:size(a3d_array, 3)
        df = vcat(df, DataFrame(a3d_array[:, :, j], Symbol.(cnames)))
    end

    v = Int[]
    cnames = names(df)
    for (ind, cn) in enumerate(cnames)
        if length(findall(!isnothing, findfirst.("real", String.(split(cn, "."))))) > 0
            append!(v, [ind])
        end
    end
    if length(v) > 0
        for i in v
            df[!, String(cnames[i])] = Complex.(df[:, String(cnames[i])], df[:, String(cnames[i+1])])
            DataFrames.select!(df, Not(String(cnames[i+1])))
        end
        cnames = names(df)
        if length(v) > 0
            v = Int[]
            for (ind, cn) in enumerate(cnames)
                if length(findall(!isnothing, findfirst.("real", String.(split(cn, "."))))) > 0
                    append!(v, [ind])
                end
            end
            for i in v
                cnames[i] = cnames[i][1:end-5]
            end
        end
        #println(cnames)
        df = DataFrame(df, cnames)
    end

    for name in names(df)
        if name in ["treedepth__", "n_leapfrog__"]
            df[!, name] = Int.(df[:, name])
        elseif name == "divergent__"
            df[!, name] = Bool.(df[:, name])
        end
    end

    df
end

"""

# convert_a3d

# Convert the output file(s) created by cmdstan to a Vector{DataFrame).

$(SIGNATURES)

"""
function convert_a3d(a3d_array, col_names, ::Val{:dataframes})

    df = Vector{DataFrame}(undef, size(a3d_array, 3))
    for j in 1:size(a3d_array, 3)
        df[j] = DataFrame(a3d_array[:, :, j], Symbol.(col_names))

        v = Int[]
        cnames = names(df[j])
        for (ind, cn) in enumerate(cnames)
            if length(findall(!isnothing, findfirst.("real", String.(split(cn, "."))))) > 0
                append!(v, [ind])
            end
        end
        if length(v) > 0
            for i in v
                df[j][!, String(cnames[i])] = Complex.(df[j][:, String(cnames[i])], df[j][:, String(cnames[i+1])])
                DataFrames.select!(df[j], Not(String(cnames[i+1])))
            end
            cnames = names(df[j])
            if length(v) > 0
                v = Int[]
                for (ind, cn) in enumerate(cnames)
                    if length(findall(!isnothing, findfirst.("real", String.(split(cn, "."))))) > 0
                        append!(v, [ind])
                    end
                end
                for i in v
                    cnames[i] = cnames[i][1:end-5]
                end
            end
            #println(cnames)
            df[j] = DataFrame(df[j], cnames)
        end

        for name in names(df[j])
            if name in ["treedepth__", "n_leapfrog__"]
                df[j][!, name] = Int.(df[j][:, name])
            elseif name == "divergent__"
                df[j][!, name] = Bool.(df[j][:, name])
            end
        end

    end

    df
end

"""

DataFrame()

# Block Stan named parameters, e.g. b.1, b.2, ... in a DataFrame.

$(SIGNATURES)

Example:

df_log_lik = DataFrame(m601s_df, :log_lik)
log_lik = Matrix(df_log_lik)

"""
function DataFrame(df::DataFrame, sym::Union{Symbol, String})
    n = string.(names(df))
    syms = string(sym)
    sel = String[]
    for (i, s) in enumerate(n)
        if length(s) > length(syms) && syms == n[i][1:length(syms)] &&
            n[i][length(syms)+1] in ['[', '.', '_']
            append!(sel, [n[i]])
        end
    end
    length(sel) == 0 && error("$syms not in $n")
    df[:, sel]
end
