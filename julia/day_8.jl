# https://adventofcode.com/2025/day/8
#

using LinearAlgebra

parse_input(input) = permutedims(reduce(hcat, [parse.(Int, row) for row in split.(input, ",")]))

function distance_matrix(p)
    G = p * p'
    D = sqrt.(diag(G) .+ diag(G)' .- 2 .* G)
    U = triu(D, 1)  # Strictly upper triangular (excludes diagonal)
    U[U .== 0.0] .= Inf  # Set lower triangle and diagonal to Inf
    U
end

function find_clusters(p; N=10, find_single_cluster=false, verbose=false)
    U = distance_matrix(p)
    v = vec(U)
    if find_single_cluster
        ind = sortperm(v)
    else
        ind = partialsortperm(v, 1:N)
    end
    boxes = CartesianIndices(U)[ind]
    clusters = Set{Int}[]

    for box in boxes
        if verbose
            @info "Processing" box[1] box[2] p[box[1],:] p[box[2],:]
        end
        c1 = nothing
        c2 = nothing
        for (cidx, cluster) in enumerate(clusters)
            box[1] in cluster && (c1 = cidx)
            box[2] in cluster && (c2 = cidx)
            c1 !== nothing && c2 !== nothing && break
        end

        if c1 !== nothing && c2 === nothing
            push!(clusters[c1], box[2])
            if verbose
                @info "Added to cluster" p[box[2],:] c1
            end
        elseif c1 === nothing && c2 !== nothing
            push!(clusters[c2], box[1])
            if verbose
                @info "Added to cluster" p[box[1],:] c2
            end
        elseif c1 !== nothing && c2 !== nothing
            if c1 == c2
                if verbose
                    @info "Skipping (already in same cluster)" p[box[1],:] p[box[2],:] c1
                end
            else
                if verbose
                    @info "Merging clusters" c1 clusters[c1] c2 clusters[c2]
                end
                u = union(clusters[c1], clusters[c2])
                deleteat!(clusters, (min(c1,c2), max(c1,c2)))
                push!(clusters, u)
            end
        elseif c1 === nothing && c2 === nothing
            if verbose
                @info "New cluster" box[1] box[2] p[box[1],:] p[box[2],:]
            end
            push!(clusters, Set([box[1], box[2]]))
        end

        if find_single_cluster
            if length(clusters) == 1 && length(clusters[1]) == size(p, 1)
                return box
            end
        end
    end
    clusters
end

# Union-Find data structure with path compression and union by rank
mutable struct UnionFind
    parent::Vector{Int}
    rank::Vector{Int}

    UnionFind(n::Int) = new(collect(1:n), zeros(Int, n))
end

function uf_find!(uf::UnionFind, x::Int)
    if uf.parent[x] != x
        uf.parent[x] = uf_find!(uf, uf.parent[x])  # Path compression
    end
    uf.parent[x]
end

function uf_union!(uf::UnionFind, x::Int, y::Int)
    rx, ry = uf_find!(uf, x), uf_find!(uf, y)
    rx == ry && return false  # Already in same set

    # Union by rank
    if uf.rank[rx] < uf.rank[ry]
        uf.parent[rx] = ry
    elseif uf.rank[rx] > uf.rank[ry]
        uf.parent[ry] = rx
    else
        uf.parent[ry] = rx
        uf.rank[rx] += 1
    end
    true
end

function find_clusters_uf(p; N=10, find_single_cluster=false)
    n = size(p, 1)
    U = distance_matrix(p)
    v = vec(U)

    uf = UnionFind(n)
    num_components = n

    if find_single_cluster
        # Process edges in sorted order until single cluster
        for idx in sortperm(v)
            box = CartesianIndices(U)[idx]
            i, j = box[1], box[2]
            if uf_union!(uf, i, j)
                num_components -= 1
                if num_components == 1
                    return box
                end
            end
        end
    else
        # Process N smallest edges
        for idx in partialsortperm(v, 1:N)
            box = CartesianIndices(U)[idx]
            uf_union!(uf, box[1], box[2])
        end

        # Count cluster sizes
        sizes = zeros(Int, n)
        for i in 1:n
            sizes[uf_find!(uf, i)] += 1
        end
        return filter(>(0), sizes)
    end
end

function part_1_uf(input)
    positions = parse_input(input)
    N = size(input, 1) == 20 ? 10 : 1000
    sizes = find_clusters_uf(positions; N)
    prod(partialsort(sizes, 1:3, rev=true))
end

function part_2_uf(input)
    positions = parse_input(input)
    box = find_clusters_uf(positions; find_single_cluster=true)
    positions[box[1], 1] * positions[box[2], 1]
end

function part_1(input; verbose=false)
    positions = parse_input(input)
    N = size(input, 1) == 20 ? 10 : 1000
    clusters = find_clusters(positions; N, verbose)
    prod(partialsort(length.(clusters), 1:3, rev=true))
end

function part_2(input; verbose=false)
    positions = parse_input(input)
    box = find_clusters(positions; find_single_cluster=true, verbose)
    positions[box[1], 1] * positions[box[2], 1]
end

if abspath(PROGRAM_FILE) == @__FILE__
    input = readlines(joinpath(@__DIR__, "../data/day_8.txt"))
    @info "Part 1" part_1(input)
    @info "Part 2" part_2(input)
end
