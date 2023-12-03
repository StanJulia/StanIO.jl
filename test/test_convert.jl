using StanIO, Test

csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "test_data")))
csvfiles = joinpath.(joinpath(stanio_data, "test_data"), csvfiles)

df = StanIO.read_csvfiles(csvfiles, :dataframe)
df = df[:, 8:end]

dct = parse_header(names(df))

ndf = stan_variables(dct, df)

convert(NamedTuple, ndf)
