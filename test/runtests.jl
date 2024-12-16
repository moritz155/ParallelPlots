using ParallelPlots
using Test

using Random
using JLD
using DataFrames

#generate Data
function create_person_df()

    Random.seed!(10)
    n_samples = 10
    df = DataFrame(
        height=randn(n_samples),
        weight=randn(n_samples),
        age=rand(0:70, n_samples), # random numbers between 0 and 70
        income=randn(n_samples),
        education_years=rand(0:25, n_samples) # random numbers between 0 and 70
    )

    return df
end

@testset "default call" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = ParallelPlots.create_parallel_coordinates_plot(df)

    @test fig != nothing

    save("parallel_coordinates_plot.png", fig)
    display(fig)

end

@testset "call with normalize" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = ParallelPlots.create_parallel_coordinates_plot(df, normalize=true)

    @test fig != nothing

    print(fig)

    save("parallel_coordinates_plot_normalized.png", fig)
    display(fig)

end