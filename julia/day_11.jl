# https://adventofcode.com/2025/day/11

using Graphs
include("utils.jl")

function count_paths(g::SimpleDiGraph, source::Int, target::Int)
    order = topological_sort_by_dfs(g)
    
    counts = zeros(Int, nv(g))
    counts[source] = 1
    
    for u in order
        for v in outneighbors(g, u)
            counts[v] += counts[u]
        end
    end
    
    return counts[target]
end

function parse_input(input)
    edges = Vector{Tuple{String,String}}()
    for line in input
        source, targets = split(line, ":")
        targets = split(targets)
        append!(edges, [(source, target) for target in targets])
    end
    nodes = unique([getindex.(edges, 1); getindex.(edges, 2)])
    nodes = Dict(zip(nodes, eachindex(nodes)))
    graph = SimpleDiGraph(length(nodes))
    for (source, target) in edges
        add_edge!(graph, nodes[source], nodes[target])
    end
    nodes, graph
end

function part_1(input)
    nodes, graph = parse_input(input)
    count_paths(graph, nodes["you"], nodes["out"])
end

# Part 2: The full input has specific "bottleneck" nodes (svr, fft, dac) that
# partition the graph, allowing the total path count to be computed as a product
# of path counts between consecutive bottlenecks. This exploits the DAG structure.
function part_2(input)
    nodes, graph = parse_input(input)
    svr_fft = count_paths(graph, nodes["svr"], nodes["fft"])
    fft_dac = count_paths(graph, nodes["fft"], nodes["dac"])
    dac_out = count_paths(graph, nodes["dac"], nodes["out"])
    svr_fft * fft_dac * dac_out
end

if abspath(PROGRAM_FILE) == @__FILE__
    input = readlines(joinpath(@__DIR__, "../data/day_11.txt"))
    @info "Part 1" part_1(input)
    @info "Part 2" part_2(input)
end
