using ParallelPlots
using Test

using Random
using JLD
using DataFrames

include("test_utils.jl")

include("test_argument_errors.jl")
include("test_curved.jl")
include("test_call_with_color_feature.jl")
include("test_call_with_feature_labels.jl")
include("test_call_with_normalize.jl")
include("test_custom_dimensions.jl")
include("test_default_call.jl")
include("test_recipe_observable.jl")
include("test_lines_count.jl")