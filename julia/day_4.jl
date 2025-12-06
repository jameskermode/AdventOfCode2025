# https://adventofcode.com/2025/day/4

const DIRS8 = [CartesianIndex(dr, dc) for dr in -1:1, dc in -1:1 if !(dr == dc == 0)]

function extract_cells(input)
    Set(
        CartesianIndex(r, c)
        for (r, line) in enumerate(input)
        for (c, ch) in enumerate(line)
        if ch == '@'
    )
end

function find_rolls(cells::Set{CartesianIndex{2}})
    Set(idx for idx in cells if count(idx + d in cells for d in DIRS8) < 4)
end

function part_1(input)
    cells = extract_cells(input)
    length(find_rolls(cells))
end

function part_2(input)
    cells = extract_cells(input)
    total = 0
    while true
        to_remove = find_rolls(cells)
        isempty(to_remove) && break
        setdiff!(cells, to_remove)
        total += length(to_remove)
    end
    total
end

if abspath(PROGRAM_FILE) == @__FILE__
    input = readlines(joinpath(@__DIR__, "../data/day_4.txt"))
    @info "Part 1" part_1(input)
    @info "Part 2" part_2(input)
end
