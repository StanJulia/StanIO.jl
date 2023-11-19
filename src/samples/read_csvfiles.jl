"""

Read .csv output files created by Stan's cmdstan executable.

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `csvfiles` : Vector of file names
* `output_format` : Requested output format
```

### Optional arguments
```julia
* `include_internals=true` : Include internal parameters
* `return_parameters=false` : Include internal parameters
* `n_chains=length(csvfiles)` : No of chains
* `n_samples=1000`: No of samples
* `kwargs...`
```
Not exported
"""
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