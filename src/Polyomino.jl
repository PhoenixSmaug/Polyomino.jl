module Polyomino

using DataStructures
using MatrixNetworks
using Combinatorics

"""
Functionality Demo
"""
function demo()
    println("<Polyomino Generation (n = 30)>")

    println("Shuffling (p = 0):")
    show(Poly(30, 0.0, true))

    println("Shuffling (p = 0.8):")
    show(Poly(30, 0.8, true))

    println("Eden Model:")
    show(Poly(30, 0.0, false))

    println("<Polyomino Analysis>")
    polyomino = Poly(30, 0.6, true)

    println("Minimal Rook Setup:")
    printMinRooks(polyomino)

    println("Maximal Rook Setup:")
    printMaxRooks(polyomino)

    println("Minimal Line Cover:")
    printMinLineCover(polyomino)
end


"""
<< Polyomino definition and generation >>
"""

struct Poly
    tiles::Set{Pair{Int64, Int64}}
end


"""
Polyomino generation
 - Shuffling algorithm for uniformly distributed polyominoes after size^3 successful shuffles
 - Probability p with perculation model, higher p creates more compact polyominoes
 - Verify polyomino stays connected after shuffle with breath first search
 - Without suffling simple eden model is used
"""
function Poly(size::Int64, p::Float64, shuffling::Bool)
    if shuffling
        tiles = Set{Pair{Int64, Int64}}()
        neighbours = Set{Pair{Int64, Int64}}([0 => 0, 0 => size + 1])
        for i in 1:size
            push!(tiles, 0 => i)
            push!(neighbours, 1 => i)
            push!(neighbours, -1 => i)
        end

        shuffles = 0
        while (shuffles < size ^ 3)
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
                    shuffles += 1
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
                else
                    delete!(tiles, ranNeigh)  # undo shuffle
                    push!(tiles, ranTile)
                end
            else
                delete!(tiles, ranNeigh)  # undo shuffle
                push!(tiles, ranTile)
            end
        end
    else
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
    end

    Poly(tiles)
end


"""
<< Algorithms >>
"""


"""
Maximal Number of Non-Attacking Rooks
 - Equal to size of maximal matching in bipartite graph
 - Algorithm for bipartite graph in https://link.springer.com/content/pdf/10.1007/s00373-020-02272-8.pdf Chapter 4
"""
function maxRooks(p::Poly)
    minX, maxX, minY, maxY =  dimensionPoly(p)

    firstCoord = Dict{Pair{Int64, Int64}, Int64}()
    counter = 0
    previous = false
    for i in minX - 1 : maxX + 1
        for j in minY - 1 : maxY + 1
            if (Pair(i, j) in p.tiles)
                if (!previous) counter += 1 end
                firstCoord[i => j] = counter
                previous = true
            else
                previous = false
            end
        end
    end

    secondCoord = Dict{Pair{Int64, Int64}, Int64}()
    counter = 0
    previous = false
    for j in minY - 1 : maxY + 1
        for i in minX - 1 : maxX + 1
            if (Pair(i, j) in p.tiles)
                if (!previous) counter += 1 end
                secondCoord[i => j] = counter
                previous = true
            else
                previous = false
            end
        end
    end

    edgeStart = Int64[]; edgeEnd = Int64[]
    biGraphOrder = Dict{Pair{Int64, Int64}, Pair{Int64, Int64}}()  # remember which tile corresponds to edge

    for i in minX : maxX
        for j in minY : maxY
            if (Pair(i, j) in p.tiles)
                push!(edgeStart, firstCoord[i => j])
                push!(edgeEnd, secondCoord[i => j])
                biGraphOrder[Pair(firstCoord[i => j], secondCoord[i => j])] = i => j
            end
        end
    end

    weights = fill(1, length(edgeStart))
    matching = bipartite_matching(weights, edgeStart, edgeEnd)
    matchingStart = edge_list(matching)[1]
    matchingEnd = edge_list(matching)[2]

    rooks = Pair{Int64, Int64}[]
    for i in 1 : length(matchingStart)
        push!(rooks, biGraphOrder[Pair(matchingStart[i], matchingEnd[i])])
    end

    return matching.cardinality, rooks
end


"""
Minimal Number of Guarding Non-Attacking Rooks
 - NP complete problem
 - Check solutions encoded as bitset
 - Runtime size * 2^size, try big polyominos with caution
 - Recommendations: Eden Model (<= 70), Shuffeling p = 0.6 (<= 50)
"""
function minRooks(p::Poly)
    if (length(p.tiles) > 127)
        error("Polyomino with size " * string(length(p.tiles)) * " too big to analyze.")
    end

    tileId = Dict{Pair{Int128, Int128}, Int128}()  # enumerate rooks
    tileIdRev = Pair{Int128, Int128}[]
    t = 1
    for i in p.tiles
        tileId[i] = t
        push!(tileIdRev, i)
        t += 1
    end

    # convert situation to bitset with Int64, if tile with tileId idB can be attacked from idA, turn (idB - 1) bit on
    bitset = fill(0, length(p.tiles))
    for (key, value) in tileId
        bitset[value] = bitset[value] | (1 << (value - 1))

        t = 1
        while (Pair(key.first - t, key.second) in p.tiles)  # up
            bitset[value] = bitset[value] | (1 << (tileId[Pair(key.first - t, key.second)] - 1))
            t += 1
        end
        t = 1
        while (Pair(key.first, key.second - t) in p.tiles)  # left
            bitset[value] = bitset[value] | (1 << (tileId[Pair(key.first, key.second - t)] - 1))
            t += 1
        end
        t = 1
        while (Pair(key.first + t, key.second) in p.tiles)  # down
            bitset[value] = bitset[value] | (1 << (tileId[Pair(key.first + t, key.second)] - 1))
            t += 1
        end
        t = 1
        while (Pair(key.first, key.second + t) in p.tiles)  # right
            bitset[value] = bitset[value] | (1 << (tileId[Pair(key.first, key.second + t)] - 1))
            t += 1
        end
    end

    bitsetOrder = Dict{Int128, Int128}()
    t = 1  # remember which bitset is which tile
    for i in bitset
        bitsetOrder[i] = t
        t += 1
    end

    bitset = unique(bitset)  # reduce symmetrical rooks

    bitsetCollector = Set{Int64}(bitset)  # filter out irrelevant rooks
    bitsetCollectorCopy = copy(bitsetCollector)

    for i in bitsetCollectorCopy
        for j in bitsetCollectorCopy
            if (i != j)
                if (j == j | i)
                    delete!(bitsetCollector, i)  # if another tile guards at least every tile the first tile guards
                end
            end
        end
    end

    empty!(bitset)
    for i in bitsetCollector
        push!(bitset, i)
    end

    max, maxSetup = maxRooks(p)  # the paper proves maxRooks/2 <= minRooks <= maxRooks

    guarded = (1 << length(p.tiles)) - 1
    for i = ceil(Int, max / 2) : max - 1
        for j in combinations(bitset, i)  # loop trough all possibilities to place i rooks
            sum = 0
            for h in j  # collect all tiles that are guarded by current rook placement
                sum |= h
            end

            if (sum == guarded)  # if sum is "1111...111", so all tiles are guarded
                rooks = Pair{Int64, Int64}[]
                for h in j
                    push!(rooks, tileIdRev[bitsetOrder[h]])  # retranslate bitset to original tile
                end

                return i, rooks
            end
        end
    end

    return max, maxSetup
end


"""
Minimal Number of Guarding Non-Attacking Queens
 - NP complete problem
 - Check solutions encoded as bitset
 - Runtime size * 2^size, try big polyominos with caution
 - Recommendations: Eden Model (<= 80), Shuffeling p = 0.6 (<= 60)
"""
function minQueens(p::Poly)
    if (length(p.tiles) > 127)
        error("Polyomino with size " * string(length(p.tiles)) * " too big to analyze.")
    end

    tileId = Dict{Pair{Int128, Int128}, Int128}()  # enumerate queens
    tileIdRev = Pair{Int128, Int128}[]
    t = 1
    for i in p.tiles
        tileId[i] = t
        push!(tileIdRev, i)
        t += 1
    end

    # convert situation to bitset with Int64, if tile with tileId idB can be attacked from idA, turn (idB - 1) bit on
    bitset = fill(0, length(p.tiles))
    for (key, value) in tileId
        bitset[value] = bitset[value] | (1 << (value - 1))

        t = 1
        while (Pair(key.first - t, key.second) in p.tiles)  # up
            bitset[value] = bitset[value] | (1 << (tileId[Pair(key.first - t, key.second)] - 1))
            t += 1
        end
        t = 1
        while (Pair(key.first - t, key.second - t) in p.tiles)  # up left
            bitset[value] = bitset[value] | (1 << (tileId[Pair(key.first - t, key.second - t)] - 1))
            t += 1
        end
        t = 1
        while (Pair(key.first, key.second - t) in p.tiles)  # left
            bitset[value] = bitset[value] | (1 << (tileId[Pair(key.first, key.second - t)] - 1))
            t += 1
        end
        t = 1
        while (Pair(key.first + t, key.second - t) in p.tiles)  # down left
            bitset[value] = bitset[value] | (1 << (tileId[Pair(key.first + t, key.second - t)] - 1))
            t += 1
        end
        t = 1
        while (Pair(key.first + t, key.second) in p.tiles)  # down
            bitset[value] = bitset[value] | (1 << (tileId[Pair(key.first + t, key.second)] - 1))
            t += 1
        end
        t = 1
        while (Pair(key.first + t, key.second + t) in p.tiles)  # down right
            bitset[value] = bitset[value] | (1 << (tileId[Pair(key.first + t, key.second + t)] - 1))
            t += 1
        end
        t = 1
        while (Pair(key.first, key.second + t) in p.tiles)  # right
            bitset[value] = bitset[value] | (1 << (tileId[Pair(key.first, key.second + t)] - 1))
            t += 1
        end
        t = 1
        while (Pair(key.first - t, key.second + t) in p.tiles)  # up right
            bitset[value] = bitset[value] | (1 << (tileId[Pair(key.first - t, key.second + t)] - 1))
            t += 1
        end
    end

    bitsetOrder = Dict{Int128, Int128}()
    t = 1  # remember which bitset is which tile
    for i in bitset
        bitsetOrder[i] = t
        t += 1
    end

    bitset = unique(bitset)  # reduce symmetrical queens

    bitsetCollector = Set{Int64}(bitset)  # filter out irrelevant queens
    bitsetCollectorCopy = copy(bitsetCollector)

    for i in bitsetCollectorCopy
        for j in bitsetCollectorCopy
            if (i != j)
                if (j == j | i)
                    delete!(bitsetCollector, i)  # if another tile guards at least every tile the first tile guards
                end
            end
        end
    end

    empty!(bitset)
    for i in bitsetCollector
        push!(bitset, i)
    end

    guarded = (1 << length(p.tiles)) - 1
    for i = 1 : length(p.tiles)
        for j in combinations(bitset, i)  # loop trough all possibilities to place i queens
            sum = 0
            for h in j  # collect all tiles that are guarded by current queen placement
                sum |= h
            end

            if (sum == guarded)  # if sum is "1111...111", so all tiles are guarded
                queens = Pair{Int64, Int64}[]
                for h in j
                    push!(queens, tileIdRev[bitsetOrder[h]])  # retranslate bitset to original tile
                end

                return i, queens
            end
        end
    end
end


"""
Convert to Minimal Line Cover (MLC)
 - Find maximal rook setup
 - Loop trough rooks, draw vertical and horizontal line through each rook, find polyomino tiles which are only part of one line
 - Add All Lines which have tiles for which they are the only lines to the MLC, Repeat last step
 - If all polyomino tiles are part of two lines, for one random rook add horizontal line to MLC, Repeat until no rooks left
"""
function minLineCover(p::Poly)
    _, rooksVec = maxRooks(p)
    rooks = Set(rooksVec)
    minLineCover = Set{Array{Pair{Int64, Int64}}}()
    done = Set{Pair{Int64, Int64}}()

    while (!isempty(rooks))
        tilesOneLine = Set{Pair{Int64, Int64}}()  # find all tiles with only one line through them, step (A)
        for i in rooks
            t = 1
            while (Pair(i.first - t, i.second) in p.tiles)  # up
                (Pair(i.first - t, i.second) in tilesOneLine) ? delete!(tilesOneLine, Pair(i.first - t, i.second)) : push!(tilesOneLine, Pair(i.first - t, i.second))
                t += 1
            end
            t = 1
            while (Pair(i.first, i.second - t) in p.tiles)  # left
                (Pair(i.first, i.second - t) in tilesOneLine) ? delete!(tilesOneLine, Pair(i.first, i.second - t)) : push!(tilesOneLine, Pair(i.first, i.second - t))
                t += 1
            end
            t = 1
            while (Pair(i.first + t, i.second) in p.tiles)  # down
                (Pair(i.first + t, i.second) in tilesOneLine) ? delete!(tilesOneLine, Pair(i.first + t, i.second)) : push!(tilesOneLine, Pair(i.first + t, i.second))
                t += 1
            end
            t = 1
            while (Pair(i.first, i.second + t) in p.tiles)  # right
                (Pair(i.first, i.second + t) in tilesOneLine) ? delete!(tilesOneLine, Pair(i.first, i.second + t)) : push!(tilesOneLine, Pair(i.first, i.second + t))
                t += 1
            end
        end

        setdiff!(tilesOneLine, done)  # remove all tiles already in the MLC

        if (isempty(tilesOneLine))
            ranRook = first(rooks)  # any rook can be choosen
            up = Pair{Int64, Int64}[]; left = Pair{Int64, Int64}[]; down = Pair{Int64, Int64}[]; right = Pair{Int64, Int64}[];

            t = 1
            while (Pair(ranRook.first - t, ranRook.second) in p.tiles)  # up
                push!(up, Pair(ranRook.first - t, ranRook.second))
                t += 1
            end
            t = 1
            while (Pair(ranRook.first, ranRook.second - t) in p.tiles)  # left
                push!(left, Pair(ranRook.first, ranRook.second - t))
                t += 1
            end
            t = 1
            while (Pair(ranRook.first + t, ranRook.second) in p.tiles)  # down
                push!(down, Pair(ranRook.first + t, ranRook.second))
                t += 1
            end
            t = 1
            while (Pair(ranRook.first, ranRook.second + t) in p.tiles)  # right
                push!(right, Pair(ranRook.first, ranRook.second + t))
                t += 1
            end

            row = Pair{Int64, Int64}[]; column = Pair{Int64, Int64}[];  # combine parts into vertical and horizontal line
            for i in length(left) : -1 : 1
                push!(row, left[i])
            end
            push!(row, ranRook)
            for i in 1 : length(right)
                push!(row, right[i])
            end
            for i in length(up) : -1 : 1
                push!(column, up[i])
            end
            push!(column, ranRook)
            for i in 1 : length(down)
                push!(column, down[i])
            end

            if (length(row) != 1)
                push!(minLineCover, row)
                for i in row
                    push!(done, i)
                end
            else
                push!(minLineCover, column)
                for i in column
                    push!(done, i)
                end
            end

            delete!(rooks, ranRook)
        else
            rooksCopy = copy(rooks)  # prevent change of the object the for loop is iterating on

            for i in rooksCopy
                horizontal = false; vertical = false
                up = Pair{Int64, Int64}[]; left = Pair{Int64, Int64}[]; down = Pair{Int64, Int64}[]; right = Pair{Int64, Int64}[];

                t = 1
                while (Pair(i.first, i.second - t) in p.tiles)
                    push!(left, Pair(i.first, i.second - t))
                    if (Pair(i.first, i.second - t) in tilesOneLine)
                        horizontal = true
                    end
                    t += 1
                end
                t = 1
                while (Pair(i.first, i.second + t) in p.tiles)
                    push!(right, Pair(i.first, i.second + t))
                    if (Pair(i.first, i.second + t) in tilesOneLine)
                        horizontal = true
                    end
                    t += 1
                end
                t = 1
                while (Pair(i.first - t, i.second) in p.tiles)
                    push!(up, Pair(i.first - t, i.second))
                    if (Pair(i.first - t, i.second) in tilesOneLine)
                        vertical = true
                    end
                    t += 1
                end
                t = 1
                while (Pair(i.first + t, i.second) in p.tiles)
                    push!(down, Pair(i.first + t, i.second))
                    if (Pair(i.first + t, i.second) in tilesOneLine)
                        vertical = true
                    end
                    t += 1
                end

                row = Pair{Int64, Int64}[]; column = Pair{Int64, Int64}[];  # combine parts into vertical and horizontal line
                for j in length(left) : -1 : 1
                    push!(row, left[j])
                end
                push!(row, i)
                for j in 1 : length(right)
                    push!(row, right[j])
                end
                for j in length(up) : -1 : 1
                    push!(column, up[j])
                end
                push!(column, i)
                for j in 1 : length(down)
                    push!(column, down[j])
                end

                if (length(column) == 1 || horizontal)
                    push!(minLineCover, row)
                    for j in row
                        push!(done, j)
                    end
                    delete!(rooks, i)
                end
                if (length(row) == 1 || vertical)
                    push!(minLineCover, column)
                    for j in column
                        push!(done, j)
                    end
                    delete!(rooks, i)
                end
            end
        end
    end

    return minLineCover
end


"""
<< Pretty print >>
"""


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
Pretty Print Max Rook Setup
"""
function printMaxRooks(p::Poly)
    _, rooks = maxRooks(p)

    minX, maxX, minY, maxY =  dimensionPoly(p)

    for i in minX:maxX
        for j in minY:maxY
            if (Pair(i, j) in p.tiles)
                (Pair(i, j) in rooks) ? print("+") : print("*")
            else
                print(" ")
            end
        end
        println()
    end
end


"""
Pretty Print Min Rook Setup
"""
function printMinRooks(p::Poly)
    _, rooks = minRooks(p)

    minX, maxX, minY, maxY =  dimensionPoly(p)

    for i in minX:maxX
        for j in minY:maxY
            if (Pair(i, j) in p.tiles)
                (Pair(i, j) in rooks) ? print("+") : print("*")
            else
                print(" ")
            end
        end
        println()
    end
end


"""
Pretty Print Min Queen Setup
"""
function printMinQueens(p::Poly)
    _, queens = minQueens(p)

    minX, maxX, minY, maxY =  dimensionPoly(p)

    for i in minX:maxX
        for j in minY:maxY
            if (Pair(i, j) in p.tiles)
                (Pair(i, j) in queens) ? print("+") : print("*")
            else
                print(" ")
            end
        end
        println()
    end
end


"""
Pretty Print Minimal Line Cover
 - "-" if tile is part of horizontal line, "|" if tile is part of vertical line, "+" if both
"""
function printMinLineCover(p::Poly)
    minLineCover = minLineCover(p)

    minX, maxX, minY, maxY =  dimensionPoly(p)

    for i in minX:maxX
        for j in minY:maxY
            isRow = false; isColumn = false;
            for k in minLineCover
                for l in 1:length(k)
                    if (k[l].first == i && k[l].second == j)
                        if (k[l].first == k[l % length(k) + 1].first)
                            isColumn = true;
                        end
                        if (k[l].second == k[l % length(k) + 1].second)
                            isRow = true;
                        end
                    end
                end
            end

            if (isRow && isColumn)
                print("+")
            elseif (isRow)
                print("|")
            elseif (isColumn)
                print("-")
            elseif (Pair(i, j) in p.tiles)
                print("X")
            else
                print(" ")
            end
        end
        println()
    end
end

"""
<< Game functions >>
"""


"""
Format Polyomino for the game
- Verify Polyomino fits in 32 x 18 grid
- Translate to (0, 0) as (minX, minY)
"""
function formatPoly(p::Poly)
    minX, maxX, minY, maxY =  dimensionPoly(p)

    tiles = copy(p.tiles)
    empty!(p.tiles)
    for i in tiles
        push!(p.tiles, Pair(i.first - minX, i.second - minY))
    end

    return (maxX - minX < 17) && (maxY - minY < 31)
end


"""
Remove Tiles guarded by rook on selected position
"""
function placeRook(p::Poly, x::Int64, y::Int64)
    delete!(p.tiles, Pair(x, y))

    t = 1  # up
    while (Pair(x - t, y) in p.tiles)
        delete!(p.tiles, Pair(x - t, y))
        t += 1
    end
    t = 1  # left
    while (Pair(x, y - t) in p.tiles)
        delete!(p.tiles, Pair(x, y - t))
        t += 1
    end
    t = 1  # down
    while (Pair(x + t, y) in p.tiles)
        delete!(p.tiles, Pair(x + t, y))
        t += 1
    end
    t = 1  # right
    while (Pair(x, y + t) in p.tiles)
        delete!(p.tiles, Pair(x, y + t))
        t += 1
    end
end


"""
Remove Tiles guarded by queen on selected position
"""
function placeQueen(p::Poly, x::Int64, y::Int64)
    delete!(p.tiles, Pair(x, y))

    t = 1  # up
    while (Pair(x - t, y) in p.tiles)
        delete!(p.tiles, Pair(x - t, y))
        t += 1
    end
    t = 1  # up left
    while (Pair(x - t, y - t) in p.tiles)
        delete!(p.tiles, Pair(x - t, y - t))
        t += 1
    end
    t = 1  # left
    while (Pair(x, y - t) in p.tiles)
        delete!(p.tiles, Pair(x, y - t))
        t += 1
    end
    t = 1  # down left
    while (Pair(x + t, y - t) in p.tiles)
        delete!(p.tiles, Pair(x + t, y - t))
        t += 1
    end
    t = 1  # down
    while (Pair(x + t, y) in p.tiles)
        delete!(p.tiles, Pair(x + t, y))
        t += 1
    end
    t = 1  # down right
    while (Pair(x + t, y + t) in p.tiles)
        delete!(p.tiles, Pair(x + t, y + t))
        t += 1
    end
    t = 1  # right
    while (Pair(x, y + t) in p.tiles)
        delete!(p.tiles, Pair(x, y + t))
        t += 1
    end
    t = 1  # up right
    while (Pair(x - t, y + t) in p.tiles)
        delete!(p.tiles, Pair(x - t, y + t))
        t += 1
    end
end


"""
<< Help functions >>
"""


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

end #module
