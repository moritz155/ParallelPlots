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
    save("parallel_coordinates_plot_color_axis_weight.png", fig)

    fig = parallelplot(df,
        color_feature="weight",
        feature_selection=["height","age","income"],
        feature_labels=["Height","Age","Income"],
        colormap=:thermal
    )
    save("parallel_coordinates_plot_color_weight_deselected.png", fig)

    fig = parallelplot(df,
        color_feature="weight",
        feature_selection=["height","age","income"],
        feature_labels=["Height","Age","Income"],
        colormap=:thermal,
        show_color_legend = false
    )
    save("parallel_coordinates_plot_color_weight_deselected_noColorBar.png", fig)

    fig = parallelplot(df,
        feature_selection=["height","age","income"],
        feature_labels=["Height","Age","Income"],
        colormap=:thermal
    )
    save("parallel_coordinates_plot_color_no_selection.png", fig)

    fig = parallelplot(df,
        color_feature="weight",
        colormap=:thermal,
        show_color_legend = true
    )
    save("parallel_coordinates_plot_color_with_bar.png", fig)

    # Test with Label not available
    @test_throws AssertionError begin
        parallelplot(df, color_feature="wrong feature name")
    end

    # Test with Selection not available
    @test_throws AssertionError begin
        parallelplot(df, feature_selection=["height","age","incomeWrongInput"])
    end

end