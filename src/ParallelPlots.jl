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
- `color_feature::String || nothing`: select, which axis/feature should be used for the coloring (e.g. 'weight') (default: last)
- `title::String`:
- `feature_labels::String`:
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
julia> parallelplot(DataFrame(height=160:180,weight=reverse(60:80),age=20:40), feature_labels=["Height","Weight","Age"])

# Adjust Color and and feature
parallelplot(df,
		# You choose which axis/feature should be in charge for the coloring
        color_feature="weight",
        # you can as well select, which Axis should be shown
        feature_selection=["height","age","income"],
        # and label them as you like
        feature_labels=["Height","Age","Income"],
        # you can change the ColorMap (https://docs.makie.org/dev/explanations/colors)
        colormap=:thermal,
        # ...and can choose to display the color legend.
        # If this Attribute is not set,
        # it will only show the ColorBar, when the color feature is not in the selected feature
        show_color_legend = true
    )
```

"""
@recipe(ParallelPlot, df) do scene
	Attributes(
		# additional attributes
		normalize = false,
		title = "", # Title of the Figure
		colormap = :viridis,  # https://docs.makie.org/dev/explanations/colors
		color_feature = nothing,    # Which feature to use for coloring (column name)
		feature_labels = nothing, # the Label of each feature as List of Strings
		feature_selection = nothing, # which features should be shown, default: nothing --> show all features
		curve = false, # If Lines should be curved between the axis. Default false
		# if colorlegend/ ColorBar should be shown. Default: when color_feature is not visible, true, else false
		show_color_legend = nothing
	)
end


function Makie.plot!(pp::ParallelPlot{<:Tuple{<:DataFrame}})

	# our first parameter is the DataFrame-Observable
	df_observable = pp[1]


	# this helper function will update our observables
	# whenever df_observable change
	function update_plot(data)

		# check the given DataFrame
		input_data_check(data)

		# Normalize the data if required
		if pp.normalize[]
			data = normalize_DF(data)
		end

		# Get the Fig and empty it, so its nice and clean for the next itaration
		fig = current_figure()
		empty!(fig)
		scene = fig.scene

		# get the parent scene dimensions
		scene_width, scene_height = size(scene)

		# Create Overlaying, invisible Axis
		# set hight to fit Label
		ax = Axis(fig[1, 1],
			title = pp.title,
			height=(scene_height-
				(
					2*Makie.default_attribute_values(Axis, nothing)[:titlegap]+
					Makie.default_attribute_values(Axis, nothing)[:titlesize]
				)
			)
		)

		# make the Axis invisible
		hidespines!(ax)
		hidedecorations!(ax)

		# set the Color of the Color Feature
		color_col = if isnothing(pp.color_feature[])  # check if colorFeature is set
			# Its not Set, use the last feature
			# therefore we need to check if user selected features
			if !isnothing(pp.feature_selection[])
				# use the last seleted feature as color_col
				@assert pp.feature_selection[][end] in names(data) "Feature Selection ("*pp.feature_selection[][end]*") is not available in DataFrame ("*string(names(data))*")"
				pp.feature_selection[][end]
			else
				names(data)[end] # no columns selected, use the last one
			end

		else
			# check if name is available
			@assert pp.color_feature[] in names(data) "Color Feature ("*pp.color_feature[]*") is not available in DataFrame ("*string(names(data))*")"
			pp.color_feature[]
		end
        color_values = data[:,color_col]  # Get all values for selected feature
        color_min = minimum(color_values)
        color_max = maximum(color_values)

		# Select the Columns, the user wants to show (feature_selection)
		if !isnothing(pp.feature_selection[])
			# check if all given selections are in the DF
			for selection in pp.feature_selection[]
				println(selection)
				@assert selection in names(data) "Feature Selection ("*selection*") is not available in DataFrame ("*string(names(data))*")"
			end
			data = data[:, pp.feature_selection[]]
		end

		# set the axis labels, if available
		# check if ax_label has the same amount of labels as axis
		labels = if isnothing(pp.feature_labels[])  # check if ax_label is set
			names(data) # ax_label is not set, use the DB label
		else
			@assert length(pp.feature_labels[]) === length(names(data)) "'feature_labels' is set but has not the same amount of labels("*string(length(pp.feature_labels[]))*") as axis("*string(length(names(data)))*")"
			pp.feature_labels[]
		end

		# Plot dimensions
		width = scene_width[] * 0.80  #% of scene width
		height = scene_height[] * 0.80  #% of scene width
		offset = min(scene_width[], scene_height[]) * 0.10  #% of scene dimensions

		# COLOR FEATURE
		# If set, use the setted value
		# Show, when color_feature is not in feature_selection
		show_color_legend = if pp.show_color_legend[] == true
			true
		elseif pp.show_color_legend[] == false
			false
		elseif !isnothing(pp.feature_selection[]) && !(pp.color_feature[] in pp.feature_selection[])
			true
		else
			false
		end

		# set the Color Bar on the side if it should be set
		if show_color_legend[]
			# update the width, combined -> 75%
			bar_width = scene_width[] * 0.05 #% of scene width
			width = scene_width[] * 0.75 #% of scene width

			Colorbar(
				fig[1, 2],
				limits = (color_min, color_max),
				colormap = pp.colormap[],
				height = height,
				width = bar_width,

				label = color_col
			)
		end


		# Parse the DataFrame into a list of arrays
		parsed_data = [data[!, col] for col in names(data)]

		# Compute limits for each column
		limits = [(minimum(col), maximum(col)) for col in parsed_data]

		numberFeatures = length(parsed_data) # Number of features, equivalent to the X Axis
		sampleSize = size(data, 1)       # Number of samples, equivalent to the Y Axis

		# # # # # # # # # #
		# # # L I N E # # #
		# # # # # # # # # #

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
            color_val = color_values[i]

			# Create the Line
            lines!(scene, dataPoints,
                color = color_val,
                colormap = pp.colormap[],
                colorrange = (color_min, color_max)
            )
		end

		# # # # # # # # # #
		# # # A X I S # # #
		# # # # # # # # # #



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
				string(labels[i]);
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