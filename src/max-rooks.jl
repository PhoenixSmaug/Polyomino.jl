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