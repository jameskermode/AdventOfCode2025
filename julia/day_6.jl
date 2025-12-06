# https://adventofcode.com/2025/day/6

input = readlines("data/day_6.txt")

parse_ops(line) = [Dict("*"=>*, "+"=>+)[op] for op in split(line)]

function parse_input(input)
    rows = [parse.(Int, split(row)) for row in input[1:end-1]]
    ops = parse_ops(last(input))
    (stack(rows), ops)
end

function part_1(input)
    numbers, ops = parse_input(input)
    sum(reduce(op, col) for (op, col) in zip(ops, eachrow(numbers)))
end
@info part_1(input)

function part_2(input)
    grid = permutedims(hcat(collect.(input[1:end-1])...))
    ops = parse_ops(last(input))
    breaks = (sum(grid .== ' ', dims=1) .== size(grid, 1))[1,:]
    break_idxs = vcat(0, findall(==(1), breaks), size(grid, 2)+1)
    blocks = [grid[:, break_idxs[bi-1]+1:break_idxs[bi]-1] for bi in 2:length(break_idxs)]

    total = 0
    for (op, block) in zip(ops, blocks)
       numbers = parse.(Int, join.(eachcol(block)))
       total += reduce(op, numbers)
    end
    total
end
@info part_2(input)
