using StanIO, Test

csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "pure_01")))
csvfiles = joinpath.(joinpath(stanio_data, "pure_01"), csvfiles)

df = StanIO.read_csvfiles(csvfiles, :dataframe)
df = df[:, 8:end]

dct = parse_header(names(df))

ndf = stan_variables(dct, df)

nnt = convert(NamedTuple, ndf)

lr = 1:size(df, 1)

@testset "Test arrays" begin

    for i in rand(lr, 5)
        @test ndf[i, :x] == reshape(Array(df[i, 4:9]), (2, 3))
        @test nnt.x[i] == reshape(Array(df[i, 4:9]), (2, 3))
    end
end

@testset "Complex values" begin

    for i in rand(lr, 5)
        @test ndf[i, :zv] == Array(df[i, ["zv.1", "zv.2"]])
        @test nnt.zv[i] == Array(df[i, ["zv.1", "zv.2"]])
    end
end

@testset "Tuples" begin

    for i in rand(lr, 5)
        @test ndf[i, :bar3] == (df[i, 15], (df[i, 16], (df[i, 17], df[i, 18])))
        @test nnt.bar3[i] == (df[i, 15], (df[i, 16], (df[i, 17], df[i, 18])))
    end
end
