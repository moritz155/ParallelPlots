module ParallelPlots

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
- Julia version: 1.10.5

# Constructors
```julia
ParallelPlot(data::DataFrame; normalize::Bool=false, scene_width::Integer=800, scene_height::Integer=600)
```

# Arguments

- `data::DataFrame`:
- `normalize::Bool`:
- `scene_width::Integer`:
- `scene_height::Integer`:

# Examples
```@example
julia> using ParallelPlots
julia> parallelplot(DataFrame(height=160:180,weight=60:80,age=20:40))

# If you want to normalize the Data, you can add the value normalized=true, default is false
julia> parallelplot(DataFrame(height=160:180,weight=reverse(60:80),age=20:40),normalize=true)

# If you want to set the size of the plot
julia> parallelplot( DataFrame(height=160:180,weight=60:80,age=20:40), figure = (resolution = (300, 300),) )

# You can update as well the Graph with Observables

julia> df_observable = Observable(DataFrame(height=160:180,weight=60:80,age=20:40))
julia> fig, ax, sc = parallelplot(df_observable)
```

"""
@recipe(ParallelPlot, df) do scene
    Attributes(
    # size, normalize attributes
        normalize = false
    )
end


function Makie.plot!(pp::ParallelPlot{<:Tuple{<:DataFrame}})

    # our first parameter is the DataFrame-Observable
    df_observable  = pp[1]

    # this helper function will update our observables
    # whenever df_observable change
    function update_plot(data)

        # check the given DataFrame
        input_check(data)

        # Normalize the data if required
        if pp.normalize[] # TODO: what happens when the parameter is an observeable to? will it update?
            data = normalize_DF(data)
        end

        # Parse the DataFrame into a list of arrays
        parsed_data = [data[!, col] for col in names(data)]

        # Compute limits for each column
        limits = [(minimum(col), maximum(col)) for col in parsed_data]

        let
            # get the scene
            fig = current_figure()
            scene = fig.scene

            # reset scene
            empty!(fig.scene)
            trim!(fig.layout)
            empty!(fig.content)
            fig.current_axis[] = nothing

            # get the widht and height
            scene_width,scene_height = size(scene)



            numberFeatures = length(parsed_data) # Number of features, equivalent to the X Axis
            sampleSize = size(data, 1)       # Number of samples, equivalent to the Y Axis

            # Plot dimensions
            width = scene_width[] * 0.75  # 75% of scene width
            height = scene_height[] * 0.75  # 75% of scene width
            offset = min(scene_width[], scene_height[]) * 0.15  # 15% of scene dimensions

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

    # connect `update_plot` so that it is called whenever the DataFrame changes
    Makie.Observables.onany(update_plot, df_observable)

    # then call it once manually with the first dataFrame
    # contents so we prepopulate all observables with correct values
    update_plot(df_observable[])

    # some Random Plot, else we get an error
    lines!(pp, 1:9, iseven.(1:9) .- 0; color = :tomato)

    # lastly we return the new ParallelPlot
    pp
end



end