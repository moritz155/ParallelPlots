# ParallelPlots

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://moritz155.github.io/ParallelPlots/dev/)
[![Build Status](https://github.com/moritz155/ParallelPlots/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/moritz155/ParallelPlots/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/moritz155/ParallelPlots/branch/main/graph/badge.svg)](https://codecov.io/gh/moritz155/ParallelPlots)

## General
This Project is for the TU-Berlin Course "Julia Programming for Machine Learning"<br>
Please make sure, that Julia `1.10` is used!

This Module will return a nice Makie Plot you can use to display your Data using a [Parallel Coordinate Plot](https://en.wikipedia.org/wiki/Parallel_coordinates)<br>. 
<img src="test/projectile_simulation.png" width="500" />

The package is heavily based on [Makie](https://docs.makie.org/). This is a data visualization tool that can be used to display various plots such as interactive 3d plots, static vector graphics or plots in a browser. Makie offers four backends that can be chosen from. This project uses [CairoMakie](https://docs.makie.org/stable/explanations/backends/cairomakie#CairoMakie) which is good for plotting vector graphics. 