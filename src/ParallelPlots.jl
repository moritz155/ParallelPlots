module ParallelPlots

    export create_parallel_coordinates_plot

using CairoMakie
using DataFrames


function normalize_DF(data::DataFrame)
    for col in names(data)
        data[!, col] = (data[!, col] .- minimum(data[!, col])) ./
                                  (maximum(data[!, col]) - minimum(data[!, col]))
    end

    return data
end


function input_check(data::DataFrame)
    if data === nothing
        throw(ArgumentError("Data cannot be nothing"))
    end
    if size(data, 2) < 2 # otherwise there will be a nullpointer exception later
        throw(ArgumentError("Data must have at least two columns"))
    end
    if size(data, 1) < 2 # otherwise there will be a nullpointer exception later
        throw(ArgumentError("Data must have at least two lines"))
    end
    if any(collect(any(ismissing.(c)) for c in eachcol(data))) # checks for missing values
        println("There are missing values in the DataFrame.")
        throw(ArgumentError("Data cannot have missing values"))
    end
end




"""
    create_parallel_coordinates_plot(data::DataFrame, normalize::Bool)

- Julia version: 1.10.5

# Constructors
```julia
ParallelPlots.create_parallel_coordinates_plot(data::DataFrame; normalize::Bool=false, scene_width::Integer=800, scene_height::Integer=600)
```

# Arguments

- `data::DataFrame`:
- `normalize::Bool`:

# Examples
```@example
julia> ParallelPlots.create_parallel_coordinates_plot(DataFrame(height=160:180,weight=60:80,age=20:40))

# If you want to normalize the Data, you can add the value normalized=true, default is false
julia> ParallelPlots.create_parallel_coordinates_plot(DataFrame(height=160:180,weight=reverse(60:80),age=20:40),normalize=true)

# If you want to set the size of the plot (default width:800, height:600)
julia> ParallelPlots.create_parallel_coordinates_plot( DataFrame(height=160:180,weight=60:80,age=20:40), scene_width=200, scene_height=200 )

```


"""
function create_parallel_coordinates_plot(data::DataFrame; normalize::Bool=false, scene_width::Integer=800, scene_height::Integer=600)
    
    # check the given DataFrame
    input_check(data)

    # Normalize the data if required
    if normalize
        data = normalize_DF(data)
    end

    # Parse the DataFrame into a list of arrays
    parsed_data = [data[!, col] for col in names(data)]

    # Compute limits for each column
    limits = [(minimum(col), maximum(col)) for col in parsed_data]

    let
        # creates the Scene for the Plot
        scene = Scene(resolution = (scene_width, scene_height), camera=campixel!)
        numberFeatures = length(parsed_data) # Number of features, equivalent to the X Axis
        sampleSize = size(data, 1)       # Number of samples, equivalent to the Y Axis

        # Plot dimensions
        width = scene_width * 0.75  # 75% of scene width
        height = scene_height * 0.75  # 75% of scene width
        offset = min(scene_width, scene_height) * 0.15  # 15% of scene dimensions

        # Create axes
        for i in 1:numberFeatures
            # x will be used to split the Scene for each feature
            x = (i - 1) / (numberFeatures - 1) * width
            # LineAxis will create one Axis Vertical, for each Feature one Axis
            MakieLayout.LineAxis(scene, limits=limits[i],
                spinecolor=:black, labelfont="Arial",
                ticklabelfont="Arial", spinevisible=true,
                minorticks=IntervalsBetween(2),
                # the lowest and highest point to maximize the Axis from Bottom to Top
                endpoints=Point2f0[(offset + x, offset), (offset + x, offset + height)],
                ticklabelalign=(:right, :center), labelvisible=true,
                # using the names of the dataframe for display the axis
                label=names(data)[i])
        end

        # Draw lines connecting points for each row
        for i in 1:sampleSize
            dataPoints = [
                # calcuating the point respectivly of the width and height in the Screen
                Point2f0(
                    # calculates which feature the Point should be on
                    offset + (j - 1) / (numberFeatures - 1) * width,
                    # calculates the Y axis value
                    (parsed_data[j][i] - limits[j][1]) / (limits[j][2] - limits[j][1]) * height + offset
                )
                # iterates through the Features and creates for each feature the samplePoint (above)
                for j in 1:numberFeatures
            ]
            lines!(scene, dataPoints, color=get(Makie.ColorSchemes.inferno, (i - 1) / (sampleSize - 1)),
                show_axis=false)
        end
        return scene
    end
end


################################### Creating the PCP by with the Example

@recipe(ParallelPlot, df) do scene
    Attributes(
    # size, normalize attributes
        normalize = false,
        scene_width = 800,
        scene_height = 600,
    )
end

# This Function will completly renew the Plot
# If we want to change only axis --> the axis must be send individually to this function!
function Makie.plot!(pp::ParallelPlot{<:Tuple{<:DataFrame}})

    # our first parameter is the DataFrame-Observable
    df_observable  = pp[1]

    # EXAMPLE: access Attributes
    println("EXAMPLE: access Attributes")
    println(pp.normalize)

    # predefine Observable for the Plot. Will be 'filled' in the update_plot
    plot_df = Observable(DataFrame())
    xs = Observable(Float32[]) # TODO: empty Array?!
    ys = Observable(Float32[])

    println(pp)
    # GET SCENE, YAY
    scene = current_figure()



    # this helper function will update our observables
    # whenever df_observable change
    function update_plot(data)

        # TODO: recalc values etc.

        # Example Update the value DF
        plot_df[] = data


        #######################
        ### EXAMPLE BARPLOT
        #######################


        # do not update, just change vals
        # it will trigger the rerender of the barplot
        xs.val = 1:0.5:rand(10:30)
        ys.val = 0.5 .* sin.(xs[])

        # Example, add another graph
        barplot!(pp, ys, xs, gap = 0, color = :red, strokecolor = :black, strokewidth = 1)

        # update
        ys[] = ys[]
    end

    # connect `update_plot` so that it is called whenever the DataFrame changes
    Makie.Observables.onany(update_plot, df_observable)

    # then call it once manually with the first dataFrame
    # contents so we prepopulate all observables with correct values
    update_plot(df_observable[])

    # in the last step we plot into our `pp` ParallelPlot object, which means
    # that our new plot is just made out of two simpler recipes layered on
    # top of each other
    barplot!(pp, xs, ys, gap = 0, color = :gray85, strokecolor = :black, strokewidth = 1)

    # lastly we return the new ParallelPlot
    pp
end




##### Using example of StockValue https://docs.makie.org/v0.21/explanations/recipes#Example:-Stock-Chart
##### TODO: THIS PART IS FOR EXAMPLE USE ONLY; DELETE BEFORE MERGE!



export StockValue
struct StockValue{T<:Real}
    open::T
    close::T
    high::T
    low::T
end

@recipe(StockChart) do scene
    Attributes(
        downcolor = :red,
        upcolor = :green,
    )
end


function Makie.plot!(sc::StockChart{<:Tuple{AbstractVector{<:Real}, AbstractVector{<:StockValue}}})

    # our first argument is an observable of parametric type AbstractVector{<:Real}
    times = sc[1]
    # our second argument is an observable of parametric type AbstractVector{<:StockValue}}
    stockvalues = sc[2]

    # we predefine a couple of observables for the linesegments
    # and barplots we need to draw
    # this is necessary because in Makie we want every recipe to be interactively updateable
    # and therefore need to connect the observable machinery to do so
    linesegs = Observable(Point2f0[])
    bar_froms = Observable(Float32[])
    bar_tos = Observable(Float32[])
    colors = Observable(Bool[])

    # this helper function will update our observables
    # whenever `times` or `stockvalues` change
    function update_plot(times, stockvalues)
        colors[]

        # clear the vectors inside the observables
        empty!(linesegs[])
        empty!(bar_froms[])
        empty!(bar_tos[])
        empty!(colors[])

        # then refill them with our updated values
        for (t, s) in zip(times, stockvalues)
            push!(linesegs[], Point2f0(t, s.low))
            push!(linesegs[], Point2f0(t, s.high))
            push!(bar_froms[], s.open)
            push!(bar_tos[], s.close)
        end
        append!(colors[], [x.close > x.open for x in stockvalues])
        colors[] = colors[]
    end

    # connect `update_plot` so that it is called whenever `times`
    # or `stockvalues` change
    Makie.Observables.onany(update_plot, times, stockvalues)

    # then call it once manually with the first `times` and `stockvalues`
    # contents so we prepopulate all observables with correct values
    update_plot(times[], stockvalues[])

    # for the colors we just use a vector of booleans or 0s and 1s, which are
    # colored according to a 2-element colormap
    # we build this colormap out of our `downcolor` and `upcolor`
    # we give the observable element type `Any` so it will not error when we change
    # a color from a symbol like :red to a different type like RGBf(1, 0, 1)
    colormap = Observable{Any}()
    map!(colormap, sc.downcolor, sc.upcolor) do dc, uc
        [dc, uc]
    end

    # in the last step we plot into our `sc` StockChart object, which means
    # that our new plot is just made out of two simpler recipes layered on
    # top of each other
    linesegments!(sc, linesegs, color = colors, colormap = colormap)
    barplot!(sc, times, bar_froms, fillto = bar_tos, color = colors, strokewidth = 0, colormap = colormap)

    # lastly we return the new StockChart
    sc
end









end