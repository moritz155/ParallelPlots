using ParallelPlots: parallelplot
using Test: @test, @testset
using DataFrames: size

@testset "Lines Count" begin
    df=create_person_df()
    fig, ax, sc = parallelplot(df)
    @test count_lines(fig) == size(df, 1)
end