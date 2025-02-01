using ParallelPlots:parallelplot
using Test: @test, @testset
using CairoMakie: save
using MLDatasets
using DataFrames

@testset "default call iris" begin

    # Generate sample multivariate data
    ENV["DATADEPS_ALWAYS_ACCEPT"] = true
    iris = Iris()

    df = iris.dataframe

    # convert Category to Number
    mapping = Dict("Iris-setosa"=>1, "Iris-virginica"=>2, "Iris-versicolor"=>3)

    df[!,"class"] = [mapping[v] for v in df[!,"class"]]

    #display
    fig = parallelplot(df,
        figure = (size = (1300, 700),),
        curve=true,
        title="Iris - setosa=1, virginica=2, versicolor=3",
        color_feature="class",
        feature_selection=["sepallength","sepalwidth","petallength","petalwidth"],
        feature_labels=["Sepal Length","Sepal Width","Petal Length","Petal Width"],
    )

    @test fig !== nothing

    save("parallel_coordinates_plot_iris.png", fig)

end
