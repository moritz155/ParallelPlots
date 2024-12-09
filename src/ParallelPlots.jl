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

    # normalize when user parameter normalize == true
    if normalize
        data = normalize_DF(data)
    end

    # create figure and axis
    fig = Figure(figsize=(12, 6))
    ax = Axis(fig[1, 1],
        xlabel="Dimensions",
        ylabel=normalize ? "Normalized Value" : "Value",
        title="Parallel Coordinates Plot"
    )

    # plotting
    columns = names(data)
    n_cols = length(columns)

    for row in 1:nrow(data)
        line_points = Point2f[]
        for (i, col) in enumerate(columns)
            push!(line_points, Point2f(i, data[row, col]))
        end
        lines!(ax, line_points, color=(:blue, 0.1))
    end

    # set x-ticks to column names
    ax.xticks = (1:n_cols, columns)

    # Add horizontal grid lines
    hlines!(ax, [0, 1], color=:lightgray, linestyle=:dot)

    return fig
end

end
