using Pkg
#Pkg.add("DataStructures");

using DataStructures;

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
            for i = 1:length(toCheck) - 1
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

        for i in 1:size - 1
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