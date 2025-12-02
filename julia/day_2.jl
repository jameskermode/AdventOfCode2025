# https://adventofcode.com/2025/day/2

include("utils.jl")
input = readlines(joinpath(@__DIR__, "../data/day_2_test.txt"))

function invalid(id, n=2)
    d = digits(id)
    (length(d) % n != 0) && return false
    parts = Iterators.partition(d, length(d) ÷ n)
    if allequal(parts)
        @show id
        return true
    end
    return false
end

function parse_input(input)
    id_ranges = split.(split(first(input), ','),'-')
    ids = [collect(parse(Int,a):parse(Int,b)) for (a, b) in id_ranges]
    return reduce(vcat, ids)
end

function part_1(input)
    ids = parse_input(input)
    mask = invalid.(ids)
    sum(ids[mask])
end
@info part_1(input)

function part_2(input)
    ids = parse_input(input)
    mask = zeros(Bool, length(ids))
    for n = 2:7
        mask[invalid.(ids, n)] .= true
    end
    sum(ids[mask])
end
@info part_2(input)
