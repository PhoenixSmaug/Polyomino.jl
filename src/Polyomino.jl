module Polyomino

using DataStructures
using MatrixNetworks
using JuMP
using HiGHS
using ProgressMeter

struct Poly
    tiles::Set{Pair{Int64, Int64}}
    vertices::Int64
    edges::Int64
end

include("algorithms.jl")
include("min-line-cover.jl")

Base.show(io::IO, x::Poly) = begin
    minX, maxX, minY, maxY = dimensionPoly(x)

    for i in minX:maxX
        for j in minY:maxY
            (Pair(i, j) in x.tiles) ? print(io, "*") : print(io, " ")
        end
        println()
    end
end

@inline function dimensionPoly(p::Poly)
    minX = typemax(Int64); minY = typemax(Int64);
    maxX = typemin(Int64); maxY = typemin(Int64);
    for i in p.tiles
        maxX = (i.first > maxX) ? i.first : maxX
        maxY = (i.second > maxY) ? i.second : maxY
        minX = (i.first < minX) ? i.first : minX
        minY = (i.second < minY) ? i.second : minY
    end

    return minX, maxX, minY, maxY
end

@inline function holes(p::Poly)
    return p.edges - p.vertices - length(p.tiles) + 1  # number of holes with euler characteristic
end

function demo()
    println("<Polyomino Generation (n = 30)>")

    println("Shuffling (p = 0):")
    show(Poly(30, 0.0))

    println("Shuffling (p = 0.8):")
    show(Poly(30, 0.8))

    println("Eden Model:")
    show(Poly(30))

    println("<Polyomino Analysis (n = 100)>")
    poly = Poly(100)

    println("Maximal Rook Setup:")
    printSet(poly, maxRooks(poly)[2])

    println("Maximal Queen Setup:")
    printSet(poly, maxQueens(poly, false)[2])

    println("Minimal Rook Setup:")
    printSet(poly, minRooks(poly, false)[2])

    println("Minimal Queen Setup:")
    printSet(poly, minQueens(poly, false)[2])

    println("Minimal Line Cover:")
    printMinLineCover(poly)
end


"""
    Poly(size, p)

Polyomino generation wih shuffling model

Generates uniformly distributed polyominoes after size^3 successful shuffles.

# Arguments
* `size`: Number of tiles of polyomino
* `p`: Perculation probability between 0 and 1, higher p results in more compact polyominoes
"""
function Poly(size::Int64, p::Float64)
    tiles = Set{Pair{Int64, Int64}}()
    neighbours = Set{Pair{Int64, Int64}}([0 => 0, 0 => size + 1])
    for i in 1:size
        push!(tiles, 0 => i)
        push!(neighbours, 1 => i)
        push!(neighbours, -1 => i)
    end

    euler = [2 * size + 2, (2 * size + 2) + (size - 1)] # vertices, edges

    @showprogress 1 "Shuffling..." for i in 1 : size^3
        while (!shuffle(tiles, neighbours, p, euler))
        end
    end

    Poly(tiles, euler[1], euler[2])
end

@inline function shuffle(tiles::Set{Pair{Int64, Int64}}, neighbours::Set{Pair{Int64, Int64}}, p::Float64, euler::Vector{Int64})
    diff = 0  # circumfrence difference
    vertexDiff = 0
    edgeDiff = 0

    ranTile = rand(tiles)  # move random tile to new position
    ranNeigh = rand(neighbours)
    delete!(tiles, ranTile)

    # vertex update from tile remval
    if !(Pair(ranTile.first - 1, ranTile.second) in tiles) && !(Pair(ranTile.first - 1, ranTile.second - 1) in tiles) && !(Pair(ranTile.first, ranTile.second - 1) in tiles)  # left upper corner
        vertexDiff -= 1
    end
    if !(Pair(ranTile.first, ranTile.second - 1) in tiles) && !(Pair(ranTile.first + 1, ranTile.second - 1) in tiles) && !(Pair(ranTile.first + 1, ranTile.second) in tiles)  # left lower corner
        vertexDiff -= 1
    end
    if !(Pair(ranTile.first + 1, ranTile.second) in tiles) && !(Pair(ranTile.first + 1, ranTile.second + 1) in tiles) && !(Pair(ranTile.first, ranTile.second + 1) in tiles)  # right lower corner
        vertexDiff -= 1
    end
    if !(Pair(ranTile.first, ranTile.second + 1) in tiles) && !(Pair(ranTile.first - 1, ranTile.second + 1) in tiles) && !(Pair(ranTile.first - 1, ranTile.second) in tiles)  # right upper corner
        vertexDiff -= 1
    end

    # vertex change from tile addition
    if !(Pair(ranNeigh.first - 1, ranNeigh.second) in tiles) && !(Pair(ranNeigh.first - 1, ranNeigh.second - 1) in tiles) && !(Pair(ranNeigh.first, ranNeigh.second - 1) in tiles)  # left upper corner
        vertexDiff += 1
    end
    if !(Pair(ranNeigh.first, ranNeigh.second - 1) in tiles) && !(Pair(ranNeigh.first + 1, ranNeigh.second - 1) in tiles) && !(Pair(ranNeigh.first + 1, ranNeigh.second) in tiles)  # left lower corner
        vertexDiff += 1
    end
    if !(Pair(ranNeigh.first + 1, ranNeigh.second) in tiles) && !(Pair(ranNeigh.first + 1, ranNeigh.second + 1) in tiles) && !(Pair(ranNeigh.first, ranNeigh.second + 1) in tiles)  # right lower corner
        vertexDiff += 1
    end
    if !(Pair(ranNeigh.first, ranNeigh.second + 1) in tiles) && !(Pair(ranNeigh.first - 1, ranNeigh.second + 1) in tiles) && !(Pair(ranNeigh.first - 1, ranNeigh.second) in tiles)  # right upper corner
        vertexDiff += 1
    end

    #edge change from tile removal
    edgeDiff -= !(Pair(ranTile.first - 1, ranTile.second) in tiles) + !(Pair(ranTile.first, ranTile.second - 1) in tiles) + !(Pair(ranTile.first + 1, ranTile.second) in tiles) + !(Pair(ranTile.first, ranTile.second + 1) in tiles)
    #edge change from tile addition
    edgeDiff += !(Pair(ranNeigh.first - 1, ranNeigh.second) in tiles) + !(Pair(ranNeigh.first, ranNeigh.second - 1) in tiles) + !(Pair(ranNeigh.first + 1, ranNeigh.second) in tiles) + !(Pair(ranNeigh.first, ranNeigh.second + 1) in tiles)

    push!(tiles, ranNeigh)

    toCheck = Pair{Int64, Int64}[]  # collect neighbours to check connectivity
    if ((Pair(ranTile.first - 1, ranTile.second) in tiles))
        push!(toCheck, Pair(ranTile.first - 1, ranTile.second))
        diff += 1
    end
    if ((Pair(ranTile.first, ranTile.second - 1) in tiles))
        push!(toCheck, Pair(ranTile.first, ranTile.second - 1))
        diff += 1
    end
    if ((Pair(ranTile.first + 1, ranTile.second) in tiles))
        push!(toCheck, Pair(ranTile.first + 1, ranTile.second))
        diff += 1
    end
    if ((Pair(ranTile.first, ranTile.second + 1) in tiles))
        push!(toCheck, Pair(ranTile.first, ranTile.second + 1))
        diff += 1
    end

    connected = true  # check connectivity
    for i = 1 : length(toCheck) - 1
        if !(bfs(tiles, toCheck[i], toCheck[i + 1]))
            connected = false
            break
        end
    end

    if (connected)
        if ((Pair(ranNeigh.first - 1, ranNeigh.second) in tiles))  # calculate diffrence in polyomino neighbour count
            diff -= 1
        end
        if ((Pair(ranNeigh.first, ranNeigh.second - 1) in tiles))
            diff -= 1
        end
        if ((Pair(ranNeigh.first + 1, ranNeigh.second) in tiles))
            diff -= 1
        end
        if ((Pair(ranNeigh.first, ranNeigh.second + 1) in tiles))
            diff -= 1
        end

        accepted = true  # accepted shuffle with probability (1 - p)^diff
        if !iszero(p)
            accepted = rand() < (1 - p)^diff;
        end

        if accepted
            push!(neighbours, ranTile)

            if (!(Pair(ranTile.first - 1, ranTile.second - 1) in tiles) && !(Pair(ranTile.first - 2, ranTile.second) in tiles) && !(Pair(ranTile.first - 1, ranTile.second + 1) in tiles))
                delete!(neighbours, Pair(ranTile.first - 1, ranTile.second))  # neighbour above does not stay neighbour
            end
            if (!(Pair(ranTile.first + 1, ranTile.second - 1) in tiles) && !(Pair(ranTile.first, ranTile.second - 2) in tiles) && !(Pair(ranTile.first - 1, ranTile.second - 1) in tiles))
                delete!(neighbours, Pair(ranTile.first, ranTile.second - 1))  # neighbour to the left does not stay neighbour
            end
            if (!(Pair(ranTile.first + 1, ranTile.second + 1) in tiles) && !(Pair(ranTile.first + 2, ranTile.second) in tiles) && !(Pair(ranTile.first + 1, ranTile.second - 1) in tiles))
                delete!(neighbours, Pair(ranTile.first + 1, ranTile.second))  # neighbour below does not stay neighbour
            end
            if (!(Pair(ranTile.first - 1, ranTile.second + 1) in tiles) && !(Pair(ranTile.first, ranTile.second + 2) in tiles) && !(Pair(ranTile.first + 1, ranTile.second + 1) in tiles))
                delete!(neighbours, Pair(ranTile.first, ranTile.second + 1))  # neighbour to the right does not stay neighbour
            end

            delete!(neighbours, ranNeigh)  # update neighbours
            if (!(Pair(ranNeigh.first - 1, ranNeigh.second) in tiles))
                push!(neighbours, Pair(ranNeigh.first - 1, ranNeigh.second))
            end
            if (!(Pair(ranNeigh.first, ranNeigh.second - 1) in tiles))
                push!(neighbours, Pair(ranNeigh.first, ranNeigh.second - 1))
            end
            if (!(Pair(ranNeigh.first + 1, ranNeigh.second) in tiles))
                push!(neighbours, Pair(ranNeigh.first + 1, ranNeigh.second))
            end
            if (!(Pair(ranNeigh.first, ranNeigh.second + 1) in tiles))
                push!(neighbours, Pair(ranNeigh.first, ranNeigh.second + 1))
            end

            euler[1] += vertexDiff
            euler[2] += edgeDiff

            return true
        end
    end

    delete!(tiles, ranNeigh)  # undo shuffle
    push!(tiles, ranTile)

    return false
end

@inline function bfs(tiles::Set{Pair{Int64, Int64}}, start::Pair{Int64, Int64}, goal::Pair{Int64, Int64})
    if (abs(start.first - goal.first) == 1 && abs(start.second - goal.second) == 1)  # start and goal directly connect via corner
        if Pair(start.first, goal.second) in tiles
            return true
        elseif Pair(goal.first, start.second) in tiles
            return true
        end
    end

    q = Queue{Pair{Int64, Int64}}()
    done = Set{Pair{Int64, Int64}}()
    enqueue!(q, start); push!(done, start)

    while (!isempty(q))
        tile = dequeue!(q)
        if (tile == goal)
            return true
        end

        if ((Pair(tile.first - 1, tile.second) in tiles) && !(Pair(tile.first - 1, tile.second) in done))  # above
            enqueue!(q, Pair(tile.first - 1, tile.second))
            push!(done, Pair(tile.first - 1, tile.second))
        end
        if ((Pair(tile.first, tile.second - 1) in tiles) && !(Pair(tile.first, tile.second - 1) in done))  # left
            enqueue!(q, Pair(tile.first, tile.second - 1))
            push!(done, Pair(tile.first, tile.second - 1))
        end
        if ((Pair(tile.first + 1, tile.second) in tiles) && !(Pair(tile.first + 1, tile.second) in done))  # below
            enqueue!(q, Pair(tile.first + 1, tile.second))
            push!(done, Pair(tile.first + 1, tile.second))
        end
        if ((Pair(tile.first, tile.second + 1) in tiles) && !(Pair(tile.first, tile.second + 1) in done))  # right
            enqueue!(q, Pair(tile.first, tile.second + 1))
            push!(done, Pair(tile.first, tile.second + 1))
        end
    end

    return false
end


"""
    Poly(size)

Polyomino generation wih Eden model

Start with one tile and iteratively add random neighbour tile. Linear runtime, but compact polyominoes with few holes.

# Arguments
* `size`: Number of tiles of polyomino
"""
function Poly(size::Int64)
    tiles = Set{Pair{Int64, Int64}}([0 => 0])
    neighbours = Set{Pair{Int64, Int64}}([-1 => 0, 0 => -1, 1 => 0, 0 => 1])

    vertices = 0
    edges = 0

    for i in 1 : size - 1
        ranElem = rand(neighbours)  # choose random element from set
        push!(tiles, ranElem)
        delete!(neighbours, ranElem)

        # edge update
        edges += !(Pair(ranElem.first - 1, ranElem.second) in tiles) + !(Pair(ranElem.first, ranElem.second - 1) in tiles) + !(Pair(ranElem.first + 1, ranElem.second) in tiles) + !(Pair(ranElem.first, ranElem.second + 1) in tiles)

        # vertex update
        if !(Pair(ranElem.first - 1, ranElem.second) in tiles) && !(Pair(ranElem.first - 1, ranElem.second - 1) in tiles) && !(Pair(ranElem.first, ranElem.second - 1) in tiles)  # left upper corner
            vertices += 1
        end
        if !(Pair(ranElem.first, ranElem.second - 1) in tiles) && !(Pair(ranElem.first + 1, ranElem.second - 1) in tiles) && !(Pair(ranElem.first + 1, ranElem.second) in tiles)  # left lower corner
            vertices += 1
        end
        if !(Pair(ranElem.first + 1, ranElem.second) in tiles) && !(Pair(ranElem.first + 1, ranElem.second + 1) in tiles) && !(Pair(ranElem.first, ranElem.second + 1) in tiles)  # right lower corner
            vertices += 1
        end
        if !(Pair(ranElem.first, ranElem.second + 1) in tiles) && !(Pair(ranElem.first - 1, ranElem.second + 1) in tiles) && !(Pair(ranElem.first - 1, ranElem.second) in tiles)  # right upper corner
            vertices += 1
        end

        !(Pair(ranElem.first - 1, ranElem.second) in tiles) && push!(neighbours, Pair(ranElem.first - 1, ranElem.second))  # update neighbours set
        !(Pair(ranElem.first, ranElem.second - 1) in tiles) && push!(neighbours, Pair(ranElem.first, ranElem.second - 1))
        !(Pair(ranElem.first + 1, ranElem.second) in tiles) && push!(neighbours, Pair(ranElem.first + 1, ranElem.second))
        !(Pair(ranElem.first, ranElem.second + 1) in tiles) && push!(neighbours, Pair(ranElem.first, ranElem.second + 1))
    end

    Poly(tiles, vertices, edges)
end

end # module
