# https://adventofcode.com/2025/day/1

include("utils.jl")

input = readlines(joinpath(@__DIR__, "../data/day_1.txt"))

function part_1(input)
    pos = 50
    nzeros = 0
    for line in input
        dir, amount = line[1], line[2:end]
        amount = parse(Int, amount)
        if dir == 'R'
            pos += amount
        elseif dir == 'L'
            pos -= amount
        else
            error("bad direction $dir")
        end
        pos = mod(pos, 100)
        if pos == 0
            nzeros += 1
        end
        @debug "$dir $amount $pos"
    end
    nzeros
end
@info part_1(input)

function part_1_v2(input)
    finalpos, nzeros = reduce(input, init=(50, 0)) do (pos, cnt), line
         sgn, inc = first(line) == 'R' ?  +1 : -1, parse(Int, line[2:end])
         newpos = mod(pos + sgn * inc, 100)
         (newpos, cnt + (newpos == 0))
    end
    nzeros
end
@info part_1_v2(input)

function part_1_v3(input)
    dir  = first.(input)
    sgn  = @. 2(dir == 'R') - 1
    incs = @. parse(Int, tail(input))
    incs .*= sgn
    positions = cumsum([50; incs])
    wrapped = mod.(positions, 100)
    count(==(0), tail(wrapped))
end
@info part_1_v3(input)

function part_2(input)
    pos = 50
    nzeros = 0
    for line in input
        dir, amount = line[1], line[2:end]
        amount = parse(Int, amount)
        if dir == 'R'
            sgn = +1
        elseif dir == 'L'
            sgn = -1
        else
            error("bad direction $dir")
        end
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
@info part_2(input)
