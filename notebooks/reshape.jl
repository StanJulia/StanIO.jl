### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 3d7c5e2c-8eba-11ee-02c7-5382f0852ca2
using Pkg

# ╔═╡ a1328860-a754-4eb8-9855-e18d9ab50c0c
Pkg.activate(expanduser("~/.julia/dev/StanIO"))

# ╔═╡ ecf1f379-7774-4a41-928e-be10be1786b4
begin
	using StanIO
	using DataFrames
	using JSON
	using NamedTupleTools
	using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF
end

# ╔═╡ e953be75-6f32-4a33-bded-a809ff38e5cd
md" ### Translation of [stanio](https://github.com/WardBrian/stanio) by Brian Ward."

# ╔═╡ 789c3f0b-8179-4126-baf5-fdd47b1938f5
md" ##### Widen the cells."

# ╔═╡ c08d0f35-92fb-4e10-81a6-5a68eea4d046
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 10%);
	}
</style>
"""

# ╔═╡ 90dd4d50-2f82-4df6-94b1-a9a72bc44e59


# ╔═╡ ca0a71bb-7ac1-4c01-9a0a-24f1ce1479bd
md" #### Setup dataframes for testing."

# ╔═╡ 4e2984b1-435d-4cac-80ef-316060aa93af
begin
	csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "test_data")))
	csvfiles = joinpath.(joinpath(stanio_data, "test_data"), csvfiles)
end

# ╔═╡ 78d5367b-542a-41b6-85da-fc616046dba4
begin
 	df = StanIO.read_csvfiles(csvfiles, :dataframe)
	df = df[:, 8:end]
 end

# ╔═╡ 2967add5-2c78-4b39-a055-174eac6daa3e
a3d, col_names = StanIO.read_csvfiles(csvfiles, :array; return_parameters=true);

# ╔═╡ 3839fdc5-e7f2-4cb6-8a48-70c670b42fbb
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

# ╔═╡ 91ed7ff7-249c-4627-b8e7-d8eb2307ceb8
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

# ╔═╡ c342b21d-0ea3-4852-b22d-d79c228d71a1
x_df = select_nested_column(df, :x)

# ╔═╡ e192e46f-f650-4dd7-9811-e8255013d292
bar3_df = select_nested_column(df, "bar3")

# ╔═╡ 0d6684e4-b4fb-4418-8631-5a07dd60a612
bar_df = select_nested_column(df, "bar")

# ╔═╡ ed833949-9eb3-496c-b822-9d84a365954b
@enum VariableType SCALAR=1 COMPLEX TUPLE ARRAY

# ╔═╡ ee603721-5c9c-4c77-a25b-aebdcff14d6d
ARRAY

# ╔═╡ f2d3031e-50ca-4b33-b7a4-b0f09f6f7919
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

# ╔═╡ 10849cc4-6069-4670-b2f7-5e39f2ac24a7
function columns(v::Variable)
	return v.start_idx:v.end_idx-1
end

# ╔═╡ dacb6aca-d69f-4749-b13b-138073d848cc
function num_elts(v::Variable)
	return prod(v.dimensions)
end

# ╔═╡ b9eeba90-4c43-48a9-bf55-fa4c6e6702f8
function elt_size(v::Variable)
	return v.end_idx - v.start_idx
end

# ╔═╡ 002780ce-41f1-4a6b-ab5a-3215093aa5c0
function _munge_first_tuple(fld::AbstractString)
	return "dummy_" * String(split(fld, ":"; limit=2)[2])
end

# ╔═╡ 35fda755-069a-4236-b970-af6fe510ea16
function _get_base_name(fld::AbstractString)
	return String(split(fld, [':', '.'])[1])
end

# ╔═╡ f6c17840-e46a-488f-a5ba-028daf19346a
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
	

# ╔═╡ 6d7c6a69-013e-4f71-a038-45ada998fd60
function parse_header(header::Vector{String})
	d = Dict{String, Variable}()
	for param in _from_header(header)
		d[param.name] = param
	end
	d
end

# ╔═╡ cfe75faf-ba69-49e3-b58d-1ddf5f4b81fe
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

# ╔═╡ 871f3e43-3fd1-4e54-bc84-b054a2c7f5b3
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

# ╔═╡ b1467c24-8109-4a7c-a5e2-0749b8107918
function extract_helper(v::Variable, df::DataFrame, offset=0)
	return _extract_helper(v, df)
end

# ╔═╡ d75d1fc7-620a-40bd-9171-ffcef06ce1aa
function stan_variables(dct::Dict{String, Variable}, df::DataFrame)
	res = DataFrame()
	for key in keys(dct)
		res[!, dct[key].name] = extract_helper(dct[key], df)
	end
	res
end

# ╔═╡ 52084c1a-6db8-4c06-994e-0e0a9371c169
dct = parse_header(names(df))

# ╔═╡ 5cca3538-97f4-47d0-afa1-0bd95bf7f08e
ndf = stan_variables(dct, df)

# ╔═╡ 840b7534-79c6-457f-b541-0a5eb4b5f07b
convert(NamedTuple, ndf)

# ╔═╡ Cell order:
# ╟─e953be75-6f32-4a33-bded-a809ff38e5cd
# ╟─789c3f0b-8179-4126-baf5-fdd47b1938f5
# ╠═c08d0f35-92fb-4e10-81a6-5a68eea4d046
# ╠═90dd4d50-2f82-4df6-94b1-a9a72bc44e59
# ╠═3d7c5e2c-8eba-11ee-02c7-5382f0852ca2
# ╠═a1328860-a754-4eb8-9855-e18d9ab50c0c
# ╠═ecf1f379-7774-4a41-928e-be10be1786b4
# ╟─ca0a71bb-7ac1-4c01-9a0a-24f1ce1479bd
# ╠═4e2984b1-435d-4cac-80ef-316060aa93af
# ╠═78d5367b-542a-41b6-85da-fc616046dba4
# ╠═2967add5-2c78-4b39-a055-174eac6daa3e
# ╠═3839fdc5-e7f2-4cb6-8a48-70c670b42fbb
# ╠═91ed7ff7-249c-4627-b8e7-d8eb2307ceb8
# ╠═c342b21d-0ea3-4852-b22d-d79c228d71a1
# ╠═e192e46f-f650-4dd7-9811-e8255013d292
# ╠═0d6684e4-b4fb-4418-8631-5a07dd60a612
# ╠═ed833949-9eb3-496c-b822-9d84a365954b
# ╠═ee603721-5c9c-4c77-a25b-aebdcff14d6d
# ╠═f2d3031e-50ca-4b33-b7a4-b0f09f6f7919
# ╠═10849cc4-6069-4670-b2f7-5e39f2ac24a7
# ╠═dacb6aca-d69f-4749-b13b-138073d848cc
# ╠═b9eeba90-4c43-48a9-bf55-fa4c6e6702f8
# ╠═002780ce-41f1-4a6b-ab5a-3215093aa5c0
# ╠═35fda755-069a-4236-b970-af6fe510ea16
# ╠═f6c17840-e46a-488f-a5ba-028daf19346a
# ╠═6d7c6a69-013e-4f71-a038-45ada998fd60
# ╠═cfe75faf-ba69-49e3-b58d-1ddf5f4b81fe
# ╠═871f3e43-3fd1-4e54-bc84-b054a2c7f5b3
# ╠═b1467c24-8109-4a7c-a5e2-0749b8107918
# ╠═d75d1fc7-620a-40bd-9171-ffcef06ce1aa
# ╠═52084c1a-6db8-4c06-994e-0e0a9371c169
# ╠═5cca3538-97f4-47d0-afa1-0bd95bf7f08e
# ╠═840b7534-79c6-457f-b541-0a5eb4b5f07b
