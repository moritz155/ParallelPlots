module ParallelPlots

    export create_parallel_coordinates_plot

using CairoMakie
using DataFrames


function normalize_DF(data::DataFrame)
    normalized_data = copy(data)
    for col in names(data)
        normalized_data[!, col] = (data[!, col] .- minimum(data[!, col])) ./
                                  (maximum(data[!, col]) - minimum(data[!, col]))
    end

    return normalized_data
end







"""
    create_parallel_coordinates_plot(data::DataFrame, normalize::Bool)

- Julia version: 1.10.5

# Constructors
```julia
ParallelPlots.create_parallel_coordinates_plot(data::DataFrame; normalize::Bool=false)
```

# Arguments

- `data::DataFrame`:
- `normalize::Bool`:

# Examples
```@example
julia> ParallelPlots.create_parallel_coordinates_plot(DataFrame(height=160:180,weight=60:80,age=20:40))

# If you want to normalize the Data, you can add the value normalized=true, default is false
julia> ParallelPlots.create_parallel_coordinates_plot(DataFrame(height=160:180,weight=reverse(60:80),age=20:40),normalize=true)


```


"""
function create_parallel_coordinates_plot(data::DataFrame; normalize::Bool=false)

    # Normalize the data if required
    if normalize
        data = normalize_DF(data)
    end

    # Parse the DataFrame into a list of arrays
    parsed_data = [data[!, col] for col in names(data)]

    # Compute limits for each column
    limits = [(minimum(col), maximum(col)) for col in parsed_data]

    let
        scene = Scene(camera=campixel!)

        numberFeatures = length(parsed_data) # Number of features, equivalent to the X Axis
        sampleSize = size(data, 1)       # Number of samples, equivalent to the Y Axis

        # Plot dimensions
        width = 6000
        height = 400
        offset = 100

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
end