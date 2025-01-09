using Random
using DataFrames

#generate Data
function create_person_df()

    Random.seed!(10)
    n_samples = 10
    df = DataFrame(
        height=randn(n_samples),
        weight=randn(n_samples),
        age=rand(0:70, n_samples), # random numbers between 0 and 70
        income=randn(n_samples),
        education_years=rand(0:25, n_samples) # random numbers between 0 and 70
    )

    return df
end