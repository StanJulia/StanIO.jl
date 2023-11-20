### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 4530e47d-abe2-4521-ba6f-1e2e4a46cf3a
using Pkg

# ╔═╡ e89264f6-3e70-474d-82aa-5956b8e824d4
Pkg.activate("/Users/rob/.julia/dev/StanIO")

# ╔═╡ 891015c3-8539-45e1-9a9a-71acfed9cfdf
begin
	using StanIO
	using DataFrames
	using JSON
	using Test
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

# ╔═╡ 6a288a48-5b2c-417b-917e-c0e84ffc7563
begin
	csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "rectangles")))
	csvfiles = joinpath.(joinpath(stanio_data, "rectangles"), csvfiles)
end

# ╔═╡ 01c5e25c-5a51-4082-8646-7793152dde33
df = StanIO.read_csvfiles(csvfiles, :dataframe);

# ╔═╡ 21eec5d3-ac5f-4522-8fb4-319d938234e5
df

# ╔═╡ b50cf06b-9751-4ce7-9696-42b8051e6102
df2, df_col_names = StanIO.read_csvfiles(csvfiles, :dataframe; return_parameters=true);

# ╔═╡ e759b33d-d236-45e9-ba0c-33b85edc2545
df_col_names

# ╔═╡ c1a23279-a0c4-47bc-a3fa-ed8a266ba5da
a3d, array_col_names = StanIO.read_csvfiles(csvfiles, :array; return_parameters=true);

# ╔═╡ b70b239a-c82c-4ba2-92dc-9b91a725ab9f
size(a3d)

# ╔═╡ 91713a39-49ac-44fc-af4b-9c305fc29978
array_col_names

# ╔═╡ 5f5e778f-db6e-4887-a0b2-b0159da7397f
nts, nts_col_names = StanIO.read_csvfiles(csvfiles, :namedtuples; return_parameters=true);

# ╔═╡ 7fc5bd2e-0e1d-4d96-8d43-4d63300a095b
keys(nts)

# ╔═╡ Cell order:
# ╠═86e386a0-b56f-42f1-a6de-1f15425d1a59
# ╠═c706075a-0174-450d-a1b0-b202cee4d216
# ╠═4530e47d-abe2-4521-ba6f-1e2e4a46cf3a
# ╠═e89264f6-3e70-474d-82aa-5956b8e824d4
# ╠═891015c3-8539-45e1-9a9a-71acfed9cfdf
# ╠═6a288a48-5b2c-417b-917e-c0e84ffc7563
# ╠═01c5e25c-5a51-4082-8646-7793152dde33
# ╠═21eec5d3-ac5f-4522-8fb4-319d938234e5
# ╠═b50cf06b-9751-4ce7-9696-42b8051e6102
# ╠═e759b33d-d236-45e9-ba0c-33b85edc2545
# ╠═c1a23279-a0c4-47bc-a3fa-ed8a266ba5da
# ╠═b70b239a-c82c-4ba2-92dc-9b91a725ab9f
# ╠═91713a39-49ac-44fc-af4b-9c305fc29978
# ╠═5f5e778f-db6e-4887-a0b2-b0159da7397f
# ╠═7fc5bd2e-0e1d-4d96-8d43-4d63300a095b
