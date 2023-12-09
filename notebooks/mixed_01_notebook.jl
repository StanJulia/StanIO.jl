### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ 3d7c5e2c-8eba-11ee-02c7-5382f0852ca2
using Pkg

# ╔═╡ a1328860-a754-4eb8-9855-e18d9ab50c0c
Pkg.activate(expanduser("~/.julia/dev/StanIO"))

# ╔═╡ ecf1f379-7774-4a41-928e-be10be1786b4
using StanIO

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

# ╔═╡ bdf6a4a7-358a-4004-ad24-0397441b203a
md" ###### Comment out below cell to use the packages from the Julia repository."

# ╔═╡ ca0a71bb-7ac1-4c01-9a0a-24f1ce1479bd
md" #### Setup dataframes for testing."

# ╔═╡ 223159f3-c270-48f8-b5a4-c3e308d56970
md" ###### Stan Language program used to generate the mixed_01 data."

# ╔═╡ f5c0ae08-f47b-42f8-9039-1a4ac72cf892
stan = "
generated quantities {
    real base = normal_rng(0, 1);
    array[3,2] tuple(real, array[2] real) a = 
        {
            {(base * 12, {base * 13, base}), (base * 14, {base * 15, base})},
            {(base * 16, {base * 17, base}), (base * 18, {base * 19, base})},
            {(base * 20, {base * 21, base}), (base * 22, {base * 23, base})}
        };
}
";

# ╔═╡ 4e2984b1-435d-4cac-80ef-316060aa93af
begin
	csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "mixed_01")))
	csvfiles = joinpath.(joinpath(stanio_data, "mixed_01"), csvfiles)
end

# ╔═╡ 78d5367b-542a-41b6-85da-fc616046dba4
begin
 	df = StanIO.read_csvfiles(csvfiles, :dataframe)
	df = df[:, 3:end]
 end

# ╔═╡ 2967add5-2c78-4b39-a055-174eac6daa3e
a3d, col_names = StanIO.read_csvfiles(csvfiles, :array; return_parameters=true);

# ╔═╡ c3975028-9fef-415a-ac57-9256e8b65637
StanIO.find_nested_columns(df)

# ╔═╡ 52084c1a-6db8-4c06-994e-0e0a9371c169
dct = parse_header(names(df))

# ╔═╡ 5cca3538-97f4-47d0-afa1-0bd95bf7f08e
ndf = stan_variables(dct, df)

# ╔═╡ b3e502df-7628-4fbe-b495-e7fcf843cf9c
ndf.a[1]

# ╔═╡ 840b7534-79c6-457f-b541-0a5eb4b5f07b
convert(NamedTuple, ndf)

# ╔═╡ d2b76958-3b6b-46f2-ade8-27d5936d9f7a
typeof(ndf.a[1])

# ╔═╡ Cell order:
# ╟─789c3f0b-8179-4126-baf5-fdd47b1938f5
# ╠═c08d0f35-92fb-4e10-81a6-5a68eea4d046
# ╠═3d7c5e2c-8eba-11ee-02c7-5382f0852ca2
# ╟─bdf6a4a7-358a-4004-ad24-0397441b203a
# ╠═a1328860-a754-4eb8-9855-e18d9ab50c0c
# ╠═ecf1f379-7774-4a41-928e-be10be1786b4
# ╟─ca0a71bb-7ac1-4c01-9a0a-24f1ce1479bd
# ╟─223159f3-c270-48f8-b5a4-c3e308d56970
# ╠═f5c0ae08-f47b-42f8-9039-1a4ac72cf892
# ╠═4e2984b1-435d-4cac-80ef-316060aa93af
# ╠═78d5367b-542a-41b6-85da-fc616046dba4
# ╠═2967add5-2c78-4b39-a055-174eac6daa3e
# ╠═c3975028-9fef-415a-ac57-9256e8b65637
# ╠═52084c1a-6db8-4c06-994e-0e0a9371c169
# ╠═5cca3538-97f4-47d0-afa1-0bd95bf7f08e
# ╠═b3e502df-7628-4fbe-b495-e7fcf843cf9c
# ╠═840b7534-79c6-457f-b541-0a5eb4b5f07b
# ╠═d2b76958-3b6b-46f2-ade8-27d5936d9f7a
