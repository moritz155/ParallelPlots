include("test_utils.jl")
using ParallelPlots
using Test

@testset "call with scene width & height" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = ParallelPlots.create_parallel_coordinates_plot(df, scene_width = 300, scene_height = 300)

    @test fig !== nothing

    print(fig)

    save("parallel_coordinates_plot_300x300.png", fig)
    display(fig)

end
