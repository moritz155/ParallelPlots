using ParallelPlots:parallelplot
using Test: @test

using DataFrames: DataFrame

@testset "default call curved" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = parallelplot(df, curve=true)

    @test fig !== nothing

    save("parallel_coordinates_plot_curved.png", fig)

end
