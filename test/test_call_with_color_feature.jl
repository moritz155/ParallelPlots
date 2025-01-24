#include("test_utils.jl")
using ParallelPlots
using Test

@testset "call with color feature Axis" begin

    # Generate sample multivariate data
    df = create_person_df()

    # Create set with correct Axis Labels
    fig = parallelplot(df, color_feature="weight", colormap=:thermal)

    # TODO: do not Test agains nothing ;)
    @test fig !== nothing
    save("parallel_coordinates_plot_color_axis.png", fig)

    # Test with Label not available
    @test_throws AssertionError begin
        parallelplot(df, color_feature="wrong feature name")
    end

end