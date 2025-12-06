# https://adventofcode.com/2025/day/5

input = readlines("data/day_5.txt")

function parse_input(input)
    idx = findfirst(isempty, input)
    ranges = [UnitRange(parse.(Int, split(line, "-"))...) for line in input[1:idx-1]]
    items = parse.(Int, input[idx+1:end])
    (ranges, items)
end


function part_1(input)
    ranges, items = parse_input(input)
    count(item -> any(r -> item in r, ranges), items)
end
@info part_1(input)

function part_2(input)
    ranges, items = parse_input(input)
    ranges = sort(ranges, by=first)
    merged = UnitRange{Int}[]
    current = first(ranges)
    for r in Iterators.drop(ranges, 1)
        if first(r) <= last(current) + 1
            current= first(current):max(last(current), last(r))
        else
            push!(merged, current)
            current = r
        end
    end
    push!(merged, current)
    sum(length, merged)
end
@info part_2(input)
