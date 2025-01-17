#include("test_utils.jl")
using ParallelPlots
using CairoMakie # for Record Video
using Test

using DataFrames

@testset "Use a Observable DataFrame" begin

    # create the Data
    df_observable = Observable(create_person_df(2))
    normalize_observable = Observable(true)

    # create the Plot
    fig, ax, sc = parallelplot(df_observable, normalize=normalize_observable)
    save("pcp_initialized.png", fig)

    # Record for Debug purpose
    record(fig, "PCP_recipe_animation.mp4", 2:60, framerate = 2) do t

        # Update Dataframe
        if(iseven(t))
            df_observable[] = create_person_df(5)
            normalize_observable[] = false
        else
            df_observable[] = create_car_df(t)
            normalize_observable[] = true
        end


    end

    # TODO: Write Testcases
    # e.g. Test the Size for Changes
    # w,h = size(scene)

end
