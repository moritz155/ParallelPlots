using ParallelPlots: parallelplot
using Test: @testset, @test, @test_throws
@testset "call with feature_labels" begin
    # Generate sample multivariate data
    df = create_person_df(3)
    # Create set with correct Axis Labels
    fig = parallelplot(df, feature_labels=["Height","Weight","Age","Income","Education Years"])
    # TODO: do not Test agains nothing ;)
    @test fig !== nothing
    save("parallel_coordinates_plot_feature_labels.png", fig)
    # Test with not enough Labels
    @test_throws AssertionError begin
        parallelplot(df, feature_labels=["Height","Weight","Age","Income"])
    end
    # Test with too much Labels
    @test_throws AssertionError begin
        parallelplot(df, feature_labels=["Height","Weight","Age","Income","Education Years","I am to much :("])
    end
end