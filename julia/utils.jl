tail(x) = @view x[2:end]

parse_grid(input) = permutedims(reduce(hcat, collect.(input)))

show_grid(grid) = print(join(join.(eachrow(grid)), "\n"))
