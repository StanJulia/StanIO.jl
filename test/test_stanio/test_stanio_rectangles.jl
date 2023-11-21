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
dct = Dict()
for col_name in names(ndf)[8:end]
    dct[Symbol(col_name)] = ndf[:, col_name]
end
nt = (;dct...)

@test size(nt.z) == (4000,)
