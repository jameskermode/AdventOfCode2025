# https://adventofcode.com/2025/day/4

input = readlines("data/day_4.txt")
grid = permutedims(hcat(collect.(input)...))

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

function part_1(grid)
    sum(find_rolls(grid))
end
@info part_1(grid)

function part_2(grid; verbose=false)
    grid = copy(grid)
    count = 0
    verbose && showgrid(grid)
    while true
        remove = find_rolls(grid)
        (removed = sum(remove)) == 0 && break
        grid[remove] .= '.'
        count += removed
        if verbose
            @info "Removing $(removed)"
            showgrid(grid)
        end
    end
    count
end
@info part_2(grid)
