using Random
using DataFrames

#generate Data
function create_person_df(n_samples = 10)

    Random.seed!(10)
    df = DataFrame(
        height=rand(150:180, n_samples),
        weight=randn(n_samples),
        age=rand(0:70, n_samples), # random numbers between 0 and 70
        income=randn(n_samples),
        education_years=rand(0:25, n_samples) # random numbers between 0 and 70
    )

    return df
end
function create_car_df(n_samples = 10)

    Random.seed!(10)
    df = DataFrame(
        horsepower=rand(60:300, n_samples),
        weight=rand(90:2000, n_samples),
        age=rand(0:70, n_samples)
    )

    return df
end
