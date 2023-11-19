"""

Helper package to create Stan input files and read Stan output files.

"""
module StanIO

using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF
using Unicode, DelimitedFiles, OrderedCollections
using DataFrames, CSV, Parameters, NamedTupleTools
using JSON

include("input/update_model_file.jl")
include("input/update_json_files.jl")

include("samples/read_csvfiles.jl")
include("samples/convert_a3d.jl")

include("output/dataframes.jl")
include("output/namedtuples.jl")
include("output/nesteddataframe.jl")

const stanio_dir = @__DIR__
const stanio_data = joinpath(stanio_dir, "..", "data")

export
    stanio_dir,
    stanio_data

end # module
