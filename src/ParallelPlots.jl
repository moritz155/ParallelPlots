module ParallelPlots

using CairoMakie
using DataFrames
using Interpolations


function normalize_DF(data::DataFrame)
	for col in names(data)
		data[!, col] = (data[!, col] .- minimum(data[!, col])) ./
					   (maximum(data[!, col]) - minimum(data[!, col]))
	end

	return data
end


function input_data_check(data::DataFrame)
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
ParallelPlot(data::DataFrame; normalize::Bool=false)
```

# Arguments

- `data::DataFrame`:
- `normalize::Bool`:
- `custom_colors::[String]`:
- `title::String`:
- `ax_label::[String]`:
- `curve::Bool`:

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

# If you want to add a Title for the Figure, sure you can!
julia> parallelplot(DataFrame(height=160:180,weight=reverse(60:80),age=20:40),title="My Title")

# If you want to specify the axis labels, make sure to use the same number of labels as you have axis!
julia> parallelplot(DataFrame(height=160:180,weight=reverse(60:80),age=20:40), ax_label=["Height","Weight","Age"])
```

"""
@recipe(ParallelPlot, df) do scene
	Attributes(
		# additional attributes
		normalize = false,
		custom_colors = [:red, :yellow, :green, :purple, :black, :pink, :brown, :orange, :cyan, :blue],
		colormap = :viridis,  # options: viridis,magma,plasma,inferno,cividis,mako,rocket,turbo
		color_feature = 1,    # Which feature to use for coloring (column index)
		title = "", # Title of the Figure
		ax_label = nothing,
		curve = false, # If Lines should be curved between the axis. Default false
	)
end


function Makie.plot!(pp::ParallelPlot{<:Tuple{<:DataFrame}})

	# our first parameter is the DataFrame-Observable
	df_observable = pp[1]


	# this helper function will update our observables
	# whenever df_observable change
	function update_plot(data)

		# check the given DataFrame
		input_data_check(data) # TODO: throw Error when new Data is invalid

		# Normalize the data if required
		if pp.normalize[] # TODO: what happens when the parameter is an observeable to? will it update?
			data = normalize_DF(data)
		end

		# Parse the DataFrame into a list of arrays
		parsed_data = [data[!, col] for col in names(data)]

		# Compute limits for each column
		limits = [(minimum(col), maximum(col)) for col in parsed_data]

		# Get the Fig and empty it, so its nice and clean for the next itaration
		fig = current_figure()
		empty!(fig)
		scene = fig.scene

		# get the parent scene dimensions
		scene_width, scene_height = size(scene)

		numberFeatures = length(parsed_data) # Number of features, equivalent to the X Axis
		sampleSize = size(data, 1)       # Number of samples, equivalent to the Y Axis

		# Plot dimensions
		width = scene_width[] * 0.75  # 75% of scene width
		height = scene_height[] * 0.75  # 75% of scene width
		offset = min(scene_width[], scene_height[]) * 0.15  # 15% of scene dimensions

		# Create Overlaying, invisible Axis
		# in here, all the lines will be stored
		ax = Axis(fig[1, 1], title = pp.title)

		# make the Axis invisible
		hidespines!(ax)
		hidedecorations!(ax)

		# # # # # # # # # #
		# # # L I N E # # #
		# # # # # # # # # #

		# set the Color of the Line
		color_col = pp.color_feature[]
        color_values = parsed_data[color_col]  # Get all values for selected feature
        color_min = minimum(color_values)
        color_max = maximum(color_values)

		# Draw lines connecting points for each row
		for i in 1:sampleSize
				# If Curved, Interpolate
				if(pp.curve[] == false)
    				# calcuating the point respectivly of the width and height in the Screen
    				dataPoints = [
						Point2f(
							# calculates which feature the Point should be on
							offset + (j - 1) / (numberFeatures - 1) * width,
							# calculates the Y axis value
							(parsed_data[j][i] - limits[j][1]) / (limits[j][2] - limits[j][1]) * height + offset,
						)
						# iterates through the Features/Axis and creates for each feature the samplePoint (above)
						for j in 1:numberFeatures
					]
				else
					# Interpolate
					dataPoints = []

					# iterates through the Features/Axis
					# Start at 2, bc we check the precious axis/feature f
					for j in 2:numberFeatures
						last_x = offset + ((j-1) - 1) / (numberFeatures - 1) * width
						current_x = offset + ((j) - 1) / (numberFeatures - 1) * width

						last_y = (parsed_data[j-1][i] - limits[j-1][1]) / (limits[j-1][2] - limits[j-1][1]) * height + offset
						current_y = (parsed_data[j][i] - limits[j][1]) / (limits[j][2] - limits[j][1]) * height + offset

						# interpolate points between the current and the last point
						for x in range(last_x, current_x, step = ( (current_x-last_x) / 30 ) )
							# calculate the interpolated Y Value
							y = interpolate(last_x, current_x, last_y, current_y, x)
							# create a new Point
							push!(dataPoints, Point2f(x,y))
						end
					end

				end

			# Color
			color_idx = if length(pp.custom_colors[]) < i  # in case too little custom colors are given, use the first color
				1
				@warn "too little Colors("*string(length(pp.custom_colors[]))*") are available for the Lines("*string(i)*"). You can set more with the 'custom_colors' attribute"
			else
				i
			end
            color_val = color_values[i]

			# Create the Line
            lines!(scene, dataPoints,
                color = color_val,
                colormap = pp.colormap[],
                colorrange = (color_min, color_max)
            )
			# lines!(scene, dataPoints, color = pp.custom_colors[][color_idx])
		end

		# # # # # # # # # #
		# # # A X I S # # #
		# # # # # # # # # #

		# set the axis labels, if available
		# check if ax_label has the same amount of labels as axis
		label = if isnothing(pp.ax_label[])  # check if ax_label is set
			names(data) # ax_label is not set, use the DB label
		else
			@assert length(pp.ax_label[]) === length(names(data)) "'ax_label' is set but has not the same amount of labels("*string(length(pp.ax_label[]))*") as axis("*string(length(names(data)))*")"
			pp.ax_label[]
		end

		# Create the new Parallel Axis
		for i in 1:numberFeatures
			# x will be used to split the Scene for each feature
			x = numberFeatures==1 ? width/2 : (i - 1) / (numberFeatures - 1) * width

			# get default
			def = Makie.default_attribute_values(Axis, nothing)

			# LineAxis will create one Axis Vertical, for each Feature one Axis
			axis = Makie.LineAxis(
				scene,
				limits = limits[i],
				dim_convert = Makie.NoDimConversion(),
                # the lowest and highest point to maximize the Axis from Bottom to Top
				endpoints = Point2f[(offset + x, offset), (offset + x, offset + height)],
				tickformat = Makie.automatic,
				spinecolor = :black,
				spinevisible = true,
				labelfont = def[:ylabelfont],
				labelrotation = def[:ylabelrotation],
				labelvisible = false,
				ticklabelfont = def[:yticklabelfont],
				ticklabelsize = def[:yticklabelsize],
				minorticks = def[:yminorticks],
			)

			# Create Lable for the Axis
			axis_title!(
				scene,
				axis.attributes.endpoints,
				string(label[i]);
				titlegap = def[:titlegap],
			)
		end


    end

	# connect `update_plot` so that it is called whenever the DataFrame changes
	Makie.Observables.onany(update_plot, df_observable)

	# then call it once manually with the first dataFrame
	# contents so we prepopulate all observables with correct values
	update_plot(df_observable[])

	# lastly we return the new ParallelPlot
	pp
end

function axis_title!(
    topscene,
    endpoints::Observable,
    title::String;
    titlegap = Observable(4.0f0),
)
    titlepos = lift(endpoints, titlegap) do a, titlegap
        x = a[1][1]
        y = a[2][2] + titlegap
        Point2(x, y)
    end

    titlet = text!(
        topscene,
        title,
        position = titlepos,
        #visible =
        #fontsize =
        align = (:center, :bottom),
        #font =
        #color =
        space = :data,
        #show_axis=false,
        inspectable = false,
    )
end

# Interpolates between the x and y point
# Inputs a x value
# Outputs a y value
function interpolate(last_x::Float64, current_x::Float64, last_y::Float64, current_y::Float64, x::Float64)

	# calculate the % of Pi related to x between two x points
	x_pi = (x - last_x)/(current_x - last_x) * π

	# calculate the % difference between both x Values
	y_scale = 0.5-0.5*cos(x_pi) #between 0-1

	return last_y + y_scale * (current_y - last_y)

end

end