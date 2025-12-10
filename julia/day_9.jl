# https://adventofcode.com/2025/day/9

using Combinatorics
include("utils.jl")

function corners_area(p1, p2)
    bl, tr = min(p1, p2), max(p1, p2)
    (bl, tr, length(bl:tr))
end

function coords_to_grid(coords, p1=nothing, p2=nothing)
    grid = fill('.', Tuple(reduce(max, coords) + CartesianIndex(2, 2)))
    grid[coords] .= '#'
    if p1 !== nothing && p2 !== nothing
        bl, tr, A = corners_area(p1, p2)
        grid[bl:tr] .= 'o'
        grid[p1] = 'O'
        grid[p2] = 'O'
        @info "Area = $A"
    end
    grid
end

function part_1(input; verbose=false)
    coords = parse_csv(input)
    coords = CartesianIndex.(Tuple.(eachrow(coords)))
    p1, p2 = argmax(((a,b),) -> corners_area(a, b)[3], combinations(coords, 2))
    bl, tr, A = corners_area(p1, p2)
    if verbose
        show_grid(coords_to_grid(coords, bl, tr)')
        println()
    end
    A
end

function is_point_in_polygon(point, poly_vertices)
    num_vertices = length(poly_vertices)
    
    # First check if point lies on any edge
    for i in 1:num_vertices
        v1 = poly_vertices[i]
        v2 = poly_vertices[i % num_vertices + 1]
        
        # Check if point is on the segment v1-v2
        # For axis-aligned edges, this is simple
        if v1[1] == v2[1] == point[1]  # Vertical edge
            if min(v1[2], v2[2]) <= point[2] <= max(v1[2], v2[2])
                return true
            end
        elseif v1[2] == v2[2] == point[2]  # Horizontal edge
            if min(v1[1], v2[1]) <= point[1] <= max(v1[1], v2[1])
                return true
            end
        end
    end
    
    # Ray casting for interior points
    num_intersections = 0
    for i in 1:num_vertices
        v1 = poly_vertices[i]
        v2 = poly_vertices[i % num_vertices + 1]

        if ((v1[2] > point[2]) != (v2[2] > point[2])) && 
           (point[1] < (v2[1] - v1[1]) * (point[2] - v1[2]) / (v2[2] - v1[2]) + v1[1])
            num_intersections += 1
        end
    end

    return num_intersections % 2 == 1
end

function segments_intersect(a1, a2, b1, b2)
    # Check if line segment (a1, a2) intersects with (b1, b2)
    # Using the cross product method
    
    function cross(o, a, b)
        (a[1] - o[1]) * (b[2] - o[2]) - (a[2] - o[2]) * (b[1] - o[1])
    end
    
    d1 = cross(b1, b2, a1)
    d2 = cross(b1, b2, a2)
    d3 = cross(a1, a2, b1)
    d4 = cross(a1, a2, b2)

    # Collinear case - segments lie on the same line, this is allowed
    if d1 == 0 && d2 == 0
        return false
    end
    
    if ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
       ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))
        return true
    end
    
    false
end

function rectangle_crosses_polygon(bl, tr, poly_vertices)
    tl = (bl[1], tr[2])
    br = (tr[1], bl[2])
    bl = Tuple(bl)
    tr = Tuple(tr)
    
    # Four edges of the rectangle
    rect_edges = [
        (bl, tl),
        (tl, tr),
        (tr, br),
        (br, bl)
    ]
    
    num_vertices = length(poly_vertices)
    for i in 1:num_vertices
        v1 = Tuple(poly_vertices[i])
        v2 = Tuple(poly_vertices[i % num_vertices + 1])
        
        for (r1, r2) in rect_edges
            if segments_intersect(r1, r2, v1, v2)
                return true
            end
        end
    end
    
    false
end

# Original implementation - processes pairs in arbitrary order
function part_2_unsorted(input; verbose=false)
    coords = parse_csv(input)
    poly_vertices = collect(eachrow(coords))

    best_area = 0
    best_rect = nothing
    for (a, b) in combinations(poly_vertices, 2)
        bl, tr, area = corners_area(CartesianIndex(Tuple(a)), CartesianIndex(Tuple(b)))
        tl = CartesianIndex(bl[1], tr[2])
        br = CartesianIndex(tr[1], bl[2])
        !is_point_in_polygon(bl, poly_vertices) && continue
        !is_point_in_polygon(tr, poly_vertices) && continue
        !is_point_in_polygon(tl, poly_vertices) && continue
        !is_point_in_polygon(br, poly_vertices) && continue

        # Check no rectangle edge crosses polygon boundary
        rectangle_crosses_polygon(bl, tr, poly_vertices) && continue

        if area > best_area
            best_area = area
            best_rect = (bl, tr)
        end
    end

    if verbose
        grid = coords_to_grid(CartesianIndex.(Tuple.(eachrow(coords))))
        (bl, tr) = best_rect
        @show bl, tr
        grid[bl:tr] .= 'o'
        grid[bl] = 'O'
        grid[tr] = 'O'
        show_grid(grid')
    end

    best_area
end

# Optimized: sort by area descending, early termination when remaining can't beat best
function part_2(input; verbose=false)
    coords = parse_csv(input)
    poly_vertices = collect(eachrow(coords))
    n = length(poly_vertices)

    # Precompute all candidate pairs with their potential areas
    candidates = Vector{Tuple{Int, Int, Int, CartesianIndex{2}, CartesianIndex{2}}}()
    sizehint!(candidates, n * (n - 1) ÷ 2)

    for i in 1:n
        for j in (i+1):n
            a, b = poly_vertices[i], poly_vertices[j]
            bl, tr, area = corners_area(CartesianIndex(Tuple(a)), CartesianIndex(Tuple(b)))
            push!(candidates, (area, i, j, bl, tr))
        end
    end

    # Sort by area descending
    sort!(candidates, by=first, rev=true)

    best_area = 0
    best_rect = nothing

    for (area, _, _, bl, tr) in candidates
        # Early termination: if max possible area <= best, we're done
        area <= best_area && break

        tl = CartesianIndex(bl[1], tr[2])
        br = CartesianIndex(tr[1], bl[2])

        # Check all corners inside polygon
        !is_point_in_polygon(bl, poly_vertices) && continue
        !is_point_in_polygon(tr, poly_vertices) && continue
        !is_point_in_polygon(tl, poly_vertices) && continue
        !is_point_in_polygon(br, poly_vertices) && continue

        # Check no edge crossing
        rectangle_crosses_polygon(bl, tr, poly_vertices) && continue

        # Valid rectangle found - this is the largest possible
        best_area = area
        best_rect = (bl, tr)
        # Don't break here - there might be another valid rect with same area
        # that we want to find for verbose output consistency
    end

    if verbose
        grid = coords_to_grid(CartesianIndex.(Tuple.(eachrow(coords))))
        (bl, tr) = best_rect
        @show bl, tr
        grid[bl:tr] .= 'o'
        grid[bl] = 'O'
        grid[tr] = 'O'
        show_grid(grid')
    end

    best_area
end

if abspath(PROGRAM_FILE) == @__FILE__
    input = readlines(joinpath(@__DIR__, "../data/day_9.txt"))
    @info "Part 1" part_1(input)
    @info "Part 2" part_2(input)
end
