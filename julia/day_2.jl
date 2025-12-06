# https://adventofcode.com/2025/day/2

include("utils.jl")

function invalid(id, n=2)
    nd = ndigits(id)
    (nd % n != 0) && return false
    part_len = nd ÷ n
    divisor = 10^part_len
    first_part = id % divisor
    remaining = id ÷ divisor
    for _ in 2:n
        (remaining % divisor != first_part) && return false
        remaining ÷= divisor
    end
    true
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

function invalid_any(id, ns=2:7)
    for n in ns
        invalid(id, n) && return true
    end
    false
end

function part_2(input)
    ids = parse_input(input)
    sum(id for id in ids if invalid_any(id))
end

if abspath(PROGRAM_FILE) == @__FILE__
    input = readlines(joinpath(@__DIR__, "../data/day_2.txt"))
    @info "Part 1" part_1(input)
    @info "Part 2" part_2(input)
end
