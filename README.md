# ParallelPlots

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://moritz155.github.io/ParallelPlots.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://moritz155.github.io/ParallelPlots.jl/dev/)
[![Build Status](https://github.com/moritz155/ParallelPlots/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/moritz155/ParallelPlots/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/moritz155/ParallelPlots/branch/main/graph/badge.svg)](https://codecov.io/gh/moritz155/ParallelPlots.jl)

## General
This Project is for the TU-Berlin Course "Julia Programming for Machine Learning"<br>
Please make sure, that Julia `1.10` is used!

This Module will return you a nice Scene you can use to display your Data with [Parallel Coordinates](https://en.wikipedia.org/wiki/Parallel_coordinates)<br>
<img src="test/parallel_coordinates_plot.png" width="300" />

_This Module was created with PkgTemplates.jl_

## Getting Started

### Install Dependencies & Use Package
Please refer to this [Link](https://adrianhill.de/julia-ml-course/lectures/E1_Installation.html) for Installation of Julia

You need to use the package (1-3) and install the dependencies (4-5)
1. Open Julia with `julia` in your command prompt
2. Open the package manager with `]`
3. Using our Package
    * `activate /path/to/package` <br>
      or<br>
      `activate .` when Julia was opened with command prompt already in package path

    * _you will then see: `(ParallelPlots) pkg>`_
4. go back to `julia>` by pressing `CMD`+`C`
5. `Import ParallelPlots` to download Dependencies and use the Package from Command Line

### Usage
#### Available Parameter

| Parameter                                                          | Default                                         | Description                                                                      |
|--------------------------------------------------------------------|-------------------------------------------------|----------------------------------------------------------------------------------|
| normalize::Bool                                                    | false                                           |                                                                                  |
| custom_colors::[Strings]                                           | [:red, :yellow, :green, :purple, :black, :pink] |                                                                                  |
| colormap::[viridis,magma,plasma,inferno,cividis,mako,rocket,turbo] | :viridis                                        |                                                                                  |
| color_feature::Number                                              | 1                                               |                                                                                  |
| title::String                                                      | ""                                              | The Title of The Figure                                                          |
| ax_label ::[String]                                                | nothing                                         | Add your own Axis labels, just use the exact amount of labes as you have axis ;) |


#### Examples
```
julia> using ParallelPlots
julia> parallelplot(DataFrame(height=160:180,weight=60:80,age=20:40))
```
```
# If you want to normalize the Data, you can add the value normalized=true, default is false
julia> parallelplot(DataFrame(height=160:180,weight=reverse(60:80),age=20:40),normalize=true)
```
```
# If you want to set the size of the plot (default width:800, height:600)
julia> parallelplot( DataFrame(height=160:180,weight=60:80,age=20:40), figure = (resolution = (300, 300),) )
```
```
# You can update as well the Graph with Observables
julia> df_observable = Observable(DataFrame(height=160:180,weight=60:80,age=20:40))
julia> fig, ax, sc = parallelplot(df_observable)
```
```
# If you want to add a Title for the Figure, sure you can!
julia> parallelplot(DataFrame(height=160:180,weight=reverse(60:80),age=20:40),title="My Title")
```
```
# If you want to specify the axis labels, make sure to use the same number of labels as you have axis!
julia> parallelplot(DataFrame(height=160:180,weight=reverse(60:80),age=20:40), ax_label=["Height","Weight","Age"])
```

Please read the [Docs](/docs/build/index.html) for further Information

### Working on this Package / Cheatsheet
1. Using the Package
   * `activate /path/to/package` <br>
   or<br>
   `activate .` when Julia was opened with command prompt already in package path
 
   * _you will then see: `(ParallelPlots) pkg>`_

2. Running commands
   * Adding external Dependencies
     - `add DepName`
   * Run Tests to check if Package is still working as intended 
     - `test`
   * Build
     - `build`
   * Precompile
     - `precompile`


#### Create Docs
* move to `./docs` folder with command line
* run `julia --project make.jl`

### Using CairoMakie

CairoMakie is a highest-quality and efficient 2D plotting backend for publications. It uses Cairo.jl to draw vector graphics to SVG,PNG and PDF

#### Activate CairoMakie

Activate the backend by using CairoMakie and calling CairoMakie.activate!(type = "png") or CairoMakie.activate!(type = "svg")

### Overview

This module provides a way to visualize data using parallel coordinates plots. A parallel coordinates plot is a common way of visualizing multivariate data by drawing lines connecting data points across parallel axes.

The key output is a **Scene**, which is a CairoMakie object that holds the graphical rendering of your plot. The `Scene` serves as the container for all visual components, including axes and plotted lines.