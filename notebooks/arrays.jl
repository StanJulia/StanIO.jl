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
	using Unicode
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
    array[2, 2, 3] real<lower=0> z;
}
model {
    r ~ std_normal();

    for (i in 1:2) {
        x[i,:] ~ std_normal();
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

# ╔═╡ 14923791-d077-4509-a51d-d49300457b92
function read_csvfiles(csvfiles, output_format::Symbol;
	include_internals=true,
	return_parameters=false,
	n_chains = length(csvfiles),
	n_samples = 1000,
	kwargs...)

	csvfile = csvfiles[1]
	if isfile(csvfile)
		instream = open(csvfile)
	
		# Skip initial set of commented lines, e.g. containing cmdstan version info, etc.      
		skipchars(isspace, instream, linecomment='#')
		
		# First non-comment line contains names of variables
		line = Unicode.normalize(readline(instream), newline2lf=true)
		idx = split(strip(line), ",")
		index = [idx[k] for k in 1:length(idx)]      
		indvec = 1:length(index)
		n_parameters = length(indvec)
		close(instream)
	else
		@warn " File $csvfile not found."
	end

	a3d = fill(0.0, n_samples, n_parameters, n_chains)	
	current_chain = 0

	# Read .csv files and return a3d[n_samples, parameters, n_chains]
	for file in csvfiles 
	    if isfile(file)
	        current_chain += 1
	        instream = open(file)
	        
	        # Skip initial set of commented lines, e.g. containing cmdstan version info, etc.      
	        skipchars(isspace, instream, linecomment='#')
	        
	        # First non-comment line contains names of variables
	        Unicode.normalize(readline(instream), newline2lf=true)
	        skipchars(isspace, instream, linecomment='#')
	        for j in 1:n_samples
				skipchars(isspace, instream, linecomment='#')
				line = Unicode.normalize(readline(instream), newline2lf=true)
				if eof(instream) && length(line) < 2
					close(instream)
					break
				else
					flds = parse.(Float64, split(strip(line), ","))
					flds = reshape(flds[indvec], 1, length(indvec))
					a3d[j, :, current_chain] = flds
				end
	        end   # read in samples
		else
			@warn "File $file not found!"
	    end   # read in next file if it exists
	end   # read in all cpp_chains
	  
	# Filtering of draws, parameters and chains before further processing
	
	cnames = convert.(String, idx[indvec])
	if include_internals
		snames = [cnames[i] for i in 1:length(cnames)]
		indices = 1:length(cnames)
	else
		pi = filter(p -> length(p) > 2 && p[end-1:end] == "__", cnames)
		snames = filter(p -> !(p in  pi), cnames)
		indices = Vector{Int}(indexin(snames, cnames))
	end
	
	res = StanIO.convert_a3d(a3d, snames, Val(output_format))

	if return_parameters
		return (res, snames)
	else
		return res
	end
end

# ╔═╡ 01c5e25c-5a51-4082-8646-7793152dde33
df = StanIO.read_csvfiles(csvfiles, :dataframe);

# ╔═╡ 21eec5d3-ac5f-4522-8fb4-319d938234e5
df

# ╔═╡ b50cf06b-9751-4ce7-9696-42b8051e6102
df2, df_col_names = read_csvfiles(csvfiles, :dataframe; return_parameters=true);

# ╔═╡ e759b33d-d236-45e9-ba0c-33b85edc2545
df_col_names

# ╔═╡ c1a23279-a0c4-47bc-a3fa-ed8a266ba5da
a3d, array_col_names = read_csvfiles(csvfiles, :array; return_parameters=true);

# ╔═╡ b70b239a-c82c-4ba2-92dc-9b91a725ab9f
size(a3d)

# ╔═╡ 91713a39-49ac-44fc-af4b-9c305fc29978
array_col_names

# ╔═╡ 5f5e778f-db6e-4887-a0b2-b0159da7397f
nt, nt_col_names = read_csvfiles(csvfiles, :namedtuples; return_parameters=true);

# ╔═╡ e2564f5d-1f77-479d-8e35-2c0f64948fa1
nt

# ╔═╡ 6f0ded97-1b1c-4b95-ac59-875b8c2fcc7b
nt_col_names

# ╔═╡ 09bb9ca6-9079-4c5c-9eeb-78ef51f6bb78
keys(nt)

# ╔═╡ Cell order:
# ╠═86e386a0-b56f-42f1-a6de-1f15425d1a59
# ╠═c706075a-0174-450d-a1b0-b202cee4d216
# ╠═4530e47d-abe2-4521-ba6f-1e2e4a46cf3a
# ╠═e89264f6-3e70-474d-82aa-5956b8e824d4
# ╠═891015c3-8539-45e1-9a9a-71acfed9cfdf
# ╠═79dca9f3-c2d8-430c-b0d5-658638dcf901
# ╠═8aa3f91e-0faf-4a04-b614-3a2f6e140118
# ╠═6a288a48-5b2c-417b-917e-c0e84ffc7563
# ╠═14923791-d077-4509-a51d-d49300457b92
# ╠═01c5e25c-5a51-4082-8646-7793152dde33
# ╠═21eec5d3-ac5f-4522-8fb4-319d938234e5
# ╠═b50cf06b-9751-4ce7-9696-42b8051e6102
# ╠═e759b33d-d236-45e9-ba0c-33b85edc2545
# ╠═c1a23279-a0c4-47bc-a3fa-ed8a266ba5da
# ╠═b70b239a-c82c-4ba2-92dc-9b91a725ab9f
# ╠═91713a39-49ac-44fc-af4b-9c305fc29978
# ╠═5f5e778f-db6e-4887-a0b2-b0159da7397f
# ╠═e2564f5d-1f77-479d-8e35-2c0f64948fa1
# ╠═6f0ded97-1b1c-4b95-ac59-875b8c2fcc7b
# ╠═09bb9ca6-9079-4c5c-9eeb-78ef51f6bb78
