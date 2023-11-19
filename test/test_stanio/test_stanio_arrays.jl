using StanIO, Test

csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "arrays")))
csvfiles = joinpath.(joinpath(stanio_data, "arrays"), csvfiles)

df = StanIO.read_csvfiles(csvfiles, :dataframe)
