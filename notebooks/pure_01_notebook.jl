### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ 3d7c5e2c-8eba-11ee-02c7-5382f0852ca2
using Pkg

# ╔═╡ a1328860-a754-4eb8-9855-e18d9ab50c0c
Pkg.activate(expanduser("~/.julia/dev/StanIO"))

# ╔═╡ ecf1f379-7774-4a41-928e-be10be1786b4
begin
	import StanIO: stanio_data, read_csvfiles, find_nested_columns, select_nested_column
	using DataFrames
	using OrderedCollections
end

# ╔═╡ e953be75-6f32-4a33-bded-a809ff38e5cd
md" ### Notebook version of translation of [`stanio/reshape.yp`](https://github.com/WardBrian/stanio) by Brian Ward."

# ╔═╡ d3fb7f48-bbec-48f8-bebc-a53a89e27716
md" ###### For testing purposes, this notebook 'duplicates' the methods available in StanIO."

# ╔═╡ 789c3f0b-8179-4126-baf5-fdd47b1938f5
md" ##### Widen the cells."

# ╔═╡ c08d0f35-92fb-4e10-81a6-5a68eea4d046
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 20%);
	}
</style>
"""

# ╔═╡ bdf6a4a7-358a-4004-ad24-0397441b203a
md" ###### Comment out below cell to use the packages from the Julia repository."

# ╔═╡ ca0a71bb-7ac1-4c01-9a0a-24f1ce1479bd
md" #### Setup dataframes for testing."

# ╔═╡ 4e2984b1-435d-4cac-80ef-316060aa93af
begin
	csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "pure_01")))
	csvfiles = joinpath.(joinpath(stanio_data, "pure_01"), csvfiles)
end

# ╔═╡ 78d5367b-542a-41b6-85da-fc616046dba4
begin
 	df = read_csvfiles(csvfiles, :dataframe)
	#df = df[:, 8:end]
 end

# ╔═╡ 2967add5-2c78-4b39-a055-174eac6daa3e
a3d, col_names = read_csvfiles(csvfiles, :array; return_parameters=true);

# ╔═╡ c3975028-9fef-415a-ac57-9256e8b65637
find_nested_columns(df)

# ╔═╡ 533dbca3-980c-41de-83e9-fbbab3728738
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
				if length(dims) > 0
					munged_header = munged_header[1:(Int(length(munged_header)/prod(dims)))]
				end
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
	d = OrderedDict{String, Variable}()
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
function extract_helper(v::Variable, df::DataFrame, offset=0; object=true)
	out = _extract_helper(v, df)
	if v.type == TUPLE
		if v.type == TUPLE
			atr = []
			elts = [p -> p.dimensions == () ? (1,) : p.dimensions for p in v.contents]
			for j in 1:length(out)
				at = Tuple[]
				for i in 1:length(elts):length(out[j])
					append!(at, [(out[j][i], out[j][i+1],)])
				end
				if length(v.dimensions) > 0
					append!(atr, [reshape(at, v.dimensions...)])
				else
					append!(atr, at)
				end
			end
			return convert.(typeof(atr[1]), atr)
		end
	else
		return out
	end
end

# ╔═╡ d75d1fc7-620a-40bd-9171-ffcef06ce1aa
function stan_variables(dct::OrderedDict{String, Variable}, df::DataFrame)
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
# ╟─d3fb7f48-bbec-48f8-bebc-a53a89e27716
# ╟─789c3f0b-8179-4126-baf5-fdd47b1938f5
# ╠═c08d0f35-92fb-4e10-81a6-5a68eea4d046
# ╠═3d7c5e2c-8eba-11ee-02c7-5382f0852ca2
# ╟─bdf6a4a7-358a-4004-ad24-0397441b203a
# ╠═a1328860-a754-4eb8-9855-e18d9ab50c0c
# ╠═ecf1f379-7774-4a41-928e-be10be1786b4
# ╟─ca0a71bb-7ac1-4c01-9a0a-24f1ce1479bd
# ╠═4e2984b1-435d-4cac-80ef-316060aa93af
# ╠═78d5367b-542a-41b6-85da-fc616046dba4
# ╠═2967add5-2c78-4b39-a055-174eac6daa3e
# ╠═c3975028-9fef-415a-ac57-9256e8b65637
# ╠═533dbca3-980c-41de-83e9-fbbab3728738
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
