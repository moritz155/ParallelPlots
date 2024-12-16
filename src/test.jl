using CairoMakie
CairoMakie.activate!(type = "svg")

let
    s = Scene(camera = campixel!)

    n = 5
    k = 20

    data = [randn(k) .* (rand() + 1) * 10 for _ in 1:n]


    limits = extrema.(data)

    scaled = [(d .- mi) ./ (ma - mi) for (d, (mi, ma)) in zip(data, limits)]

    width = 600
    height = 400
    offset = 100

    for i in 1:n
        x = (i - 1) / (n - 1) * width
        MakieLayout.LineAxis(s, limits = limits[i],
            spinecolor = :black, labelfont = "Arial",
            ticklabelfont = "Arial", spinevisible = true,
            minorticks = IntervalsBetween(2),
            endpoints = Point2f0[(offset + x, offset), (offset + x, offset + height)],
            ticklabelalign = (:right, :center), labelvisible = false)
    end

    for i in 1:k
        values = map(1:n, data, limits) do j, d, l
            x = (j - 1) / (n - 1) * width
            Point2f0(offset + x, (d[i] - l[1]) ./ (l[2] - l[1]) * height + offset)
        end

        lines!(s, values, color = get(Makie.ColorSchemes.inferno, (i - 1) / (k - 1)),
            show_axis = false)
    end

    s
    save("parallel_coordinates_plot.png", s)
    display(s)
end