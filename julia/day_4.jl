# https://adventofcode.com/2025/day/4

showgrid(grid) = println(join([join(row, "") for row in eachrow(grid)], "\n"))

const DIRS8 = [CartesianIndex(dr, dc) for dr in -1:1, dc in -1:1 if !(dr == dc == 0)]

function find_rolls(grid)
    remove = zeros(Bool, size(grid))
    for idx in CartesianIndices(grid)
        grid[idx] == '@' || continue
        nn = count(
            checkbounds(Bool, grid, idx + d) && grid[idx + d] == '@'
            for d in DIRS8
        )
        remove[idx] = nn < 4
    end
    remove
end

function part_1(input)
    grid = parse_grid(input)
    sum(find_rolls(grid))
end

function part_2(input; verbose=false)
    grid = parse_grid(input)
    total = 0
    verbose && showgrid(grid)
    while true
        remove = find_rolls(grid)
        (removed = sum(remove)) == 0 && break
        grid[remove] .= '.'
        total += removed
        if verbose
            @info "Removing $(removed)"
            showgrid(grid)
        end
    end
    total
end

function parse_grid(input)
    permutedims(hcat(collect.(input)...))
end

if abspath(PROGRAM_FILE) == @__FILE__
    input = readlines(joinpath(@__DIR__, "../data/day_4.txt"))
    @info "Part 1" part_1(input)
    @info "Part 2" part_2(input)
end
