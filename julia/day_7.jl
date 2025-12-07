# https://adventofcode.com/2025/day/7

include("utils.jl")

const Location = CartesianIndex{2}

const DOWN  = Location(+1, 0)
const LEFT  = Location(0, -1)
const RIGHT = Location(0, +1)

function part_1(input; verbose=false)
    grid = parse_grid(input)
    beams = Location[findfirst(==('S'), grid)]
    next_beams = Location[]
    nsplit = 0
    for row in 2:size(grid, 1)
        empty!(next_beams)
        for beam in beams
            next_loc = beam + DOWN
            next_val = grid[next_loc]
            if next_val == '.'
                push!(next_beams, beam + DOWN)
                grid[next_loc] = '|'
            elseif next_val == '^'
                nsplit += 1
                for offset in (DOWN + LEFT, DOWN + RIGHT)
                    push!(next_beams, beam + offset)
                    grid[beam + offset] = '|'
                end
            end
        end
        beams, next_beams = next_beams, beams
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
        else
            0  # Dead end (shouldn't happen with valid input)
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

if abspath(PROGRAM_FILE) == @__FILE__
    input = readlines(joinpath(@__DIR__, "../data/day_7.txt"))
    @info "Part 1" part_1(input)
    @info "Part 2" part_2(input)
    @info "Part 2 (bottom-up)" part_2_bottom_up(input)
end
