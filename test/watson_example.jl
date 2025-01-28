using DrWatson: display, @unpack, push!, first, Dict, dict_list
using DataFrames: DataFrame, nrow
using ParallelPlots: parallelplot
using CairoMakie: save

function projectile_simulation()
    dicts = prepare_simulation()
    results = DataFrame(
        initial_velocity=Float64[],
        launch_angle=Float64[],
        air_resistance=Float64[],
        gravity=Float64[],
        max_height=Float64[],
        total_distance=Float64[],
        time_of_flight=Float64[]
    )
    dicts_distint = find_minimal_distinct_params(dicts)
    for d in dicts_distint
        results = exec_simulation(d, results)
    end
    results_obs = Observable(results)

    fig = parallelplot(results_obs, curve=true, figure = (size = (1000, 600),))
    save("projectile_simulation_initial.png", fig)
    record(fig, "projectile_simulation.mp4", 1:length(dicts), framerate = 1) do t
        results_obs[] = exec_simulation(dicts[t], results)
    end
    return results
end

function prepare_simulation()
    initial_velocities = 40.0:10.0:50.0 |> collect
    launch_angles = 0:45:90 |> collect
    air_resistances = 0.0:0.5:1.0 |> collect
    gravities = 9.0:0.5:10.0 |> collect
    allparams = Dict(
        "initial_velocities" => initial_velocities,
        "launch_angles" => launch_angles,
        "air_resistances" => air_resistances,
        "gravities" => gravities,
    )
    dicts = dict_list(allparams)
    return dicts
end

function exec_simulation(d::Dict, results)
    @unpack launch_angles, initial_velocities, gravities, air_resistances = d
    # Convert angle to radians
    θ = launch_angles * π / 180

    # Calculate components
    vx0 = initial_velocities * cos(θ)
    vy0 = initial_velocities * sin(θ)

    # Analytical solution with air resistance
    time_to_peak = vy0 / (gravities + air_resistances * vy0)
    max_height = vy0 * time_to_peak - 0.5 * gravities * time_to_peak^2

    # Total flight time (approximate)
    total_time = 2 * time_to_peak

    # Horizontal distance (with air resistance approximation)
    total_distance = vx0 * total_time * (1 - air_resistances * total_time)

    # Push results
    push!(results, [
        initial_velocities,
        launch_angles,
        air_resistances,
        gravities,
        max_height,
        total_distance,
        total_time
    ])

    return results
end

function find_minimal_distinct_params(arr_of_dicts)
    # Get all unique values for each parameter
    params = keys(first(arr_of_dicts))
    param_values = Dict(
        param => unique([Float64(d[param]) for d in arr_of_dicts])  # Ensure all values are Float64
        for param in params
    )

    # Only two different values for each parameter
    minimal_values = Dict(
        param => param_values[param][1:min(2, length(param_values[param]))]
        for param in params
    )

    # Create minimal set with proper types
    result = Vector{Dict{String, Float64}}()  # Specify the exact type of the result
    push!(result, Dict(param => minimal_values[param][1] for param in params))

    for param in params
        if length(minimal_values[param]) > 1
            new_dict = copy(result[1])  # Copy the base dict
            new_dict[param] = minimal_values[param][2]  # Set the second value for the current parameter
            push!(result, new_dict)
        end
    end

    return result
end

# Main execution
function main()
    results = projectile_simulation()
    println("Total parameter combinations: ", nrow(results))
    println("\nSample results:")
    display(first(results, 5))
    fig = parallelplot(results,
        figure = (size = (1300, 700),),
        curve=true,
        color_feature="max_height",
        feature_selection=["initial_velocity","launch_angle","air_resistance","gravity","total_distance","time_of_flight"],
        feature_labels=["Initial Velocity","Launch Angle","Air Resistance","Gravity","Total Distance","Time of Flight"],
    )
    save("projectile_simulation.png", fig)
end

# Run the simulation
main()