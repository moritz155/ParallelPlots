module ParallelPlots

    export create_parallel_coordinates_plot

using CairoMakie
using DataFrames


function normalize(data::DataFrame)
    normalized_data = copy(data)
    for col in names(data)
        normalized_data[!, col] = (data[!, col] .- minimum(data[!, col])) ./
                                  (maximum(data[!, col]) - minimum(data[!, col]))
    end
end
# create parallel coordinates plot
function create_parallel_coordinates_plot(data::DataFrame; normalize=false)

    # normalize when user parameter normalize == true
    if normalize
        data = normalize(data)
    end

    # create figure and axis
    fig = Figure(figsize=(12, 6))
    ax = Axis(fig[1, 1],
        xlabel="Dimensions",
        ylabel="Normalized Value",
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
