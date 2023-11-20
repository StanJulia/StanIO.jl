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

# ╔═╡ 9c399d89-4768-4938-a757-425535c04ef8
df1 = StanIO.read_csvfiles(csvfiles, :dataframe)

# ╔═╡ b586b97f-bca4-439b-ac6f-5e39aa40a932
names(df1)[40:50]

# ╔═╡ 1a5079f0-01e7-4a73-a030-c2c22d874e19
df2 = StanIO.read_csvfiles(csvfiles, :nesteddataframe)

# ╔═╡ 47382829-cc92-40cb-91a5-b9017d545e7d
df3 = StanIO.read_csvfiles(csvfiles, :dataframes)

# ╔═╡ Cell order:
# ╠═86e386a0-b56f-42f1-a6de-1f15425d1a59
# ╠═c706075a-0174-450d-a1b0-b202cee4d216
# ╠═4530e47d-abe2-4521-ba6f-1e2e4a46cf3a
# ╠═e89264f6-3e70-474d-82aa-5956b8e824d4
# ╠═891015c3-8539-45e1-9a9a-71acfed9cfdf
# ╠═6a288a48-5b2c-417b-917e-c0e84ffc7563
# ╠═9c399d89-4768-4938-a757-425535c04ef8
# ╠═b586b97f-bca4-439b-ac6f-5e39aa40a932
# ╠═1a5079f0-01e7-4a73-a030-c2c22d874e19
# ╠═47382829-cc92-40cb-91a5-b9017d545e7d
