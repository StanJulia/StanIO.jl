using StanIO
using Test

csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "ultimate")))
csvfiles = joinpath.(joinpath(stanio_data, "ultimate"), csvfiles)


df = StanIO.read_csvfiles(csvfiles, :dataframe)

dct = parse_header(names(df))
ndf = stan_variables(dct, df)
nnt = convert(NamedTuple, ndf)

lr = 1:size(df, 1)

pair_df = StanIO.select_nested_column(df, :pair)
nested_df = StanIO.select_nested_column(df, :nested)
arr_pair_df = StanIO.select_nested_column(df, :arr_pair)
avn_df = StanIO.select_nested_column(df, :arr_very_nested)
a2d_df = StanIO.select_nested_column(df, :arr_2d_pair)
u_df = StanIO.select_nested_column(df, :ultimate)

@testset "Pair" begin
    for i in rand(lr, 10)
        @test ndf.pair[i] == (pair_df[i, 1], pair_df[i, 2])
    end
end

@testset "Nested" begin
    for i in rand(lr, 15)
        @test ndf.nested[i][1] == nested_df[i, 1]
        @test ndf.nested[i][2] == (nested_df[i, 2], nested_df[i, 3])
    end
end

@testset "Arr_pair" begin
    for i in rand(lr, 15)
        @test ndf.arr_pair[i] == [(arr_pair_df[i, 1], arr_pair_df[i, 2]),
        	(arr_pair_df[i, 3], arr_pair_df[i, 4])]
    end
end

@testset "Arr_very_nested" begin
    for i in rand(lr, 15)
        @test ndf.arr_very_nested[i][3][1][1] == avn_df[i, 1]
        @test ndf.arr_very_nested[i][3][1][2] == (avn_df[i, 2], avn_df[i, 3])
        @test ndf.arr_very_nested[i][3][2] == avn_df[i, 12]
    end
end

@testset "Arr_2d_pair" begin
    for i in rand(lr, 15)
        @test ndf.arr_2d_pair[i][3, 2] == (a2d_df[i, 11], a2d_df[i, 12])
    end
end
@testset "Ultimate" begin
    for i in rand(lr, 15)
    	@test ndf.ultimate[i][2, 3][1][4] == Array(u_df[i, 135:136])
        @test ndf.ultimate[i][2, 3][2] == reshape(Array(u_df[i, (end-19):end]), 4, 5)
    end
end
