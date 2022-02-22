using Pkg
#Pkg.add("DataStructures");
#Pkg.add("MatrixNetworks")

using DataStructures
using MatrixNetworks

struct Polyomino
    tiles::Set{Pair{Int64, Int64}}
end


"""
Pretty Print Polyomino
 - ASCII Art: " " if tile is not in polyomino, "*" if tile is in polyomino
"""
Base.show(io::IO, x::Polyomino) = begin
    minX = typemax(Int64); minY = typemax(Int64);
    maxX = typemin(Int64); maxY = typemin(Int64);
    for i in x.tiles
        maxX = (i.first > maxX) ? i.first : maxX
        maxY = (i.second > maxY) ? i.second : maxY
        minX = (i.first < minX) ? i.first : minX
        minY = (i.second < minY) ? i.second : minY
    end

    for i in minX:maxX
        for j in minY:maxY
            (Pair(i, j) in x.tiles) ? print(io, "*") : print(io, " ")
        end
        println()
    end
end


"""
Polyomino Generation
 - Shuffling algorithm for uniformly distributed polyominoes after size^3 successful shuffles
 - Probability p with perculation model, higher p creates more compact polyominoes
 - Verify polyomino stays connected after shuffle with breath first search
 - Without suffling simple eden model is used
"""
function Polyomino(size::Int64, p::Float64, shuffling::Bool)
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

    Polyomino(tiles)
end


"""
Breadth first search
"""
function bfs(tiles::Set{Pair{Int64, Int64}}, start::Pair{Int64, Int64}, goal::Pair{Int64, Int64})
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
Maximal Number of Non-Attacking Rooks
 - Equal to size of maximal matching in bipartite graph
 - Algorithm for bipartite graph in https://link.springer.com/content/pdf/10.1007/s00373-020-02272-8.pdf Chapter 4
"""
function maxRooks(p::Polyomino)
    minX = typemax(Int64); minY = typemax(Int64);
    maxX = typemin(Int64); maxY = typemin(Int64);
    for i in p.tiles
        maxX = (i.first > maxX) ? i.first : maxX
        maxY = (i.second > maxY) ? i.second : maxY
        minX = (i.first < minX) ? i.first : minX
        minY = (i.second < minY) ? i.second : minY
    end

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
Pretty Print Max Rook Setup
 - ASCII Art: "+" if tile has rook on it, "*" if not
"""
function printMaxRooks(p::Polyomino)
    _, matching = maxRooks(p)

    minX = typemax(Int64); minY = typemax(Int64);
    maxX = typemin(Int64); maxY = typemin(Int64);
    for i in p.tiles
        maxX = (i.first > maxX) ? i.first : maxX
        maxY = (i.second > maxY) ? i.second : maxY
        minX = (i.first < minX) ? i.first : minX
        minY = (i.second < minY) ? i.second : minY
    end

    for i in minX:maxX
        for j in minY:maxY
            if (Pair(i, j) in p.tiles)
                (Pair(i, j) in matching) ? print("+") : print("*")
            else
                print(" ")
            end
        end
        println()
    end
end


"""
Minimal Number of Guarding Non-Attacking Rooks
 - NP complete problem
 - Approximate with greedy algorithm by placing rook so it guards as many new tiles as possible
"""
function minRooks(p::Polyomino)
    attackable = Dict{Pair{Int64, Int64}, Set{Pair{Int64, Int64}}}()
    rooks = Pair{Int64, Int64}[]

    for i in p.tiles
        attackable[i] = Set{Pair{Int64, Int64}}()
    end

    while (!isempty(attackable))
        for (key, value) in attackable
            attackable[key] = Set{Pair{Int64, Int64}}()
            t = 1
            while (Pair(key.first - t, key.second) in p.tiles)  # up
                push!(attackable[key], Pair(key.first - t, key.second))
                t += 1
            end
            t = 1
            while (Pair(key.first, key.second - t) in p.tiles)  # left
                push!(attackable[key], Pair(key.first, key.second - t))
                t += 1
            end
            t = 1
            while (Pair(key.first + t, key.second) in p.tiles)  # down
                push!(attackable[key], Pair(key.first + t, key.second))
                t += 1
            end
            t = 1
            while (Pair(key.first, key.second + t) in p.tiles)  # right
                push!(attackable[key], Pair(key.first, key.second + t))
                t += 1
            end
        end

        max = 0; maxEdge = Pair(0, 0)

        for (key, value) in attackable  # find edge with most neighbours
            if (length(value) >= max)
                max = length(value)
                maxEdge = key
            end
        end

        for i in attackable[maxEdge]
            delete!(attackable, i)
        end
        delete!(attackable, maxEdge)

        push!(rooks, maxEdge)
    end

    return length(rooks), rooks
end


"""
Pretty Print Min Rook Setup
 - ASCII Art: "+" if tile has rook on it, "*" if not
"""
function printMinRooks(p::Polyomino)
    _, matching = minRooks(p)

    minX = typemax(Int64); minY = typemax(Int64);
    maxX = typemin(Int64); maxY = typemin(Int64);
    for i in p.tiles
        maxX = (i.first > maxX) ? i.first : maxX
        maxY = (i.second > maxY) ? i.second : maxY
        minX = (i.first < minX) ? i.first : minX
        minY = (i.second < minY) ? i.second : minY
    end

    for i in minX:maxX
        for j in minY:maxY
            if (Pair(i, j) in p.tiles)
                (Pair(i, j) in matching) ? print("+") : print("*")
            else
                print(" ")
            end
        end
        println()
    end
end