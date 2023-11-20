using StanIO, Test

csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "arrays")))
csvfiles = joinpath.(joinpath(stanio_data, "arrays"), csvfiles)

df = StanIO.read_csvfiles(csvfiles, :dataframe)

a3d, array_col_names = StanIO.read_csvfiles(csvfiles, :array; return_parameters=true);

nts, nts_col_names = StanIO.read_csvfiles(csvfiles, :namedtuples; return_parameters=true);

display(keys(nts))

@test size(nts.z) == (2, 2, 3, 1000, 4)
