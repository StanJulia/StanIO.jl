### A Pluto.jl notebook ###
# v0.19.38

using Markdown
using InteractiveUtils

# ╔═╡ 3d7c5e2c-8eba-11ee-02c7-5382f0852ca2
using Pkg

# ╔═╡ a1328860-a754-4eb8-9855-e18d9ab50c0c
Pkg.activate(expanduser("~/.julia/dev/StanIO"))

# ╔═╡ ecf1f379-7774-4a41-928e-be10be1786b4
begin
	using StanIO
	using Statistics
end

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

# ╔═╡ 132fcda9-f6cc-4f88-a093-5594b541cc42
stan = "
generated quantities {
    real base = normal_rng(0, 1);
    matrix[4, 5] m = to_matrix(linspaced_vector(20, 7, 11), 4, 5) * base;
    array[2,3] tuple(array[2] tuple(real, array[2] real), matrix[4,5]) u =
    {
        {
            (
                {(base, {base *2, base *3}), (base *4, {base*5, base*6})}, m
            ),
            (
                {(base, {base *2, base *3}), (base *4, {base*5, base*6})}, m
            ),
            (
                {(base, {base *2, base *3}), (base *4, {base*5, base*6})}, m
            )
        },
        {
            (
                {(base, {base *2, base *3}), (base *4, {base*5, base*6})}, m
            ),
            (
                {(base, {base *2, base *3}), (base *4, {base*5, base*6})}, m
            ),
            (
                {(base, {base *2, base *3}), (base *4, {base*5, base*6})}, m
            )
        }
    };
}
";


# ╔═╡ 4e2984b1-435d-4cac-80ef-316060aa93af
begin
	csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "mixed_02")))
	csvfiles = joinpath.(joinpath(stanio_data, "mixed_02"), csvfiles)
end

# ╔═╡ 78d5367b-542a-41b6-85da-fc616046dba4
begin
 	df = StanIO.read_csvfiles(csvfiles, :dataframe)
	#df = df[:, 4:end]
 end

# ╔═╡ 2967add5-2c78-4b39-a055-174eac6daa3e
a3d, col_names = StanIO.read_csvfiles(csvfiles, :array; return_parameters=true);

# ╔═╡ 4d30b847-b4e8-429b-9e18-0f9c0e8e6dfb
size(a3d)

# ╔═╡ c3975028-9fef-415a-ac57-9256e8b65637
StanIO.find_nested_columns(df)

# ╔═╡ 533dbca3-980c-41de-83e9-fbbab3728738
u_df = StanIO.select_nested_column(df, :u)

# ╔═╡ e689523d-1bbb-43e7-a465-aa2dfc045c1f
size(u_df)

# ╔═╡ 52084c1a-6db8-4c06-994e-0e0a9371c169
dct = parse_header(names(df))

# ╔═╡ 3e8bf2c5-7e8e-41c8-b9c8-6be227be69fd
dct["u"]

# ╔═╡ 5cca3538-97f4-47d0-afa1-0bd95bf7f08e
ndf = stan_variables(dct, df)

# ╔═╡ 1ed77d9a-bc91-4659-ab21-fc6704634598
ndf.u[1]

# ╔═╡ 840b7534-79c6-457f-b541-0a5eb4b5f07b
convert(NamedTuple, ndf)

# ╔═╡ d2b76958-3b6b-46f2-ade8-27d5936d9f7a
typeof(ndf.u[1])

# ╔═╡ 94383d28-1c80-4069-8503-70abe741a7a0
typeof(ndf)

# ╔═╡ 0031db11-1940-48c5-9946-9079fd5fd110
ndf.m

# ╔═╡ e1552abe-1ca1-4eab-953f-2f535ea47713
mean(ndf.m)

# ╔═╡ 5f46f254-e2e2-4965-b49c-e83110a3c489
std(ndf.m)

# ╔═╡ 78387ca3-a875-4e09-a00c-0d2a6b05ef47
a = extract_reshape(csvfiles, :m);

# ╔═╡ a5c7425d-57aa-4b90-9ffc-efe0645018f1
size(a)

# ╔═╡ 629177f2-68ac-46e3-ac5c-32a9dbd018ac
a[1,1]

# ╔═╡ 05239335-d27a-4a50-866a-ff1ea13ad4ea
a[1000,4]

# ╔═╡ 1c2e96de-74b3-4201-9fd3-ace4e7822109
b = extract_reshape(csvfiles, "m");

# ╔═╡ e9024961-e510-4770-bffe-bffaa362145b
b[1000, 4]

# ╔═╡ 14efd4f4-84cd-415a-943d-544663a4e03a
l = extract_reshape(csvfiles, "base");

# ╔═╡ 4ce6ce1a-b2b9-420a-b4ac-af557e4c2dff
c = extract_reshape(csvfiles, :m; nested=false);

# ╔═╡ 081ce983-df9f-49ec-ad46-0cd2f77d07c3
size(c)

# ╔═╡ 8b5c040e-377f-4f84-8927-01ceeb82e857
c[1, 1, :, :]

# ╔═╡ 071576d7-c4d1-4ba0-ae4e-5551cc3d4122
c[1000, 4, :, :]

# ╔═╡ 4670a92b-59e9-4551-aedd-5dd06c1a250e
ndf.m[1, 1] == a[1, 1]

# ╔═╡ 11557a52-f128-41ef-8051-79e42a450c3d
ndf.m[4000] == c[1000, 4, :, :]

# ╔═╡ 997a079a-d91e-47fc-969f-f9fca3a09086
typeof(ndf.u[1])

# ╔═╡ 32eb73d5-3f6c-4888-b397-736311d48d91
size(ndf[1, "u"])

# ╔═╡ beb15fa2-0601-4067-8f1e-debac814d3a3
typeof(ndf.m[1])

# ╔═╡ 4bf4a353-772f-488f-afad-5902bec32472
size(ndf.m[1])

# ╔═╡ 6b228208-33dc-4484-b03c-100f7aef0beb
size(ndf[1, "m"])

# ╔═╡ 7eb4fdd4-b070-498d-919f-b9461b4ad910
u = extract_reshape(csvfiles, :u);

# ╔═╡ 90b134e6-2583-47cb-8644-dfd0f5af1b98
u[1, 1]

# ╔═╡ d1afd4d1-981a-4fe6-b0c0-3beb41682086
u2 = extract_reshape(csvfiles, :u; nested=false);

# ╔═╡ Cell order:
# ╟─789c3f0b-8179-4126-baf5-fdd47b1938f5
# ╠═c08d0f35-92fb-4e10-81a6-5a68eea4d046
# ╠═3d7c5e2c-8eba-11ee-02c7-5382f0852ca2
# ╟─bdf6a4a7-358a-4004-ad24-0397441b203a
# ╠═a1328860-a754-4eb8-9855-e18d9ab50c0c
# ╠═ecf1f379-7774-4a41-928e-be10be1786b4
# ╟─ca0a71bb-7ac1-4c01-9a0a-24f1ce1479bd
# ╠═132fcda9-f6cc-4f88-a093-5594b541cc42
# ╠═4e2984b1-435d-4cac-80ef-316060aa93af
# ╠═78d5367b-542a-41b6-85da-fc616046dba4
# ╠═2967add5-2c78-4b39-a055-174eac6daa3e
# ╠═4d30b847-b4e8-429b-9e18-0f9c0e8e6dfb
# ╠═c3975028-9fef-415a-ac57-9256e8b65637
# ╠═533dbca3-980c-41de-83e9-fbbab3728738
# ╠═e689523d-1bbb-43e7-a465-aa2dfc045c1f
# ╠═52084c1a-6db8-4c06-994e-0e0a9371c169
# ╠═3e8bf2c5-7e8e-41c8-b9c8-6be227be69fd
# ╠═5cca3538-97f4-47d0-afa1-0bd95bf7f08e
# ╠═1ed77d9a-bc91-4659-ab21-fc6704634598
# ╠═840b7534-79c6-457f-b541-0a5eb4b5f07b
# ╠═d2b76958-3b6b-46f2-ade8-27d5936d9f7a
# ╠═94383d28-1c80-4069-8503-70abe741a7a0
# ╠═0031db11-1940-48c5-9946-9079fd5fd110
# ╠═e1552abe-1ca1-4eab-953f-2f535ea47713
# ╠═5f46f254-e2e2-4965-b49c-e83110a3c489
# ╠═78387ca3-a875-4e09-a00c-0d2a6b05ef47
# ╠═a5c7425d-57aa-4b90-9ffc-efe0645018f1
# ╠═629177f2-68ac-46e3-ac5c-32a9dbd018ac
# ╠═05239335-d27a-4a50-866a-ff1ea13ad4ea
# ╠═1c2e96de-74b3-4201-9fd3-ace4e7822109
# ╠═e9024961-e510-4770-bffe-bffaa362145b
# ╠═14efd4f4-84cd-415a-943d-544663a4e03a
# ╠═4ce6ce1a-b2b9-420a-b4ac-af557e4c2dff
# ╠═081ce983-df9f-49ec-ad46-0cd2f77d07c3
# ╠═8b5c040e-377f-4f84-8927-01ceeb82e857
# ╠═071576d7-c4d1-4ba0-ae4e-5551cc3d4122
# ╠═4670a92b-59e9-4551-aedd-5dd06c1a250e
# ╠═11557a52-f128-41ef-8051-79e42a450c3d
# ╠═997a079a-d91e-47fc-969f-f9fca3a09086
# ╠═32eb73d5-3f6c-4888-b397-736311d48d91
# ╠═beb15fa2-0601-4067-8f1e-debac814d3a3
# ╠═4bf4a353-772f-488f-afad-5902bec32472
# ╠═6b228208-33dc-4484-b03c-100f7aef0beb
# ╠═7eb4fdd4-b070-498d-919f-b9461b4ad910
# ╠═90b134e6-2583-47cb-8644-dfd0f5af1b98
# ╠═d1afd4d1-981a-4fe6-b0c0-3beb41682086
