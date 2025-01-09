using ParallelPlots
using Test

using Random
using JLD
using DataFrames

#generate Data
function create_person_df(n_samples = 10)

    Random.seed!(10)
    df = DataFrame(
        height=rand(150:180, n_samples),
        weight=randn(n_samples),
        age=rand(0:70, n_samples), # random numbers between 0 and 70
        income=randn(n_samples),
        education_years=rand(0:25, n_samples) # random numbers between 0 and 70
    )

    return df
end
function create_car_df(n_samples = 10)

    Random.seed!(10)
    df = DataFrame(
        horsepower=rand(60:300, n_samples),
        weight=rand(90:2000, n_samples),
        age=rand(0:70, n_samples)
    )

    return df
end


@testset "ArgumentError Tests" begin
    df_missing = DataFrame(Name=["Alice", "Bob", "Charlie"],
        Age=[25, 30, missing],
        City=["Berlin", "Munich", "Hamburg"])
    df_one_column = DataFrame(Name=["Alice", "Bob", "Charlie"])
    df_one_line = DataFrame(Name=["Alice"],
        Age=[25,],
        City=["Berlin"])
    # Test 1: Function throws ArgumentError for invalid input
    @test_throws ArgumentError begin
        parallelplot(DataFrame(nothing))
    end

    @test_throws ArgumentError begin
        parallelplot(df_missing)
    end
    @test_throws ArgumentError begin
        parallelplot(df_one_column)
    end
    @test_throws ArgumentError begin
        parallelplot(df_one_line)
    end
end

@testset "default call" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = parallelplot(df)

    @test fig !== nothing

    save("parallel_coordinates_plot.png", fig)

end

@testset "call with normalize" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = parallelplot(df, normalize=true)

    @test fig !== nothing

    save("parallel_coordinates_plot_normalized.png", fig)

end

@testset "call with scene width & height" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = parallelplot(df, scene_width = 300, scene_height = 300)

    @test fig !== nothing

    save("parallel_coordinates_plot_300x300.png", fig)

end

@testset "Test the Recipe --> Use a Observable" begin

    # create the Data
    df_observable = Observable(create_person_df(2))

    # create the Plot
    fig, ax, sc = parallelplot(df_observable)
    save("pcp_initialized.png", fig)

    # Record for Debug purpose
    record(fig, "PCP_recipe_animation.mp4", 2:60, framerate = 2) do t

        # Update Dataframe
        if(iseven(t))
            df_observable[] = create_person_df(5)
        else
            df_observable[] = create_car_df(t)
        end


    end

    # TODO: Write Testcases
    #e.g. Test the Size for Changes

end
include("test_argument_errors.jl")
include("test_call_with_normalize.jl")
include("test_custom_dimensions.jl")
include("test_default_call.jl")