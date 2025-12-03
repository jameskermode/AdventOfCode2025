# https://adventofcode.com/2025/day/3

input = readlines("data/day_3.txt")

function joltage(bank, ndigits, start=1)
    ndigits == 0 && return 0
    range = start:(length(bank) - ndigits + 1)
    max_val, rel_idx = findmax(@view bank[range])
    max_idx = start + rel_idx - 1
    (max_val - '0') * 10^(ndigits-1) + joltage(bank, ndigits-1, max_idx+1)
end

function part_1(input)
    sum(joltage.(input, 2))
end
@info part_1(input)

function part_2(input)
    sum(joltage.(input, 12))
end
@info part_2(input)
