using StanIO, Test

csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "mixed_01")))
csvfiles = joinpath.(joinpath(stanio_data, "mixed_01"), csvfiles)

df = StanIO.read_csvfiles(csvfiles, :dataframe)

dct = parse_header(names(df))

ndf = stan_variables(dct, df)

nnt = convert(NamedTuple, ndf)

lr = 1:size(df, 1)

a_df = StanIO.select_nested_column(df, :a)

@testset "Mixed tuples 01" begin

    for i in rand(lr, 15)
        @test ndf.a[i][2, 2][2] == Array(a_df[i, 14:15])
    end
end

# 