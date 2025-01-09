include("test_utils.jl")
using ParallelPlots
using Test

@testset "call with normalize" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = ParallelPlots.create_parallel_coordinates_plot(df, normalize=true)

    @test fig !== nothing

    print(fig)

    save("parallel_coordinates_plot_normalized.png", fig)
    display(fig)

end