### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 4530e47d-abe2-4521-ba6f-1e2e4a46cf3a
using Pkg

# ╔═╡ 71527404-bb92-4023-b177-8e4cc3cef7f8
Pkg.activate("/Users/rob/.julia/dev/StanIO")

# ╔═╡ 891015c3-8539-45e1-9a9a-71acfed9cfdf
begin
	using StanIO
	using DataFrames
	using JSON
	using NamedTupleTools
end

# ╔═╡ 86e386a0-b56f-42f1-a6de-1f15425d1a59
md" ##### Widen the cells."

# ╔═╡ c706075a-0174-450d-a1b0-b202cee4d216
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

# ╔═╡ 79dca9f3-c2d8-430c-b0d5-658638dcf901
stan = "
parameters {
    real r;
    matrix[2, 3] x;
    tuple(real, real) bar;
    tuple(real, tuple(real, real), real) bar2;
    tuple(real, tuple(real, tuple(real, real)), real) bar3;
}
model {
    r ~ std_normal();

    for (i in 1:2) {
        x[i,:] ~ std_normal();
    }

    bar.1 ~ std_normal();
    bar.2 ~ std_normal();
    bar2.1 ~ std_normal();
    bar2.2.1 ~ std_normal();
    bar2.2.2 ~ std_normal();
	bar2.3 ~ std_normal();
    bar3.1 ~ std_normal();
    bar3.2.1 ~ std_normal();
    bar3.2.2.1 ~ std_normal();
    bar3.2.2.2 ~ std_normal();
	bar3.3 ~ std_normal();
}
";

# ╔═╡ 4920dd3b-703d-458c-b63f-27bd8b70ae79
begin
	csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "tuples")))
	csvfiles = joinpath.(joinpath(stanio_data, "tuples"), csvfiles)
end

# ╔═╡ 8ca11b28-e702-4328-8fb9-17909f2aadcc
a3d, col_names = StanIO.read_csvfiles(csvfiles, :array; return_parameters=true);

# ╔═╡ 727aa981-0ae2-4ca4-8c6c-e85f236ac28f
 begin
 	df = StanIO.read_csvfiles(csvfiles, :dataframe)
	df = df[:, 8:end]
 end

# ╔═╡ 59cab475-ddff-4dea-9762-7b97c437770f
 begin
 	ndf = StanIO.read_csvfiles(csvfiles, :nesteddataframe)
	ndf = ndf[:, 9:end]
 end

# ╔═╡ 57a43a87-4cfd-49a4-8e4f-44170ce0ec3c
names(ndf)

# ╔═╡ 3f116117-d056-48b3-a9ee-93ca44cb45b6
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

# ╔═╡ b2c6d4a7-7cf8-4661-8283-a2fc2f331df3
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

# ╔═╡ 6e58174a-4fa2-4f0c-b90e-11f759a3935b
function is_arrays_only(df)
	fns = names(df)
	l = [findall(c -> c in [':', '.'], fn) for fn in fns]
	la = [findall(c -> c in ['.'], fn) for fn in fns]
	return l == la
end

# ╔═╡ 7de37725-bf40-4ba9-9385-e345a242e36e
function is_tuples_only(df)
	fns = names(df)
	l = [findall(c -> c in [':', '.'], fn) for fn in fns]
	lt = [findall(c -> c in [':'], fn) for fn in fns]
	return l == lt
end

# ╔═╡ 51cc906b-f961-408b-b38c-44cf42f86622
function get_splits(fns)
	splits = Int[]
	for i in 1:length(fns)
		splts = findall(c -> c in ['.', ':'], fns[i])
		for j in 1:length(splts)
			push!(splits, splts[j])
		end
	end
	splits = unique(splits)
	return splits
end

# ╔═╡ 7bc13f29-7a80-4656-aae5-649c8188fa54
function handle_nested_column(df)
	fns = names(df)
	#println(fns)
	splits = get_splits(fns)
	#println(splits)
	nf = Vector{Tuple{Int, Symbol, Any}}()
	t = fns[1][splits[1]] == '.' ? :array : :tuple
	if t == :array && is_arrays_only(df)
		im = [Meta.parse.(split(fns[i], ['.', ':'])[2:end]) for i in 1:length(fns)]
		#println(im)
		for (i, s) in enumerate(splits)
			append!(nf, [(s, t, im[end][i])])
		end
	elseif is_tuples_only(df)
		#println("Handle tuple")
		cur_len = 0
		next_len = nothing
		for i in 1:length(fns)
			im = Meta.parse.(split(fns[i], ['.', ':'])[2:end])
			if i < length(fns)
				im_next = Meta.parse.(split(fns[i+1], ['.', ':'])[2:end])
			elseif i == length(fns)
				im_next = 0
			else
				im_next = nothing
			end
			next_len = isnothing(im_next) ? nothing : length(im_next)
			cur_len = length(im)
			fsplit = findall(c -> c in ['.', ':'], fns[i])
			println((im=im, im_next=im_next, cur_len=cur_len, next_len=next_len, fsplit=fsplit))
			if !isnothing(next_len) && (cur_len !== next_len || !(i == 1))
				new_entry = (fsplit[cur_len], :tuple, im[end])
				#println(new_entry)
				append!(nf, [new_entry])
				nf = unique(nf)
			end
		end
	elseif !is_arrays_only(df) || is_tuples_only(df)
		@warn "Mixed arrays and tuples not supported!"
		return nothing
	end
	println(nf)
	nf
end

# ╔═╡ 87d8e7eb-4419-40bc-9103-4b072e5947a7
x_df = select_nested_column(df, :x)

# ╔═╡ ae985ce1-45f5-4f8e-be22-91137c701e06
handle_nested_column(x_df)

# ╔═╡ ec3495cf-053e-4757-8b56-eda4a9ff15a7
bar_df = select_nested_column(df, :bar)

# ╔═╡ 5c8c2b43-1494-4e98-9093-fb3d91d4a837
handle_nested_column(bar_df)

# ╔═╡ 80342dd8-3dd8-4ede-9312-99641b43957a
function handle_arrays_and_tuples(flds, x_def=names(x_df); 
		x_val=Array(x_df[1, :]), da=Int[], df=DataFrame(), debug=true)
	println(x_def)
	te = copy(x_val)
	nf = copy(flds)
	println(nf)
	daf = copy(da)
	if debug 
		append!(df, DataFrame(Step="Enter:", nf=[nf], te=[te], da=[daf]))
	end
	#println(df)
	if length(nf) == 0
		debug && append!(df, DataFrame(Step="Final in:", nf=[nf], te=[te], da=[daf]))
		if length(daf) > 0
			te = reshape(te, daf...)
			daf = Int[]
		end
		debug && append!(df, DataFrame(Step="Final out:", nf=[nf], te=[te], da=[daf]); promote=true)
		if debug
			return (te, df)
		else
			return te
		end
	elseif nf[end][2] == :tuple
		println((nf, te, daf, x_def))
		if length(daf) > 0
			te = reshape(te, daf...)
			daf = Int[]
		end
		println((nf, te, daf, x_def))
		debug && append!(df, DataFrame(Step="Tuple in:", nf=[nf], te=[te], da=[daf]); promote=true)
		te = Vector{NTuple{2}}()
		for i in 1:2:length(x_val)
			append!(te, [(x_val[i], x_val[i+1])])
		end
		nf = nf[1:end-1]
		#println((nf, te, daf))
		debug && append!(df, DataFrame(Step="Tuple out:", nf=[nf], te=te, da=[daf]); promote=true)
		handle_arrays_and_tuples(nf, x_def; x_val=te, df=df, da=daf, debug)
	elseif nf[end][2] == :array
		println((nf, te, daf))
		debug && append!(df, DataFrame(Step="Array in:", nf=[nf], te=[te], da=[daf]); promote=true)
		daf = vcat(nf[end][3], daf)
		nf = nf[1:end-1]
		println((nf, te, daf))
		debug && append!(df, DataFrame(Step="Array out:", nf=[nf], te=[te], da=[daf]); promote=true)
		handle_arrays_and_tuples(nf, x_def; x_val=te, df=df, da=daf, debug)
	end
end

# ╔═╡ 5ee5859e-a556-4ae0-9623-7591b8e87888
function nested_flds(df, col; debug=true)
	df = select_nested_column(df, Symbol(col))
	nf = handle_nested_column(df)
	if isnothing(nf)
		return nothing
	end
	x_val = Array(df[1, :])
	res = handle_arrays_and_tuples(nf, names(df); x_val=Array(df[1, :]), debug)
	return (res)
end

# ╔═╡ 111475ac-ec83-47de-b49c-37543b96fada
begin
	debug = true
	res = nested_flds(df, "x"; debug)
	if debug
		x_res, x_steps_df = res
	else
		x_res = res
	end
	x_res
end

# ╔═╡ fa44ee61-0908-4b86-807f-c8045519c88c
x_steps_df

# ╔═╡ 945988ff-5b49-45b3-9c30-8263e7b0fc77
begin
	bar_res, bar_debug = nested_flds(df, "bar")
	bar_res
end

# ╔═╡ 29772409-a85e-4971-a684-5ce9659c4cd7
bar_debug

# ╔═╡ aa50c548-6f20-4156-a275-7ab1f2d7cfbc
begin
	bar2_res, bar2_debug = nested_flds(df, :bar2)
end

# ╔═╡ 73a6b430-f7e7-4dd0-8269-d43f89c4bc52
bar2_df = select_nested_column(df, :bar2)

# ╔═╡ 2ff4d6f4-2b61-4e42-b380-7db59c7ce4ec
handle_nested_column(bar2_df)

# ╔═╡ e93dc8ac-58ea-4d68-ad9d-f7a375ce6ec6
nested_flds(df, :bar3)

# ╔═╡ 4202bf16-c4c7-489a-81b5-298317011ece
bar3_df = select_nested_column(df, :bar3)

# ╔═╡ 7d33daee-2c6d-4468-a013-232ff7170a53
handle_nested_column(bar3_df)

# ╔═╡ d64b4a72-08c8-4f8f-8358-4ff10f59707c
names(bar3_df)

# ╔═╡ Cell order:
# ╠═86e386a0-b56f-42f1-a6de-1f15425d1a59
# ╠═c706075a-0174-450d-a1b0-b202cee4d216
# ╠═4530e47d-abe2-4521-ba6f-1e2e4a46cf3a
# ╠═71527404-bb92-4023-b177-8e4cc3cef7f8
# ╠═891015c3-8539-45e1-9a9a-71acfed9cfdf
# ╠═79dca9f3-c2d8-430c-b0d5-658638dcf901
# ╠═4920dd3b-703d-458c-b63f-27bd8b70ae79
# ╠═8ca11b28-e702-4328-8fb9-17909f2aadcc
# ╠═727aa981-0ae2-4ca4-8c6c-e85f236ac28f
# ╠═59cab475-ddff-4dea-9762-7b97c437770f
# ╠═57a43a87-4cfd-49a4-8e4f-44170ce0ec3c
# ╠═3f116117-d056-48b3-a9ee-93ca44cb45b6
# ╠═b2c6d4a7-7cf8-4661-8283-a2fc2f331df3
# ╠═6e58174a-4fa2-4f0c-b90e-11f759a3935b
# ╠═7de37725-bf40-4ba9-9385-e345a242e36e
# ╠═51cc906b-f961-408b-b38c-44cf42f86622
# ╠═7bc13f29-7a80-4656-aae5-649c8188fa54
# ╠═ae985ce1-45f5-4f8e-be22-91137c701e06
# ╠═5c8c2b43-1494-4e98-9093-fb3d91d4a837
# ╠═2ff4d6f4-2b61-4e42-b380-7db59c7ce4ec
# ╠═7d33daee-2c6d-4468-a013-232ff7170a53
# ╠═d64b4a72-08c8-4f8f-8358-4ff10f59707c
# ╠═5ee5859e-a556-4ae0-9623-7591b8e87888
# ╠═111475ac-ec83-47de-b49c-37543b96fada
# ╠═fa44ee61-0908-4b86-807f-c8045519c88c
# ╠═87d8e7eb-4419-40bc-9103-4b072e5947a7
# ╠═945988ff-5b49-45b3-9c30-8263e7b0fc77
# ╠═29772409-a85e-4971-a684-5ce9659c4cd7
# ╠═ec3495cf-053e-4757-8b56-eda4a9ff15a7
# ╠═80342dd8-3dd8-4ede-9312-99641b43957a
# ╠═aa50c548-6f20-4156-a275-7ab1f2d7cfbc
# ╠═73a6b430-f7e7-4dd0-8269-d43f89c4bc52
# ╠═e93dc8ac-58ea-4d68-ad9d-f7a375ce6ec6
# ╠═4202bf16-c4c7-489a-81b5-298317011ece
