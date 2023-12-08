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
    "generate_test_data/generate_test_cases.jl",
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
    "test_pure_01.jl",
    "test_mixed_01.jl",
    "test_mixed_02.jl",
]

@testset "StanIO tests" begin
    for test in stanio_tests
        println("\nTesting: $test.")
        include(joinpath(@__DIR__, test))
    end
end
