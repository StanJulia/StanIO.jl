"""

Read a .csv output file created by Stan's cmdstan executable.

$(SIGNATURES)

"""
function read_csv_files(csv_file::String, output_format::Symbol=namedtuple;
    n_samples=1000, start=1, kwargs...)

    local a3d, monitors, index, idx, indvec, ftype, noofsamples
  
    println("Reading "*csvfile)

    if isfile(csvfile)
        println(csvfile*" found!")
        current_chain += 1
        instream = open(csvfile)
        
        # Skip initial set of commented lines, e.g. containing cmdstan version info, etc.      
        skipchars(isspace, instream, linecomment='#')
        
        # First non-comment line contains names of variables
        line = Unicode.normalize(readline(instream), newline2lf=true)
        idx = split(strip(line), ",")
        index = [idx[k] for k in 1:length(idx)]      
        indvec = 1:length(index)
        n_parameters = length(indvec)
        
        # Allocate a3d as we now know number of parameters
        if init_a3d
            init_a3d = false
            a3d = fill(0.0, n_samples, n_parameters)
        end
        
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
                a3d[j,:,current_chain] = flds
            end
        end
    end
  
    cnames = convert.(String, idx[indvec])
    if include_internals
        snames = [cnames[i] for i in 1:length(cnames)]
        indices = 1:length(cnames)
    else
        pindx = filter(p -> length(p) > 2 && p[end-1:end] == "__", cnames)
        snames = filter(p -> !(p in  pindx), cnames)
        indices = Vector{Int}(indexin(snames, cnames))
    end 

    #println(size(a3d))
    res = convert_a3d(a3d[start:end, indices], snames, Val(output_format); kwargs...)

    (res, snames) 

end   # end of read_samples
