using ParallelPlots
using Test

using DataFrames

@testset "ArgumentError Tests" begin
    df_missing = DataFrame(Name=["Alice", "Bob", "Charlie"],
        Age=[25, 30, missing],
        City=["Berlin", "Munich", "Hamburg"])
    df_one_column = DataFrame(Name=["Alice", "Bob", "Charlie"])
    df_one_line = DataFrame(Name=["Alice"],
        Age=[25,],
        City=["Berlin"])
    # Test 1: Function throws ArgumentError for invalid input
    @test_throws ArgumentError begin
        ParallelPlots.create_parallel_coordinates_plot(DataFrame(nothing))
    end

    @test_throws ArgumentError begin
        ParallelPlots.create_parallel_coordinates_plot(df_missing)
    end
    @test_throws ArgumentError begin
        ParallelPlots.create_parallel_coordinates_plot(df_one_column)
    end
    @test_throws ArgumentError begin
        ParallelPlots.create_parallel_coordinates_plot(df_one_line)
    end
end 