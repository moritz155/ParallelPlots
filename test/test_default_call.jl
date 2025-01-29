using ParallelPlots: parallelplot
using Test: @test, @testset
using CairoMakie: save

@testset "default call" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = parallelplot(df)

    @test fig !== nothing

    save("parallel_coordinates_plot.png", fig)

end
