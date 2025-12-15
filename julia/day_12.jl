# https://adventofcode.com/2025/day/12

include("utils.jl")

const Shape = BitMatrix

struct Rect
    counts::Vector{Int}
    grid::BitMatrix
end

function parse_shape(input)
    id = parse(Int, split(input[1], ":")[1])
    shape = parse_grid(input[2:end]) .== '#'
    id, Shape(shape)
end

function parse_rect(line)
    dims, counts = split(line, ":")
    width, height = Tuple(parse.(Int, split(dims, "x")))
    counts = parse.(Int, split(counts))
    Rect(counts, falses(height, width))
end

function parse_input(input)
    blocks = split.(split(join(input, "\n"), "\n\n"), "\n")
    shapes = Dict(parse_shape.(blocks[1:end-1]))
    rects = parse_rect.(blocks[end])
    (shapes, rects)
end

function all_orientations(s::Shape)
    orientations = Shape[]
    for rot in 0:3
        r = rot == 0 ? s : rotr90(s, rot)
        push!(orientations, r)
        push!(orientations, reverse(r, dims=1))  # flip
    end
    unique(orientations)  # deduplicate
end

area(s::Shape) = count(s)

# Precompute for all orientations
function prepare_pieces(shapes::Dict{Int,Shape}, counts::Vector{Int})
    # Each entry: (area, Vector of (orientation, offsets) pairs)
    pieces = Tuple{Int, Vector{Tuple{Shape, Vector{CartesianIndex{2}}}}}[]

    for (id, count) in enumerate(counts)
        count == 0 && continue
        base_shape = shapes[id - 1]  # 0-indexed in problem

        orientation_data = [(shape, findall(shape)) for shape in
                            all_orientations(base_shape)]
        A = area(base_shape)
        for _ in 1:count
            push!(pieces, (A, orientation_data))
        end
    end

    sort!(pieces, by = first, rev = true)
    [p[2] for p in pieces]  # throw away area
end

function can_place(grid::BitMatrix, shape::Shape, origin::CartesianIndex{2})
    shape_size = CartesianIndex(size(shape))
    stop = origin + shape_size - CartesianIndex(1, 1)

    # Bounds check
    checkbounds(Bool, grid, origin) || return false
    checkbounds(Bool, grid, stop) || return false

    # Overlap check - any cell where both grid and shape are true?
    # Use explicit loop to avoid allocations
    @inbounds for j in axes(shape, 2), i in axes(shape, 1)
        grid[origin[1] + i - 1, origin[2] + j - 1] && shape[i, j] && return false
    end
    true
end

function place!(grid::BitMatrix, shape::Shape, origin::CartesianIndex{2})
    @inbounds for j in axes(shape, 2), i in axes(shape, 1)
        if shape[i, j]
            grid[origin[1] + i - 1, origin[2] + j - 1] = true
        end
    end
end

function unplace!(grid::BitMatrix, shape::Shape, origin::CartesianIndex{2})
    # Use explicit loop to avoid allocations from .!shape
    @inbounds for j in axes(shape, 2), i in axes(shape, 1)
        if shape[i, j]
            grid[origin[1] + i - 1, origin[2] + j - 1] = false
        end
    end
end

function solve(grid::BitMatrix, pieces, piece_idx::Int)
    piece_idx > length(pieces) && return true

    for (shape, _) in pieces[piece_idx]
        # Row-major iteration for consistent fill order
        for r in axes(grid, 1), c in axes(grid, 2)
            origin = CartesianIndex(r, c)
            @inbounds grid[origin] && continue
            if can_place(grid, shape, origin)
                place!(grid, shape, origin)
                solve(grid, pieces, piece_idx + 1) && return true
                unplace!(grid, shape, origin)
            end
        end
    end

    false
end

function part_1(input)
    total = 0
    shapes, rects = parse_input(input)
    for rect in rects
        pieces = prepare_pieces(shapes, rect.counts)
        total_piece_area = sum(count(p[1][1]) for p in pieces)
        grid_area = length(rect.grid)
        total_piece_area > grid_area && continue
        valid = solve(rect.grid, pieces, 1)
        @info "$(join(reverse(size(rect.grid)), "x"))) $(rect.counts) -> $valid"
        total += valid
    end
    total
end
