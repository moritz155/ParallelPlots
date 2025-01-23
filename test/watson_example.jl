using DrWatson
using DataFrames
using ParallelPlots

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
    for d in dicts
        results = exec_simulation(d, results)
    end
    return results
end

function prepare_simulation()
    initial_velocities = 40.0:10.0:50.0 |> collect
    launch_angles = 0:45:90 |> collect
    air_resistances = 0.0:0.5:1.0 |> collect
    gravities = 9.0:0.5:10.0 |> collect
    display(initial_velocities)
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

# Main execution
function main()
    results = projectile_simulation()
    println("Total parameter combinations: ", nrow(results))
    println("\nSample results:")
    display(first(results, 5))
    fig = parallelplot(results, color_feature=5)
    save("projectile_simulation.png", fig)
end

# Run the simulation
main()