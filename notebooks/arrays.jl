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

# ╔═╡ 79dca9f3-c2d8-430c-b0d5-658638dcf901
stan = "
parameters {
    real r;
	array[4] real x;
    matrix[2, 3] y;
    array[2, 2, 3] real<lower=0> z;
}
model {
    r ~ std_normal();
	x ~ std_normal();

    for (i in 1:2) {
        y[i,:] ~ std_normal();
        for (j in 1:2)
            z[i, j, :] ~ std_normal();
    }
}
";

# ╔═╡ 8aa3f91e-0faf-4a04-b614-3a2f6e140118
v = readdir(joinpath(stanio_data, "arrays"))[4][end-3:end]

# ╔═╡ 6a288a48-5b2c-417b-917e-c0e84ffc7563
begin
	csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "arrays")))
	csvfiles = joinpath.(joinpath(stanio_data, "arrays"), csvfiles)
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

# ╔═╡ e2564f5d-1f77-479d-8e35-2c0f64948fa1
size(nts.x)

# ╔═╡ 3f2b3110-c213-4344-b036-4a46b0d4a16f
size(nts.z)

# ╔═╡ 6f0ded97-1b1c-4b95-ac59-875b8c2fcc7b
nts_col_names

# ╔═╡ 09bb9ca6-9079-4c5c-9eeb-78ef51f6bb78
keys(nts)

# ╔═╡ d2202329-576b-49a5-a56a-cd7bda4541d1
nts.z[1:5]

# ╔═╡ 88ff640b-cab8-4423-98ce-a5f9b079e71e
size(nts.z)

# ╔═╡ 52c7d7e7-239a-49c1-848e-e0a568270132
@test size(nts.z) == (2, 2, 3, 1000, 4)

# ╔═╡ aefabe33-a787-47ad-a84c-8c8d36ca28b9
ndf, ndf_col_names = StanIO.read_csvfiles(csvfiles, :nesteddataframe; return_parameters=true);

# ╔═╡ cab5dbbb-ad30-4302-be98-c2fcd950f284
ndf_col_names

# ╔═╡ a4422d8b-ccd6-4c1c-9207-0f608442c687
ndf.x[1:10]

# ╔═╡ 176636b3-1a2b-4894-82f0-5bea0aef62cf
ndf.y[1:3]

# ╔═╡ 3d573697-2998-42d4-bb7f-01a134e88ab6
ndf.z[1:3]

# ╔═╡ a05c2963-3d94-4513-9d30-a12d2e2ec497
begin
	dct = Dict()
	for col_name in names(ndf)[8:end]
		dct[Symbol(col_name)] = ndf[:, col_name]
	end
	dct
end

# ╔═╡ d0f0e982-2110-48d4-ac32-fb0d7474b506
nt = (;dct...)

# ╔═╡ Cell order:
# ╠═86e386a0-b56f-42f1-a6de-1f15425d1a59
# ╠═c706075a-0174-450d-a1b0-b202cee4d216
# ╠═4530e47d-abe2-4521-ba6f-1e2e4a46cf3a
# ╠═e89264f6-3e70-474d-82aa-5956b8e824d4
# ╠═891015c3-8539-45e1-9a9a-71acfed9cfdf
# ╠═79dca9f3-c2d8-430c-b0d5-658638dcf901
# ╠═8aa3f91e-0faf-4a04-b614-3a2f6e140118
# ╠═6a288a48-5b2c-417b-917e-c0e84ffc7563
# ╠═01c5e25c-5a51-4082-8646-7793152dde33
# ╠═21eec5d3-ac5f-4522-8fb4-319d938234e5
# ╠═b50cf06b-9751-4ce7-9696-42b8051e6102
# ╠═e759b33d-d236-45e9-ba0c-33b85edc2545
# ╠═c1a23279-a0c4-47bc-a3fa-ed8a266ba5da
# ╠═b70b239a-c82c-4ba2-92dc-9b91a725ab9f
# ╠═91713a39-49ac-44fc-af4b-9c305fc29978
# ╠═5f5e778f-db6e-4887-a0b2-b0159da7397f
# ╠═e2564f5d-1f77-479d-8e35-2c0f64948fa1
# ╠═3f2b3110-c213-4344-b036-4a46b0d4a16f
# ╠═6f0ded97-1b1c-4b95-ac59-875b8c2fcc7b
# ╠═09bb9ca6-9079-4c5c-9eeb-78ef51f6bb78
# ╠═d2202329-576b-49a5-a56a-cd7bda4541d1
# ╠═88ff640b-cab8-4423-98ce-a5f9b079e71e
# ╠═52c7d7e7-239a-49c1-848e-e0a568270132
# ╠═aefabe33-a787-47ad-a84c-8c8d36ca28b9
# ╠═cab5dbbb-ad30-4302-be98-c2fcd950f284
# ╠═a4422d8b-ccd6-4c1c-9207-0f608442c687
# ╠═176636b3-1a2b-4894-82f0-5bea0aef62cf
# ╠═3d573697-2998-42d4-bb7f-01a134e88ab6
# ╠═a05c2963-3d94-4513-9d30-a12d2e2ec497
# ╠═d0f0e982-2110-48d4-ac32-fb0d7474b506
