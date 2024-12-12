# ParallelPlots

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://moritz155.github.io/ParallelPlots.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://moritz155.github.io/ParallelPlots.jl/dev/)
[![Build Status](https://github.com/moritz155/ParallelPlots/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/moritz155/ParallelPlots/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/moritz155/ParallelPlots/branch/main/graph/badge.svg)](https://codecov.io/gh/moritz155/ParallelPlots.jl)

## General
This Project is for the TU-Berlin Course "Julia Programming for Machine Learning"
Please make sure, that Julia `1.10` is used!

_It was created with PkgTemplates.jl_

## Getting Started

### Install Dependencies & Use Package
Please refer to this [Link](https://adrianhill.de/julia-ml-course/lectures/E1_Installation.html) for Installation of Julia

You need use the package (1-3) and install the dependencies (4-5)
1. Open Julia with `julia` in your command prompt
2. open the package manager with `]`
3. Using our Package
    * `activate /path/to/package` <br>
      or<br>
      `activate .` when Julia was opened with command prompt already in package path

    * _you will then see: `(ParallelPlots) pkg>`_
4. go back to `julia>` by pressing `CMD`+`C`
5. `Import ParallelPlots` to download Dependencies and use the Package from Command line

### Usage
Please read the [Docs](/docs/build/index.html)

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

``

