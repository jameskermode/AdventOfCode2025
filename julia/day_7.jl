# https://adventofcode.com/2025/day/7

parse_grid(input) = permutedims(reduce(hcat, collect.(input)))

show_grid(grid) = print(join(join.(eachrow(grid)), "\n"))

Location = CartesianIndex{2}

const DOWN  = Location(+1, 0)
const LEFT  = Location(0, -1)
const RIGHT = Location(0, +1)

function part_1(input; verbose=false)
    grid = parse_grid(input)
    beams = Location[]
    push!(beams, findfirst(==('S'), grid))
    nsplit = 0
    for row in 2:size(grid, 1)
        new_beams = Location[]
        for beam in beams
            next_loc = beam + DOWN
            next_val = grid[next_loc]
            if next_val == '.'
                push!(new_beams, beam + DOWN)
                grid[next_loc] = '|'
            elseif next_val == '^'
                nsplit += 1
                for offset in (DOWN + LEFT, DOWN + RIGHT)
                    push!(new_beams, beam + offset)
                    grid[beam + offset] = '|'
                end
            end
        end
        beams = new_beams
        if verbose
            println("Step $(row)")
            show_grid(grid)
        end
    end
    nsplit
end

function part_2(input)
    grid = parse_grid(input)
    start = findfirst(==('S'), grid)
    stack = Location[start]
    cache = Dict{Location, Int}()

    function count_paths(start_loc)
        haskey(cache, start_loc) && return cache[start_loc]

        loc = start_loc
        while loc[1] < size(grid, 1) && grid[loc + DOWN] == '.'
            loc += DOWN
        end
        result = if loc[1] == size(grid, 1)
            1
        elseif grid[loc + DOWN] == '^'
            count_paths(loc + DOWN + LEFT) + count_paths(loc + DOWN + RIGHT)
        end

        cache[start_loc] = result
        result
    end

    count_paths(start)
end

function part_2_bottom_up(input)
    grid = parse_grid(input)
    nrow, ncol = size(grid)

    paths = zeros(Int, nrow, ncol)
    paths[nrow, :] .= 1

    for row in (nrow-1):-1:1
        for col in 1:ncol
            cell = grid[row, col]
            if cell == '^'
                paths[row, col] = paths[row+1, col-1] + paths[row+1, col+1]
            elseif cell in ('.', 'S')
                paths[row, col] = paths[row+1, col]
            end
        end
    end

    start = findfirst(==('S'), grid)
    paths[start]
end
