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
	ndf = ndf[:, 7:end]
 end

# ╔═╡ 57a43a87-4cfd-49a4-8e4f-44170ce0ec3c
names(ndf)

# ╔═╡ b67a35ce-0379-4280-9e00-4a23300db7e7
StanIO.find_nested_columns(df)

# ╔═╡ b2c6d4a7-7cf8-4661-8283-a2fc2f331df3
function select_nested_column(df::DataFrame, var::Union{Symbol, String})
    n = string.(names(df))
    sym = string(var)
    sel = String[]
    for (i, s) in enumerate(n)
		splits = findall(c -> c in ['.', ':'], s)
		if length(splits) > 0
			println((splits, sym, s, length(s), s[1:splits[1]-1]))
	        if length(splits) > 0 && sym == s[1:splits[1]-1]
	            append!(sel, [n[i]])
	        end
		end
    end
    length(sel) == 0 && @warn "$sym not in $n"
    #println(sel)
    df[:, sel]
end

# ╔═╡ 87d8e7eb-4419-40bc-9103-4b072e5947a7
x_df = select_nested_column(df, :x)

# ╔═╡ ec3495cf-053e-4757-8b56-eda4a9ff15a7
b_df = select_nested_column(df, :bar)

# ╔═╡ c6130f37-0482-4f7a-8b29-65e2a6c4e2e8
function handle_nested_column(df)
	x_def = names(df)
	index_matrix = Meta.parse.(split(x_def[end], ['.', ':'])[2:end])
	splits = findall(c -> c in ['.', ':'], x_def[1])
	nf = Vector{Tuple{Int, Symbol, Int}}()
	for (i, s) in enumerate(splits)
		t = x_def[1][s] == '.' ? :array : :tuple
		append!(nf, [(s, t, index_matrix[i])])
	end
	nf
end

# ╔═╡ a5f16633-c98d-463c-a54c-d124ef4f6c07
nf_x = handle_nested_column(x_df)

# ╔═╡ 9690333f-757f-409c-b965-030a4969a130
x_val = Array(x_df[1, :])

# ╔═╡ 80342dd8-3dd8-4ede-9312-99641b43957a
function handle_arrays_and_tuples(flds, x_def=names(x_df); x_val=Array(x_df[1, :]), da=Int[])
	te = copy(x_val)
	nf = copy(flds)
	daf = copy(da)
	if length(nf) == 0
		println(("End:", nf, te, daf))
		if length(daf) > 0
			te = reshape(te, daf...)
			daf = Int[]
		end
		println(("End:", nf, te, daf))
		return te
	elseif nf[end][2] == :tuple
		if length(daf) > 0
			te = reshape(te, daf...)
			daf = Int[]
		end
		println((nf, te, daf, x_def))
		te = Vector{NTuple{2}}()
		for i in 1:2:length(x_val)
			append!(te, [(x_val[i], x_val[i+1])])
		end
		nf = nf[1:end-1]
		println((nf, te, daf))
		handle_arrays_and_tuples(nf, x_def; x_val=te, da=daf)
	elseif nf[end][2] == :array
		daf = vcat(nf[end][3], daf)
		nf = nf[1:end-1]
		println((nf, te, daf))
		handle_arrays_and_tuples(nf, x_def; x_val=te, da=daf)
	end
end

# ╔═╡ 431d8ed1-c8db-469f-8f4c-9c26f4310925
nf_x

# ╔═╡ bc8190f2-1240-4050-be6a-bd4d5ed1d4f5
x_res = handle_arrays_and_tuples(nf_x, names(x_df); x_val=Array(x_df[1, :]))

# ╔═╡ 044455ae-1021-450a-9db0-49372512fef2
bar_df = select_nested_column(df, :bar)

# ╔═╡ a23ae743-2174-414a-b543-0d1fd61da2ca
nf_bar = handle_nested_column(bar_df)

# ╔═╡ 65816360-0814-4330-8df6-98bb10fb8fdc
bar_res = handle_arrays_and_tuples(nf_bar, names(bar_df); x_val=Array(bar_df[1, :]))

# ╔═╡ aa50c548-6f20-4156-a275-7ab1f2d7cfbc
bar2_df = select_nested_column(df, :bar2)

# ╔═╡ ac159e77-2be5-4acb-b51c-e6ae87de4ea8
nf_bar2 = handle_nested_column(bar2_df)

# ╔═╡ 9d66e8dc-f7a9-4f65-acdb-d9ef3bdad906
bar2_res = handle_arrays_and_tuples(nf_bar2, names(bar2_df); x_val=Array(bar2_df[1, :]))

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
# ╠═b67a35ce-0379-4280-9e00-4a23300db7e7
# ╠═87d8e7eb-4419-40bc-9103-4b072e5947a7
# ╠═ec3495cf-053e-4757-8b56-eda4a9ff15a7
# ╠═b2c6d4a7-7cf8-4661-8283-a2fc2f331df3
# ╠═c6130f37-0482-4f7a-8b29-65e2a6c4e2e8
# ╠═a5f16633-c98d-463c-a54c-d124ef4f6c07
# ╠═9690333f-757f-409c-b965-030a4969a130
# ╠═80342dd8-3dd8-4ede-9312-99641b43957a
# ╠═431d8ed1-c8db-469f-8f4c-9c26f4310925
# ╠═bc8190f2-1240-4050-be6a-bd4d5ed1d4f5
# ╠═044455ae-1021-450a-9db0-49372512fef2
# ╠═a23ae743-2174-414a-b543-0d1fd61da2ca
# ╠═65816360-0814-4330-8df6-98bb10fb8fdc
# ╠═aa50c548-6f20-4156-a275-7ab1f2d7cfbc
# ╠═ac159e77-2be5-4acb-b51c-e6ae87de4ea8
# ╠═9d66e8dc-f7a9-4f65-acdb-d9ef3bdad906
