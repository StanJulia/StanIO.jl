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
	ndf = df[:, 8:end]
 end

# ╔═╡ c8290cf6-03ef-4c51-bf0e-2db5977f42d8
stan_def = "array[3,2] tuple(real, real) arr_2d_pair = {{(1, 3), (4, 5)}, {(6, 7), (8, 9)}, {(20, 21), (22, 23)}};"

# ╔═╡ a541f226-f6f0-4daa-8258-442a56e7bc94
x_def = ["r", "x.1.1:1", "x.1.1:2", "x.2.1:1", "x.2.1:2", "x.3.1:1", "x.3.1:2", "x.1.2:1", "x.1.2:2", "x.2.2:1", "x.2.2:2", "x.3.2:1", "x.3.2:2", "y"];

# ╔═╡ e445918b-e57f-4ac4-9576-f3edbdbcba0a
x_val = [1, 3, 6, 7, 20, 21, 4, 5, 8, 9, 22, 23];

# ╔═╡ e5e81f0f-858e-4479-ab61-7c1a4ee62c7e
function find_nested_columns(x_def)
    nested_columns = String[]
    for (i, s) in enumerate(x_def)
        r = split(s, ['.', ':'])
        if length(r) > 1
            append!(nested_columns, [r[1]])
        end
    end
    unique(nested_columns)
end

# ╔═╡ b5ee6486-f042-485e-bc61-f30d39575a79
function select_nested_column(x_def, var::Union{Symbol, String})
    sym = string(var)
    sel = String[]
    for (i, s) in enumerate(x_def)
        if length(s) > length(sym) && sym == x_def[i][1:length(sym)] && x_def[i][length(sym)+1] in ['.']
            append!(sel, [x_def[i]])
        end
    end
    length(sel) == 0 && @warn "$syms not in $x_def"
    sel
end

# ╔═╡ 5a45fe14-d32f-48eb-ab1d-8a82dcb334bc
nested_columns = find_nested_columns(x_def)

# ╔═╡ aa5051d6-506a-41c7-9cf3-610a0815f3fe
xdef = select_nested_column(x_def, nested_columns[1]) 

# ╔═╡ 952bff76-8ca3-43da-abc1-1afa90b424eb
function handle_nested_column(x_def, x_val)
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
nf = handle_nested_column(xdef, x_val)

# ╔═╡ 9690333f-757f-409c-b965-030a4969a130
x_val

# ╔═╡ 70390e88-2373-4356-a5e4-9dee1ecffd8b
x_def

# ╔═╡ 81468a03-83eb-4438-8591-22b256670f46
md" {{(1, 3), (4, 5)}, {(6, 7), (8, 9)}, {(20, 21), (22, 23)}}"

# ╔═╡ 03ec4af3-6e5c-427a-92f1-6e4220431b04
begin
	a = Vector{NTuple{2}}()
	for i in 1:2:length(x_val)
		append!(a, [(x_val[i], x_val[i+1])])
	end
	a
end

# ╔═╡ 37afd7b7-de12-4e06-9159-5f92af6ee4f7
reshape(a, 3, 2)

# ╔═╡ 80342dd8-3dd8-4ede-9312-99641b43957a
function handle_arrays_and_tuples(flds, x_def, x_val, da=Int[])
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
		return (nf, te, daf)
	elseif nf[end][2] == :tuple
		if length(daf) > 0
			te = reshape(te, daf...)
			daf = Int[]
		end
		te = Vector{NTuple{2}}()
		for i in 1:2:length(x_val)
			append!(te, [(x_val[i], x_val[i+1])])
		end
		nf = nf[1:end-1]
		println((nf, te, daf))
		handle_arrays_and_tuples(nf, x_def, te, daf)
	elseif nf[end][2] == :array
		daf = vcat(nf[end][3], daf)
		nf = nf[1:end-1]
		println((nf, te, daf))
		handle_arrays_and_tuples(nf, x_def, te, daf)
	end
end

# ╔═╡ bc8190f2-1240-4050-be6a-bd4d5ed1d4f5
begin
	_, te, _ = handle_arrays_and_tuples(nf, x_def, x_val)
	te
end

# ╔═╡ 1b27d9c3-19a1-4479-935a-532a51455cc6
reshape(te, [3, 2]...)

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
# ╠═c8290cf6-03ef-4c51-bf0e-2db5977f42d8
# ╠═a541f226-f6f0-4daa-8258-442a56e7bc94
# ╠═e445918b-e57f-4ac4-9576-f3edbdbcba0a
# ╠═e5e81f0f-858e-4479-ab61-7c1a4ee62c7e
# ╠═b5ee6486-f042-485e-bc61-f30d39575a79
# ╠═5a45fe14-d32f-48eb-ab1d-8a82dcb334bc
# ╠═aa5051d6-506a-41c7-9cf3-610a0815f3fe
# ╠═952bff76-8ca3-43da-abc1-1afa90b424eb
# ╠═a5f16633-c98d-463c-a54c-d124ef4f6c07
# ╠═9690333f-757f-409c-b965-030a4969a130
# ╠═70390e88-2373-4356-a5e4-9dee1ecffd8b
# ╠═81468a03-83eb-4438-8591-22b256670f46
# ╠═03ec4af3-6e5c-427a-92f1-6e4220431b04
# ╠═37afd7b7-de12-4e06-9159-5f92af6ee4f7
# ╠═80342dd8-3dd8-4ede-9312-99641b43957a
# ╠═bc8190f2-1240-4050-be6a-bd4d5ed1d4f5
# ╠═1b27d9c3-19a1-4479-935a-532a51455cc6
