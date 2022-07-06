module Polyomino

using DataStructures
using MatrixNetworks
using Combinatorics

struct Poly
    tiles::Set{Pair{Int64, Int64}}
end

include("max-rooks.jl")
include("min-rooks.jl")
include("min-queens.jl")
include("min-line-cover.jl")

"""
Polyomino generation - Shuffling
 - Shuffling algorithm for uniformly distributed polyominoes after size^3 successful shuffles
 - Probability p with perculation model, higher p creates more compact polyominoes
 - Verify polyomino stays connected after shuffle with breath first search
"""
function Poly(size::Int64, p::Float64)
    tiles = Set{Pair{Int64, Int64}}()
    neighbours = Set{Pair{Int64, Int64}}([0 => 0, 0 => size + 1])
    for i in 1:size
        push!(tiles, 0 => i)
        push!(neighbours, 1 => i)
        push!(neighbours, -1 => i)
    end

    shuffles = 0
    while (shuffles < size ^ 3)
        if (shuffle(tiles, neighbours, p))
            shuffles += 1
        end
    end

    Poly(tiles)
end


"""
Polyomino generation - Eden model
"""
function Poly(size::Int64)
    tiles = Set{Pair{Int64, Int64}}([0 => 0])
    neighbours = Set{Pair{Int64, Int64}}([-1 => 0, 0 => -1, 1 => 0, 0 => 1])

    for i in 1 : size - 1
        ranElem = rand(neighbours)  # choose random element from set
        push!(tiles, ranElem)
        delete!(neighbours, ranElem)

        !(Pair(ranElem.first - 1, ranElem.second) in tiles) && push!(neighbours, Pair(ranElem.first - 1, ranElem.second))  # update neighbours set
        !(Pair(ranElem.first, ranElem.second - 1) in tiles) && push!(neighbours, Pair(ranElem.first, ranElem.second - 1))
        !(Pair(ranElem.first + 1, ranElem.second) in tiles) && push!(neighbours, Pair(ranElem.first + 1, ranElem.second))
        !(Pair(ranElem.first, ranElem.second + 1) in tiles) && push!(neighbours, Pair(ranElem.first, ranElem.second + 1))
    end

    Poly(tiles)
end


"""
Pretty print polyomino
"""
Base.show(io::IO, x::Poly) = begin
    minX, maxX, minY, maxY =  dimensionPoly(x)

    for i in minX:maxX
        for j in minY:maxY
            (Pair(i, j) in x.tiles) ? print(io, "*") : print(io, " ")
        end
        println()
    end
end


"""
Polyomino dimensions
"""
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


"""
Breadth first search
"""
@inline function bfs(tiles::Set{Pair{Int64, Int64}}, start::Pair{Int64, Int64}, goal::Pair{Int64, Int64})
    if (abs(start.first - goal.first) == 1 && abs(start.second - goal.second) == 1)  # corner
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

                    
@inline function shuffle(tiles::Set{Pair{Int64, Int64}}, neighbours::Set{Pair{Int64, Int64}}, p::Float64)
    diff = 0

    ranTile = rand(tiles)  # move random tile to new position
    ranNeigh = rand(neighbours)
    delete!(tiles, ranTile)
    push!(tiles, ranNeigh)

    toCheck = Pair{Int64, Int64}[]  # collect tiles to check connectivity
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
        if (p != 0)
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

            return true
        end
    end

    delete!(tiles, ranNeigh)  # undo shuffle
    push!(tiles, ranTile)

    return false
end


function demo()
    println("<Polyomino Generation (n = 30)>")

    println("Shuffling (p = 0):")
    show(Poly(30, 0.0))

    println("Shuffling (p = 0.8):")
    show(Poly(30, 0.8))

    println("Eden Model:")
    show(Poly(30))

    println("<Polyomino Analysis>")
    polyomino = Poly(30, 0.6)

    println("Minimal Rook Setup:")
    printMinRooks(polyomino)

    println("Maximal Rook Setup:")
    printMaxRooks(polyomino)

    println("Minimal Line Cover:")
    printMinLineCover(polyomino)
end

end #module
