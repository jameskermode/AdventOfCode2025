# https://adventofcode.com/2025/day/10

include("utils.jl")

function parse_line(text)
    # Extract each bracket type
    indicators = match(r"\[([^\]]+)\]", text).captures[1]
    parens = [m.captures[1] for m in eachmatch(r"\(([^)]+)\)", text)]
    braces = match(r"\{([^}]+)\}", text).captures[1]

    # Split the comma-separated ones
    parens_split = [split(p, ",") for p in parens]
    braces_split = split(braces, ",")

    buttons = [parse.(Int, split(p, ",")) for p in parens]
    joltage = parse.(Int, split(braces, ","))

    (indicators, buttons, joltage)
end

to_indicator(v, d) = BitVector(i in v for i in 0:d-1)

# Brute force: try all 2^n button combinations (old implementation)
function best_n_pressed_brute(buttons, indicators)
    n_buttons = length(buttons)
    n_indicators = length(indicators)
    best_n_pressed = typemax(Int)

    for mask in 0:(2^n_buttons - 1)
        result = zeros(Int, n_indicators)
        for i in 0:(n_buttons - 1)
            if mask & (1 << i) != 0
                result = xor.(result, buttons[i+1])
            end
        end
        if all(result .== indicators)
            n_pressed = count_ones(mask)
            @debug "match with buttons $(digits(mask, base=2)) $(n_pressed)"
            if n_pressed < best_n_pressed
                best_n_pressed = n_pressed
            end
        end
    end
    best_n_pressed
end

# GF(2) Gaussian elimination solver - O(n³) instead of O(2^n)
function solve_gf2(A, b)
    m, n = size(A)
    # Augmented matrix [A | b]
    aug = hcat(A, b) .% 2

    # Gaussian elimination over GF(2)
    pivot_row = 1
    pivot_cols = Int[]

    for col in 1:n
        # Find pivot
        found = false
        for row in pivot_row:m
            if aug[row, col] == 1
                aug[pivot_row, :], aug[row, :] = aug[row, :], aug[pivot_row, :]
                found = true
                break
            end
        end
        !found && continue

        push!(pivot_cols, col)

        # Eliminate other rows
        for row in 1:m
            if row != pivot_row && aug[row, col] == 1
                aug[row, :] = aug[row, :] .⊻ aug[pivot_row, :]
            end
        end
        pivot_row += 1
    end

    # Check consistency
    for row in pivot_row:m
        aug[row, end] == 1 && return typemax(Int)  # No solution
    end

    # Free variables - try all combinations to minimize weight
    free_vars = setdiff(1:n, pivot_cols)
    best_weight = typemax(Int)

    for mask in 0:(2^length(free_vars) - 1)
        x = zeros(Int, n)
        for (i, fv) in enumerate(free_vars)
            x[fv] = (mask >> (i-1)) & 1
        end

        # Solve for pivot variables via back-substitution
        for (i, pc) in enumerate(pivot_cols)
            val = aug[i, end]
            for j in (pc+1):n
                val ⊻= aug[i, j] * x[j]
            end
            x[pc] = val
        end

        weight = sum(x)
        weight < best_weight && (best_weight = weight)
    end

    best_weight
end

function best_n_pressed(buttons, indicators)
    A = Int.(hcat(buttons...))
    b = Int.(indicators)
    solve_gf2(A, b)
end

function part_1_brute(input)
    total = 0
    for line in input
        indicators, buttons, _ = parse_line(line)
        indicators = collect(indicators) .== '#'
        buttons = to_indicator.(buttons, length(indicators))
        n_pressed = best_n_pressed_brute(buttons, indicators)
        @debug "$line -> $n_pressed"
        total += n_pressed
    end
    total
end

function part_1(input)
    total = 0
    for line in input
        indicators, buttons, _ = parse_line(line)
        indicators = collect(indicators) .== '#'
        buttons = to_indicator.(buttons, length(indicators))
        n_pressed = best_n_pressed(buttons, indicators)
        @debug "$line -> $n_pressed"
        total += n_pressed
    end
    total
end

using JuMP, HiGHS

function min_presses(A, y)
    n = size(A, 2)
    model = Model(HiGHS.Optimizer)
    set_silent(model)
    @variable(model, x[1:n] >= 0, Int)
    @constraint(model, A * x .== y)
    @objective(model, Min, sum(x))
    optimize!(model)
    return round.(Int, value.(x))
end

function part_2(input)
    total = 0
    for line in input
        _, buttons, y = parse_line(line)
        A = stack(to_indicator.(buttons, length(y)))
        x = min_presses(A, y)
        total += sum(x)
        @debug "$line -> $x $(sum(x))"
    end
    total
end

if abspath(PROGRAM_FILE) == @__FILE__
    input = readlines(joinpath(@__DIR__, "../data/day_10.txt"))
    @info "Part 1" part_1(input)
    @info "Part 2" part_2(input)
end
