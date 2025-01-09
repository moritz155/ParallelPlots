using ParallelPlots
using Test

using DataFrames

@testset "default call" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = parallelplot(df)

    @test fig !== nothing

    save("parallel_coordinates_plot.png", fig)

end
