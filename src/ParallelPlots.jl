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
julia> ParallelPlots.create_parallel_coordinates_plot(DataFrame(height=2,weight=60,age=20))
julia> ParallelPlots.create_parallel_coordinates_plot(DataFrame(height=160:180,weight=60:80,age=20:40))
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
        s = Scene(camera=campixel!)

        n = length(parsed_data) # Number of features
        k = size(data, 1)       # Number of samples

        # Plot dimensions
        width = 600
        height = 400
        offset = 100

        # Create axes
        for i in 1:n
            x = (i - 1) / (n - 1) * width
            MakieLayout.LineAxis(s, limits=limits[i],
                spinecolor=:black, labelfont="Arial",
                ticklabelfont="Arial", spinevisible=true,
                minorticks=IntervalsBetween(2),
                endpoints=Point2f0[(offset + x, offset), (offset + x, offset + height)],
                ticklabelalign=(:right, :center), labelvisible=true,
                label=names(data)[i])
        end

        # Draw lines connecting points for each row
        for i in 1:k
            values = [
                Point2f0(
                    offset + (j - 1) / (n - 1) * width,
                    (parsed_data[j][i] - limits[j][1]) / (limits[j][2] - limits[j][1]) * height + offset
                )
                for j in 1:n
            ]
            lines!(s, values, color=get(Makie.ColorSchemes.inferno, (i - 1) / (k - 1)),
                show_axis=false)
        end
        return s
    end
end
end