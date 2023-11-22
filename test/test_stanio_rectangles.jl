using StanIO, Test

csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "rectangles")))
csvfiles = joinpath.(joinpath(stanio_data, "rectangles"), csvfiles)

println()
a3d, array_col_names = StanIO.read_csvfiles(csvfiles, :array; return_parameters=true);
display(array_col_names)

println()
df = StanIO.read_csvfiles(csvfiles, :dataframe)
display(names(df))

println()
ndf = StanIO.read_csvfiles(csvfiles, :nesteddataframe)
display(names(ndf))

println()
nt = convert(NamedTuple, ndf)
display(keys(nt))

@test size(nt.z) == (4000,)
