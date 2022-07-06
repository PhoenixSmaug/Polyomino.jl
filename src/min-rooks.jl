"""
Minimal Number of Guarding Non-Attacking Rooks
 - NP complete problem
 - Check solutions encoded as bitset
 - Worst case runtime size * 2^size, try big polyominos with caution
"""
function minRooks(p::Poly)
    if (length(p.tiles) > 127)
        error("Polyomino with size " * string(length(p.tiles)) * " too big to analyze.")
    end

    tileId = Dict{Pair{Int128, Int128}, Int128}()  # enumerate tiles
    tileIdRev = Pair{Int128, Int128}[]
    t = 1
    for i in p.tiles
        tileId[i] = t
        push!(tileIdRev, i)
        t += 1
    end

    # convert situation to bitset with Int128, if tile with tileId idB can be attacked from idA, turn (idB - 1) bit on
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

    bitsetMin = unique(bitset)  # reduce symmetrical rooks

    bitsetCollector = Set{Int64}(bitsetMin)  # filter out irrelevant rooks
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

    empty!(bitsetMin)
    for i in bitsetCollector
        push!(bitsetMin, i)
    end


    forcedPlacement = Set{Array{Pair{Int64, Int64}}}()  # find list of all rook placements forced by arms of the polyomino
    for i in p.tiles
        options = optionsRook(p, i.first, i.second)
        push!(forcedPlacement, options)
    end
    delete!(forcedPlacement, Pair{Int64, Int64}[])

    guarded = (1 << length(p.tiles)) - 1
    t = 1
    while true
        for setup in Iterators.product(forcedPlacement...)
            sumPre = 0

            rooksCol = Set{Pair{Int64, Int64}}(setup)
            for i in rooksCol
                sumPre |= bitset[tileId[i]]
            end

            for i in combinations(bitsetMin, t - length(rooksCol))  # loop trough all possibilities to place the rest of the rooks
                sum = sumPre
                for h in i  # collect all tiles that are guarded by current rook placement
                    sum |= h
                end

                if (sum == guarded)  # if sum is "1111...111", so all tiles are guarded
                    rooks = Pair{Int64, Int64}[]
                    for h in i
                        push!(rooks, tileIdRev[bitsetOrder[h]])  # retranslate bitset to original tile
                    end
                    for h in rooksCol
                        push!(rooks, h)
                    end

                    return t, rooks
                end
            end
        end
        t += 1
    end
end


"""
Polyomino pattern forces rook
"""
@inline function optionsRook(p::Poly, x::Int64, y::Int64)
    options = Pair{Int64, Int64}[]

    rev = false
    if (Pair(x, y) in p.tiles)
        if ((Pair(x - 1, y) in p.tiles) && !(Pair(x, y - 1) in p.tiles) && !(Pair(x + 1, y) in p.tiles) && !(Pair(x, y + 1) in p.tiles))
            t = 1
            while (Pair(x - t, y) in p.tiles)
                if (Pair(x - t, y - 1) in p.tiles) || (Pair(x - t, y + 1) in p.tiles)
                    push!(options, Pair(x - t, y))
                end
                t += 1
            end
            rev = true
        elseif (!(Pair(x - 1, y) in p.tiles) && (Pair(x, y - 1) in p.tiles) && !(Pair(x + 1, y) in p.tiles) && !(Pair(x, y + 1) in p.tiles))
            t = 1
            while (Pair(x, y - t) in p.tiles)
                if (Pair(x - 1, y - t) in p.tiles) || (Pair(x + 1, y - t) in p.tiles)
                    push!(options, Pair(x, y - t))
                end
                t += 1
            end
            rev = true
        elseif (!(Pair(x - 1, y) in p.tiles) && !(Pair(x, y - 1) in p.tiles) && (Pair(x + 1, y) in p.tiles) && !(Pair(x, y + 1) in p.tiles))
            t = 1
            while (Pair(x + t, y) in p.tiles)
                if (Pair(x + t, y - 1) in p.tiles) || (Pair(x + t, y + 1) in p.tiles)
                    push!(options, Pair(x + t, y))
                end
                t += 1
            end
        elseif (!(Pair(x - 1, y) in p.tiles) && !(Pair(x, y - 1) in p.tiles) && !(Pair(x + 1, y) in p.tiles) && (Pair(x, y + 1) in p.tiles))
            t = 1
            while (Pair(x, y + t) in p.tiles)
                if (Pair(x - 1, y + t) in p.tiles) || (Pair(x + 1, y + t) in p.tiles)
                    push!(options, Pair(x, y + t))
                end
                t += 1
            end
        end
    end

    if (rev)
        reverse!(options)
    end

    return options
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