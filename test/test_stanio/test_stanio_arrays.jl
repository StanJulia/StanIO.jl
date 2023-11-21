using StanIO, Test

csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "arrays")))
csvfiles = joinpath.(joinpath(stanio_data, "arrays"), csvfiles)

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
nts, nts_col_names = StanIO.read_csvfiles(csvfiles, :namedtuples; return_parameters=true);
display(keys(nts))

@test size(nts.z) == (2, 2, 3, 1000, 4)
