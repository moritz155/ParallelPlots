using DrWatson

using CairoMakie # fo Figure()

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
        ParallelPlots.create_parallel_coordinates_plot(DataFrame(nothing))
    end

    @test_throws ArgumentError begin
        ParallelPlots.create_parallel_coordinates_plot(df_missing)
    end
    @test_throws ArgumentError begin
        ParallelPlots.create_parallel_coordinates_plot(df_one_column)
    end
    @test_throws ArgumentError begin
        ParallelPlots.create_parallel_coordinates_plot(df_one_line)
    end
end

@testset "default call" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = ParallelPlots.create_parallel_coordinates_plot(df)

    @test fig !== nothing

    save("parallel_coordinates_plot.png", fig)

end

@testset "call with normalize" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = ParallelPlots.create_parallel_coordinates_plot(df, normalize=true)

    @test fig !== nothing

    save("parallel_coordinates_plot_normalized.png", fig)

end

@testset "call with scene width & height" begin

    # Generate sample multivariate data
    df = create_person_df()

    #display
    fig = ParallelPlots.create_parallel_coordinates_plot(df, scene_width = 300, scene_height = 300)

    @test fig !== nothing

    save("parallel_coordinates_plot_300x300.png", fig)

end





### DEBUG!
### TEST DRWATSON STOCKCHART


@testset "DrWatson Stockchart DEBUG" begin

    # Create Dict --> Needed?
    dfs = Dict(
        :dataFrame => [DataFrame(), create_person_df(), create_person_df()]
    )

# STOCKCHART EXAMPLE:

    timestamps = 1:100

    # we create some fake stock values in a way that looks pleasing later
    startvalue = StockValue(0.0, 0.0, 0.0, 0.0)
    stockvalues = foldl(timestamps[2:end], init = [startvalue]) do values, t
        open = last(values).close + 0.3 * randn()
        close = open + randn()
        high = max(open, close) + rand()
        low = min(open, close) - rand()

        push!(values, StockValue(
            open, close, high, low
        ))
    end


    f1 = stockchart(timestamps, stockvalues)

    # and let's try one where we change our default attributes
    f2, ax, sc = stockchart(timestamps, stockvalues,
        downcolor = :purple, upcolor = :orange)

    # TODO SAVE
    save("f1.png", f1)
    save("f2.png", f2)

    println("XXXXXX")
    println(ax)
    println(sc)

    # Scanning folder C:\Users\LEON_L~1\AppData\Local\Temp\jl_oWVAfO\test for result files.
    # DrWatson Stockchart DEBUG: Error During Test at C:\Users\Leon_Laptop\Desktop\UNI\Julia\GIT\ParallelPlots\test\runtests.jl:108
    #collect_results!(projectdir("test"))

    timestamps = Observable(collect(1:100))
    stocknode = Observable(stockvalues)

    fig, ax, sc = stockchart(timestamps, stocknode)

    record(fig, "stockchart_animation.mp4", 101:200, framerate = 30) do t
        # push a new timestamp without triggering the observable
        push!(timestamps[], t)

        # push a new StockValue without triggering the observable
        old = last(stocknode[])
        open = old.close + 0.3 * randn()
        close = open + randn()
        high = max(open, close) + rand()
        low = min(open, close) - rand()
        new = StockValue(open, close, high, low)
        push!(stocknode[], new)

        # now both timestamps and stocknode are synchronized
        # again and we can trigger one of them by assigning it to itself
        # to update the whole stockcharts plot for the new frame
        stocknode[] = stocknode[]
        # let's also update the axis limits because the plot will grow
        # to the right
        autolimits!(ax)
    end

end