function convert_matrices(d::Union{NamedTuple, Dict})
    dct = typeof(d) <: NamedTuple ? dct = convert(Dict, d) : deepcopy(d)
    for key in keys(dct)
        if typeof(dct[key]) <: Array
            dct[key] = permutedims(dct[key], length(size(dct[key])):-1:1)
        end
    end
    dct
end

function convert_matrices(d::T) where {T <: Vector}
    dd = copy(d)
    dda = []
    for i in 1:length(dd)
        append!(dda, [convert_matrices(dd[i])])
    end
    dda
end

"""

Update data or init R files.

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `m`                             : CmdStanModels object
* `input`                         : Input data or init values
* `num_chains`                    : Number of chains in model
* `fname_part="data"`             : Data or init R files to be created
```

Not exported.
"""
function update_json_files(m, input, num_chains, fname_part="data")
  
    m_field = fname_part == "data" ? m.data_file : m.init_file

    if typeof(input) <: OrderedCollections.OrderedDict
        dct = Dict()
        for key in keys(input)
            dct[Symbol(key)] = input[key]
        end
        input = dct
    end

    if typeof(input) <: Union{NamedTuple, Dict, Array}
        input = convert_matrices(input)
    end

    if typeof(input) <: NamedTuple || typeof(input) <: Dict
        for i in 1:num_chains
            open(m.output_base*"_$(fname_part)_$i.json", "w") do f
                JSON.print(f, input)
            end
            append!(m_field, [m.output_base*"_$(fname_part)_$i.json"])
        end
    elseif  typeof(input) <: Array
        if length(input) == num_chains
            for (i, d) in enumerate(input)
                open(m.output_base*"_$(fname_part)_$i.json", "w") do f
                    JSON.print(f, d)
            end
            append!(m_field, [m.output_base*"_$(fname_part)_$i.json"])
        end
    else
        @info "Data vector length does not match number of chains,"
        @info "only first element in data vector will be used,"
        for i in 1:num_chains
            open(m.output_base*"_$(fname_part)_$i.json", "w") do f
                JSON.print(f, input[1])
            end
            append!(m_field, [m.output_base*"_$(fname_part)_$i.json"])
        end
    end
    elseif typeof(input) <: AbstractString && length(input) > 0
        for i in 1:num_chains
            cp(input, "$(m.output_base)_$(fname_part)_$i.json", force=true)
            append!(m_field, [m.output_base*"_$(fname_part)_$i.json"])
        end
    else
    error("\nUnrecognized input argument: $(typeof(input))\n")
    end
  
end


