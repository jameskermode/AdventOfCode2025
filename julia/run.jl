# AoC 2025 Test Runner
#
# Usage:
#   julia julia/run.jl             # Run all days with full input (includes JIT time)
#   julia julia/run.jl --bench     # Benchmark mode (excludes JIT, multiple samples)
#   julia julia/run.jl --test      # Run all days with test input
#   julia julia/run.jl 3           # Run day 3 with full input
#   julia julia/run.jl 3 --bench   # Benchmark day 3
#
# To add a new day: just create day_N.jl and add answers to answers.jl

using BenchmarkTools

include("answers.jl")

# Auto-discover and load day modules
const DAYS = Dict{Int, Module}()

function discover_days()
    for file in readdir(@__DIR__)
        m = match(r"^day_(\d+)\.jl$", file)
        isnothing(m) && continue
        day = parse(Int, m.captures[1])
        # Create module with include() defined for nested includes
        mod = Module(Symbol("Day$day"))
        Core.eval(mod, :(include(path) = Base.include($mod, joinpath($(@__DIR__), path))))
        Base.include(mod, joinpath(@__DIR__, file))
        DAYS[day] = mod
    end
end

discover_days()

function format_time(seconds)
    if seconds < 1e-6
        "$(round(seconds * 1e9, digits=1))ns"
    elseif seconds < 1e-3
        "$(round(seconds * 1e6, digits=1))μs"
    elseif seconds < 1
        "$(round(seconds * 1e3, digits=2))ms"
    else
        "$(round(seconds, digits=2))s"
    end
end

function run_day(day::Int; test::Bool=false, bench::Bool=false)
    mod = DAYS[day]
    suffix = test ? "_test" : ""
    input_file = joinpath(@__DIR__, "../data/day_$(day)$(suffix).txt")

    if !isfile(input_file)
        println("  Input file not found: $input_file")
        return false
    end

    input = readlines(input_file)
    expected = test ? ANSWERS[day].test : ANSWERS[day].full

    all_passed = true

    for (part_num, (part_fn, expected_answer)) in enumerate([(mod.part_1, expected[1]), (mod.part_2, expected[2])])
        local result, elapsed

        if bench
            # Warmup run to compile
            result = part_fn(input)
            # Benchmark (minimum of multiple samples)
            elapsed = @belapsed $part_fn($input)
        else
            # Single run (includes JIT)
            elapsed = @elapsed begin
                result = part_fn(input)
            end
        end

        passed = result == expected_answer
        all_passed &= passed

        status = passed ? "✓" : "✗ expected $expected_answer"
        time_str = format_time(elapsed)

        println("  Part $part_num: $result $status ($time_str)")
    end

    all_passed
end

function main()
    args = collect(ARGS)
    test_mode = "--test" in args
    bench_mode = "--bench" in args
    filter!(x -> x ∉ ["--test", "--bench"], args)

    days_to_run = if isempty(args)
        sort(collect(keys(DAYS)))
    else
        [parse(Int, args[1])]
    end

    mode_str = test_mode ? "test" : "full"
    bench_str = bench_mode ? " (benchmarking)" : ""
    println("Running with $mode_str input$bench_str\n")

    all_passed = true
    total_time = @elapsed begin
        for day in days_to_run
            println("Day $day:")
            if !haskey(DAYS, day)
                println("  Not implemented")
                continue
            end
            passed = run_day(day; test=test_mode, bench=bench_mode)
            all_passed &= passed
            println()
        end
    end

    println("Total time: $(round(total_time, digits=2))s")

    exit(all_passed ? 0 : 1)
end

main()
