#using StanIO
using Test

# write tests here

## NOTE add JET to the test environment, then uncomment
# using JET
# @testset "static analysis with JET.jl" begin
#     @test isempty(JET.get_reports(report_package(StanIO, target_modules=(StanIO,))))
# end

## NOTE add Aqua to the test environment, then uncomment
# @testset "QA with Aqua" begin
#     import Aqua
#     Aqua.test_all(StanIO; ambiguities = false)
#     # testing separately, cf https://github.com/JuliaTesting/Aqua.jl/issues/77
#     Aqua.test_ambiguities(StanIO)
# end

arrays_and_tuples_tests = [
    "generate_array_data/generate_arrays.jl",
    "generate_rectangle_data/generate_rectangles.jl",
    "generate_edge_data/generate_one_row.jl",
    "generate_edge_data/generate_oned_sample.jl",
    "generate_tuple_data/generate_tuples.jl",
    "generate_brian_tuple_data/generate_brian_tuples.jl",
]

#=
@testset "Arrays and tuples" begin
    for test in arrays_and_tuples_tests
        println("\nTesting: $test.")
        include(joinpath(@__DIR__, test))
    end
end
=#

stanio_tests = [
    "test_stanio/test_stanio_arrays.jl",
    "test_stanio/test_stanio_rectangles.jl",
]

@testset "StanIO tests" begin
    for test in stanio_tests
        println("\nTesting: $test.")
        include(joinpath(@__DIR__, test))
    end
end
