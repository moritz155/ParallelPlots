using ParallelPlots
using Documenter

DocMeta.setdocmeta!(ParallelPlots, :DocTestSetup, :(using ParallelPlots); recursive=true)

makedocs(;
    modules=[ParallelPlots],
    authors="Moritz Schelten <moritz155@win.tu-berlin.de>, Leon Haufe <leon.haufe@campus.tu-berlin.de>",
    sitename="ParallelPlots",
    format=Documenter.HTML(;
        canonical="https://moritz155.github.io/ParallelPlots",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Getting started" => "getting_started.md",
    ],
)

deploydocs(;
    repo="github.com/moritz155/ParallelPlots",
    devbranch="main",
)
