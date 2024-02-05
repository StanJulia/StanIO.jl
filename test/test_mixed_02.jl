using StanIO
using Test

csvfiles = filter(x -> x[end-3:end] == ".csv", readdir(joinpath(stanio_data, "mixed_02")))
csvfiles = joinpath.(joinpath(stanio_data, "mixed_02"), csvfiles)

df = StanIO.read_csvfiles(csvfiles, :dataframe)

dct = parse_header(names(df))

ndf = stan_variables(dct, df)

nnt = convert(NamedTuple, ndf)

lr = 1:size(df, 1)

u_df = StanIO.select_nested_column(df, :u)

a = extract_reshape(csvfiles, :m)
b = extract_reshape(csvfiles, "m"; nested=false)

a3d, col_names = read_csvfiles(csvfiles, :array; return_parameters=true)
c = extract_reshape(a3d, col_names, :m)

@testset "Mixed tuples 02" begin
    for i in rand(lr, 5)
        @test ndf.u[i][1][2] == reshape(Array(u_df[i, 7:26]), 4, 5)
        @test ndf.u[i][1][1][4] == Array(u_df[i, 5:6])
        @test ndf.m[1, 1] == a[1, 1]
        @test ndf.m[4000] == b[1000, 4, :, :]
        @test ndf.m[1] == c[1]
    end
end
