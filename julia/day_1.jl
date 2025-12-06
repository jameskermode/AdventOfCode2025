# https://adventofcode.com/2025/day/1

include("utils.jl")

function part_1(input)
    pos = 50
    nzeros = 0
    for line in input
        dir, amount = line[1], line[2:end]
        amount = parse(Int, amount)
        sgn = dir == 'R' ? 1 : -1
        pos += sgn * amount
        pos = mod(pos, 100)
        if pos == 0
            nzeros += 1
        end
        @debug "$dir $amount $pos"
    end
    nzeros
end
function part_1_v2(input)
    finalpos, nzeros = reduce(input, init=(50, 0)) do (pos, cnt), line
         sgn, inc = first(line) == 'R' ?  +1 : -1, parse(Int, line[2:end])
         newpos = mod(pos + sgn * inc, 100)
         (newpos, cnt + (newpos == 0))
    end
    nzeros
end
function part_1_v3(input)
    dir  = first.(input)
    sgn  = @. 2(dir == 'R') - 1
    incs = @. parse(Int, tail(input))
    incs .*= sgn
    positions = cumsum([50; incs])
    wrapped = mod.(positions, 100)
    count(==(0), tail(wrapped))
end
function part_2(input)
    pos = 50
    nzeros = 0
    for line in input
        dir, amount = line[1], line[2:end]
        amount = parse(Int, amount)
        sgn = dir == 'R' ? 1 : -1
        for idx in 1:amount
            pos = mod(pos + sgn, 100)
            if pos == 0
                nzeros += 1
            end
        end
        @debug "$dir $amount $pos"
    end
    nzeros
end

if abspath(PROGRAM_FILE) == @__FILE__
    input = readlines(joinpath(@__DIR__, "../data/day_1.txt"))
    @info "Part 1" part_1(input)
    @info "Part 2" part_2(input)
end
