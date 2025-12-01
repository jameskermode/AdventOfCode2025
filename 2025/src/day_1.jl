# https://adventofcode.com/2025/day/1

input = readlines("2025/data/day_1.txt")

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
        @info "$dir $amount $pos"
    end
    nzeros
end
@info part_1(input)

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
        @info "$dir $amount $pos"
    end
    nzeros
end
@info part_2(input)
