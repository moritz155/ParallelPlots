using DrWatson
using DataFrames
using ParallelPlots
function projectile_simulation()
    # Define parameter values explicitly
    initial_velocities = 40.0:10.0:50.0 |> collect
    launch_angles = 0:45:90 |> collect
    air_resistances = 0.0:0.5:1.0 |> collect
    gravities = 9.0:0.5:10.0 |> collect
    
    # Generate parameter combinations
    parameter_combinations = vec(collect(Iterators.product(
        initial_velocities, 
        launch_angles, 
        air_resistances, 
        gravities
    )))
    
    # Prepare results DataFrame
    results = DataFrame(
        initial_velocity = Float64[],
        launch_angle = Float64[],
        air_resistance = Float64[],
        gravity = Float64[],
        max_height = Float64[],
        total_distance = Float64[],
        time_of_flight = Float64[]
    )
    
    # Simulation of projectile motion
    for (v0, θ_deg, k, g) in parameter_combinations
        # Convert angle to radians
        θ = θ_deg * π/180
        
        # Calculate components
        vx0 = v0 * cos(θ)
        vy0 = v0 * sin(θ)
        
        # Analytical solution with air resistance
        time_to_peak = vy0 / (g + k * vy0)
        max_height = vy0 * time_to_peak - 0.5 * g * time_to_peak^2
        
        # Total flight time (approximate)
        total_time = 2 * time_to_peak
        
        # Horizontal distance (with air resistance approximation)
        total_distance = vx0 * total_time * (1 - k * total_time)
        
        # Push results
        push!(results, [
            v0, 
            θ_deg,  
            k, 
            g, 
            max_height, 
            total_distance, 
            total_time
        ])
    end
    
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