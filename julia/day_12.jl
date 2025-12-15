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
area(r::Rect) = size(r.grid)

# Precompute for all orientations
function prepare_pieces(shapes::Dict{Int,Shape}, counts::Vector{Int})
    # Each entry: (area, Vector of (orientation, offsets) pairs)
    pieces = []
        
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
    [p[2] for p in pieces] # throw away area
end

function can_place(grid::BitMatrix, shape::Shape, origin::CartesianIndex{2})
    shape_size = CartesianIndex(size(shape))
    stop = origin + shape_size - CartesianIndex(1, 1)
    
    # Bounds check
    checkbounds(Bool, grid, origin) || return false
    checkbounds(Bool, grid, stop) || return false
    
    # Overlap check - any cell where both grid and shape are true?
    region = @view grid[origin[1]:stop[1], origin[2]:stop[2]]
    !any(region .& shape)
end

function place!(grid::BitMatrix, shape::Shape, origin::CartesianIndex{2})
    stop = origin + CartesianIndex(size(shape)) - CartesianIndex(1, 1)
    region = @view grid[origin[1]:stop[1], origin[2]:stop[2]]
    region .|= shape
end

function unplace!(grid::BitMatrix, shape::Shape, origin::CartesianIndex{2})
    stop = origin + CartesianIndex(size(shape)) - CartesianIndex(1, 1)
    region = @view grid[origin[1]:stop[1], origin[2]:stop[2]]
    region .&= .!shape
end

function first_empty(grid::BitMatrix)
    for r in axes(grid, 1)
        for c in axes(grid, 2)
            grid[r, c] || return CartesianIndex(r, c)
        end
    end
    nothing
end

function solve(grid::BitMatrix, pieces, piece_idx::Int, must_fill::Bool)
    piece_idx > length(pieces) && return true

    target = first_empty(grid)
    isnothing(target) && return false
    
    for (shape, offsets) in pieces[piece_idx]
        if must_fill
            for offset in offsets
                origin = target - offset + CartesianIndex(1, 1)
                if can_place(grid, shape, origin)
                     place!(grid, shape, origin)
                     solve(grid, pieces, piece_idx + 1, must_fill) && return true
                     unplace!(grid, shape, origin)
                end
            end
        else
            # Try all valid positions
            for r in axes(grid, 1), c in axes(grid, 2)
                origin = CartesianIndex(r, c)
                if can_place(grid, shape, origin)
                    place!(grid, shape, origin)
                    solve(grid, pieces, piece_idx + 1, must_fill) && return true
                    unplace!(grid, shape, origin)
                end
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
        must_fill = total_piece_area == length(rect.grid)
        valid = solve(rect.grid, pieces, 1, must_fill)
        @info "$(join(reverse(size(rect.grid)), "x"))) $(rect.counts) -> $valid"
        total += valid
    end
    total
end
