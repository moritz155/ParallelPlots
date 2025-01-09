using ParallelPlots
using Test

using Random
using JLD
using DataFrames

include("test_argument_errors.jl")
include("test_call_with_normalize.jl")
include("test_custom_dimensions.jl")
include("test_default_call.jl")