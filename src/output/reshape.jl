function find_nested_columns(df::DataFrame)
    n = string.(names(df))
    nested_columns = String[]
    for (i, s) in enumerate(n)
        r = split(s, ['.', ':'])
        if length(r) > 1
            append!(nested_columns, [r[1]])
        end
    end
    unique(nested_columns)
end

function select_nested_column(df::DataFrame, var::Union{Symbol, String})
    n = string.(names(df))
    sym = string(var)
    sel = String[]
    for (i, s) in enumerate(n)
		splits = findall(c -> c in ['.', ':'], s)
		if length(splits) > 0
			#println((splits, sym, s, length(s), s[1:splits[1]-1]))
	        if length(splits) > 0 && sym == s[1:splits[1]-1]
	            append!(sel, [n[i]])
	        end
		end
    end
    length(sel) == 0 && @warn "$sym not in $n"
    #println(sel)
    df[:, sel]
end

@enum VariableType SCALAR=1 COMPLEX TUPLE ARRAY

struct Variable
    name::AbstractString # Name as in Stan .csv file. For nested fields, just the initial part.
    # For arrays with nested parameters, this will be for the first element
    # and is relative to the start of the parent
    start_idx::Int # Where to start (resp. end) reading from the flattened array.
    end_idx::Int
    # Rectangular dimensions of the parameter (e.g. (2, 3) for a 2x3 matrix)
    # For nested parameters, this will be the dimensions of the outermost array.
    dimensions::Tuple
    type::VariableType # Type of the parameter
    contents::Vector{Variable} # Array of possibly nested variables
end

function columns(v::Variable)
	return v.start_idx:v.end_idx-1
end

function num_elts(v::Variable)
	return prod(v.dimensions)
end

function elt_size(v::Variable)
	return v.end_idx - v.start_idx
end

function _munge_first_tuple(fld::AbstractString)
	return "dummy_" * String(split(fld, ":"; limit=2)[2])
end

function _get_base_name(fld::AbstractString)
	return String(split(fld, [':', '.'])[1])
end

function _from_header(hdr)
	header = String.(vcat(strip.(hdr), "__dummy"))
	#println(header)
	entries = header
	params = Variable[]
	var_type = SCALAR
	munged_header = String[]
	start_idx = 1
	name = _get_base_name(entries[1])
	for i in 1:length(entries)-1
		entry = entries[i]
		next_name = _get_base_name(entries[i+1])
		if next_name !== name
			if isnothing(findfirst(':', entry))
				splt = split(entry, ".")[2:end]
				dims = isnothing(splt) ? () : Meta.parse.(splt)
				var_type = SCALAR
				contents = Variable[]
				append!(params, [Variable(name, start_idx, i+1, tuple(dims...), var_type, contents)])
			elseif !isnothing(findfirst(':', entry))
				dims = Meta.parse.(split(entry, ":")[1] |> x -> split(x, ".")[2:end])
				munged_header = map(_munge_first_tuple, entries[start_idx:i])
				var_type = TUPLE
				append!(params, [Variable(name, start_idx, i+1, tuple(dims...), var_type, 
					_from_header(munged_header))])
			end
			start_idx = i + 1
			name = next_name
		end
	end
	return params
end
	

function parse_header(header::Vector{String})
	d = Dict{String, Variable}()
	for param in _from_header(header)
		d[param.name] = param
	end
	d
end

function dtype(v::Variable, top=true)
	if v.type == Tuple
		elts = [("$(i + 1)", dtype(p, false)) for (i, p) in enumerate(v.contents)]
		dtype = dtype.(elts)
	elseif v.type == Scalar
		dtype = Number
	end

	if top
		return dtype
	else
		return (dtype, v.dimensions)
	end
end

function _extract_helper(v::Variable, df::DataFrame, offset=0)
	the_start = v.start_idx + offset
	the_end = v.end_idx - 1 + offset
	if v.type == SCALAR
		if length(v.dimensions) == 0
			return Array(df[:, the_start])
		else
			return [reshape(Array(df[i, the_start:the_end]), v.dimensions...) for i in 1:size(df, 1)]
		end
	elseif v.type == TUPLE
		elts = fill(0.0, nrow(df))
		for idx in 1:num_elts(v)
			off = Int((idx - 1) * elt_size(v)//num_elts(v) - 1)
			for param in v.contents
				elts = hcat(elts, _extract_helper(param, df, the_start + off))
			end
		end
		return [Tuple(elts[i, 2:end]) for i in 1:nrow(df)]
	end
end

function extract_helper(v::Variable, df::DataFrame, offset=0)
	return _extract_helper(v, df)
end

function stan_variables(dct::Dict{String, Variable}, df::DataFrame)
	res = DataFrame()
	for key in keys(dct)
		res[!, dct[key].name] = extract_helper(dct[key], df)
	end
	res
end

export
	parse_header,
	stan_variables