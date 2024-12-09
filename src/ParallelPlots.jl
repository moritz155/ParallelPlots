module ParallelPlots
using CairoMakie
using DataFrames
using Random

# Generate sample multivariate data
Random.seed!(10)
n_samples = 10
df = DataFrame(
    height=randn(n_samples),
    weight=randn(n_samples),
    age=rand(0:70, n_samples), # random numbers between 0 and 70
    income=randn(n_samples),
    education_years=rand(0:25, n_samples) # random numbers between 0 and 70
)
function normalize(data::DataFrame)
    normalized_data = copy(data)
    for col in names(data)
        normalized_data[!, col] = (data[!, col] .- minimum(data[!, col])) ./
                                  (maximum(data[!, col]) - minimum(data[!, col]))
    end
end
# create parallel coordinates plot
function create_parallel_coordinates_plot(data::DataFrame)
    # normalized_data = normalize(data)
    normalized_data = data
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

    for row in 1:nrow(normalized_data)
        line_points = Point2f[]
        for (i, col) in enumerate(columns)
            push!(line_points, Point2f(i, normalized_data[row, col]))
        end
        lines!(ax, line_points, color=(:blue, 0.1))
    end

    # set x-ticks to column names
    ax.xticks = (1:n_cols, columns)

    # Add horizontal grid lines
    hlines!(ax, [0, 1], color=:lightgray, linestyle=:dot)

    return fig
end

#display
fig = create_parallel_coordinates_plot(df)
save("parallel_coordinates_plot.png", fig)
display(fig)

end
