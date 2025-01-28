using ParallelPlots: parallelplot
using Test: @testset, @test

@testset "call with normalize" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = parallelplot(df, normalize=true; title="Normalize")

    @test fig !== nothing

    save("parallel_coordinates_plot_normalized.png", fig)

end