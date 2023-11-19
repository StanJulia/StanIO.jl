# read_samples

"""

Read sample output files created by StanSample.jl and return in the requested `output_format`.
The default output_format is :table. Optionally the list of parameter symbols can be returned.

$(SIGNATURES)


"""
function read_samples(model::StaticSampleModel, output_format=:table;
  include_internals=false,
  return_parameters=false,
  chains=1:model.num_chains,
  start=1,
  kwargs...)

  #println(chains)
  
  (res, names) = StanIO.read_csv_files(model::StaticSampleModel, output_format;
    include_internals, start, chains, kwargs...
  )

  if return_parameters
    return( (res, names) )
  else
    return(res)
  end

end
