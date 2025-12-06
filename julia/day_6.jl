# https://adventofcode.com/2025/day/6

const OPS = Dict("*"=>*, "+"=>+)
parse_ops(line) = [OPS[op] for op in split(line)]

function parse_input(input)
    rows = [parse.(Int, split(row)) for row in input[1:end-1]]
    ops = parse_ops(last(input))
    (stack(rows), ops)
end

function part_1(input)
    numbers, ops = parse_input(input)
    sum(reduce(op, col) for (op, col) in zip(ops, eachrow(numbers)))
end

function part_2(input)
    lines = input[1:end-1]
    ops = parse_ops(last(input))
    ncols = maximum(length, lines)
    nrows = length(lines)

    # Pad lines to equal length for safe indexing
    padded = [rpad(line, ncols) for line in lines]

    # Find columns that are spaces in all rows (block separators)
    is_break = [all(padded[r][c] == ' ' for r in 1:nrows) for c in 1:ncols]

    # Find block boundaries
    break_idxs = vcat(0, findall(is_break), ncols + 1)

    total = 0
    op_idx = 1
    for bi in 2:length(break_idxs)
        col_start = break_idxs[bi-1] + 1
        col_end = break_idxs[bi] - 1
        col_start > col_end && continue  # skip empty blocks

        # Parse each column in this block as a vertical number
        numbers = Int[]
        for c in col_start:col_end
            # Build number string from column characters
            numstr = String([padded[r][c] for r in 1:nrows])
            push!(numbers, parse(Int, numstr))
        end

        total += reduce(ops[op_idx], numbers)
        op_idx += 1
    end
    total
end

if abspath(PROGRAM_FILE) == @__FILE__
    input = readlines(joinpath(@__DIR__, "../data/day_6.txt"))
    @info "Part 1" part_1(input)
    @info "Part 2" part_2(input)
end
