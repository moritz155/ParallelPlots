using ParallelPlots: parallelplot
using CairoMakie:Observable, record, save # for Record Video
using Test: @testset

@testset "Use a Observable DataFrame" begin

    # create the Data
    df_observable = Observable(create_person_df(2))
    title_observable = Observable("")
    curve_observable = Observable(true)

    # create the Plot
    fig, ax, sc = parallelplot(df_observable, title=title_observable, curve = curve_observable)
    save("pcp_initialized.png", fig)

    # we can change a parameter and the graph will be automaticly changed
    curve_observable[] = false
    title_observable[] = "No Curve"
    save("pcp_initialized_curve_Changed.png", fig)

    # Record for Debug purpose
    record(fig, "PCP_recipe_animation.mp4", 2:60, framerate = 2) do t

        # Update Dataframe
        if(iseven(t))
            curve_observable[] = false
            title_observable[] = ""
            df_observable[] = create_person_df(5)
        else
            curve_observable[] = true
            title_observable[] = "Curved"
            df_observable[] = create_car_df(t)
        end


    end

end
