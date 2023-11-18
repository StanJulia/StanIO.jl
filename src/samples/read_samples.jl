# read_samples

"""

Read sample output files created by StanSample.jl and return in the requested `output_format`.
The default output_format is :table. Optionally the list of parameter symbols can be returned.

$(SIGNATURES)

"""
function read_samples(csvfile::String, output_format=:namedtuple;
  return_parameters=false,
  start=1,
  kwargs...)

  (res, names) = read_csv_files(model::SampleModel, output_format;
    n_samples=1000, start, kwargs...
  )

  return( (res, names) )

end
