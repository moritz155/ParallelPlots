# ParallelPlots

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://moritz155.github.io/ParallelPlots.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://moritz155.github.io/ParallelPlots.jl/dev/)
[![Build Status](https://github.com/moritz155/ParallelPlots.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/moritz155/ParallelPlots.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/moritz155/ParallelPlots.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/moritz155/ParallelPlots.jl)

## General
This Project is for the TU-Berlin Course "Julia Programming for Machine Learning"
Please make sure, that Julia `1.10` is used!

_It was created with PkgTemplates.jl_

## Getting Started

### Install & Dependencies
Please refer to this [Link](https://adrianhill.de/julia-ml-course/lectures/E1_Installation.html) for Installation of Julia

You need to install differente packages.
1. Open Julia with `julia` in your command prompt
2. open the package manager with `]`
<br> you should now see  
3. Add the following modules:
   1. `add CairoMakie`
   2. `add DataFrames`
   3. `add Random`

### Usage
you can create a plot with the following command
`create_parallel_coordinates_plot(data::DataFrame)`

you can call the function with the following parameter
1. **data**<br>
Dataframe: Where each Column will be a Dataset on the X-Axis
2. **normalize**<br>
Boolean: If Data should be normalized


### Working on this Package
- Adding Dependencies
  - `activate /path/to/package` or `activate .` when in package
  - `add DepName`
- Tests
  - f

