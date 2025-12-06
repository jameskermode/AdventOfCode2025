# Advent of Code 2025

My solutions for [Advent of Code 2025](https://adventofcode.com/2025/).

## Languages

Solutions are implemented in:

- **Julia** - in the `julia/` directory
- **Uiua** - in the `uiua/` directory

## Setup

### Julia

1. Install [Julia](https://julialang.org/downloads/)
2. Activate the project and install dependencies:
   ```julia
   using Pkg
   Pkg.activate(".")
   Pkg.instantiate()
   ```
3. Run a single solution:
   ```bash
   julia julia/day_1.jl
   ```

#### Test Runner

Run all solutions with timing and answer verification:

```bash
julia julia/run.jl           # Run all days with full input
julia julia/run.jl --test    # Run all days with test input
julia julia/run.jl 3         # Run day 3 only
julia julia/run.jl 3 --test  # Run day 3 with test input
```

To add a new day, create `julia/day_N.jl` and add expected answers to `julia/answers.jl`.

### Uiua

1. Install [Uiua](https://www.uiua.org/)
2. Run a solution:
   ```bash
   uiua run uiua/day1.ua
   ```

## Input Data

Place your puzzle input files in the `data/` directory with the naming convention `day_N.txt` (e.g., `day_1.txt`).

Note: Puzzle inputs are personal and are not included in this repository per the [Advent of Code FAQ](https://adventofcode.com/about#faq_copying).
