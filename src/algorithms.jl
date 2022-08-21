function printSet(p::Poly, set::Vector{Pair{Int64, Int64}})
    minX, maxX, minY, maxY =  dimensionPoly(p)

    for i in minX : maxX
        for j in minY : maxY
            if (Pair(i, j) in p.tiles)
                (Pair(i, j) in set) ? print("+") : print("*")
            else
                print(" ")
            end
        end
        println()
    end
end


"""
Maximal non-attacking rook set problem
 - Polynomial runtime as maximal matching in corresponding biparite graph
 - Details in https://link.springer.com/content/pdf/10.1007/s00373-020-02272-8.pdf Chapter 4
"""
function maxRooks(p::Poly)
    minX, maxX, minY, maxY =  dimensionPoly(p)
    
    start = Dict{Pair{Int64, Int64}, Int64}()  # key = position of tile, value = start of edge in bipartite graph
    counter = 0
    previous = false
    for i in minX - 1 : maxX + 1
        for j in minY - 1 : maxY + 1
            if (Pair(i, j) in p.tiles)
                if (!previous) counter += 1 end
                start[i => j] = counter
                previous = true
            else
                previous = false
            end
        end
    end

    finish = Dict{Pair{Int64, Int64}, Int64}()  # key = position of tile, value = end of edge in bipartite graph
    counter = 0
    previous = false
    for j in minY - 1 : maxY + 1
        for i in minX - 1 : maxX + 1
            if (Pair(i, j) in p.tiles)
                if (!previous) counter += 1 end
                finish[i => j] = counter
                previous = true
            else
                previous = false
            end
        end
    end

    edgeStart = Int64[]; edgeEnd = Int64[]
    biGraphOrder = Dict{Pair{Int64, Int64}, Pair{Int64, Int64}}()  # key = edge in bipartite graph, value = position of tile

    for i in minX : maxX  # convert to required form
        for j in minY : maxY
            if (Pair(i, j) in p.tiles)
                push!(edgeStart, start[i => j])
                push!(edgeEnd, finish[i => j])
                biGraphOrder[Pair(start[i => j], finish[i => j])] = i => j
            end
        end
    end
    weights = fill(1, length(edgeStart))

    matching = bipartite_matching(weights, edgeStart, edgeEnd)  # calculate matching
    matchingStart = edge_list(matching)[1]
    matchingEnd = edge_list(matching)[2]
    rooks = Pair{Int64, Int64}[]
    for i in 1 : length(matchingStart)
        push!(rooks, biGraphOrder[Pair(matchingStart[i], matchingEnd[i])])
    end

    return matching.cardinality, rooks  # number, set
end


"""
Maximal non-attacking queen set problem
- NP complete problem, solve as LIP with HiGHS optimizer
"""
function maxQueens(p::Poly)
    tileId = Dict{Pair{Int64, Int64}, Int64}()  # enumerate tiles
    tileIdRev = Pair{Int64, Int64}[]
    t = 1
    for i in p.tiles
        tileId[i] = t
        push!(tileIdRev, i)
        t += 1
    end

    tileRow = Dict{Int64, Vector{Int64}}()  # key: tile by id, value: ids of attackable tiles in this direction
    tileColumn = Dict{Int64, Vector{Int64}}()
    tileDiagDown = Dict{Int64, Vector{Int64}}()
    tileDiagUp = Dict{Int64, Vector{Int64}}()

    for (key, value) in tileId
        tileRow[value] = Vector{Int64}([value])
        tileColumn[value] = Vector{Int64}([value])
        tileDiagDown[value] = Vector{Int64}([value])
        tileDiagUp[value] = Vector{Int64}([value])

        t = 1
        while (Pair(key.first - t, key.second) in p.tiles)  # up
            push!(tileColumn[value], tileId[Pair(key.first - t, key.second)])
            t += 1
        end
        t = 1
        while (Pair(key.first - t, key.second - t) in p.tiles)  # up left
            push!(tileDiagUp[value], tileId[Pair(key.first - t, key.second - t)])
            t += 1
        end
        t = 1
        while (Pair(key.first, key.second - t) in p.tiles)  # left
            push!(tileRow[value], tileId[Pair(key.first, key.second - t)])
            t += 1
        end
        t = 1
        while (Pair(key.first + t, key.second - t) in p.tiles)  # down left
            push!(tileDiagDown[value], tileId[Pair(key.first + t, key.second - t)])
            t += 1
        end
        t = 1
        while (Pair(key.first + t, key.second) in p.tiles)  # down
            push!(tileColumn[value], tileId[Pair(key.first + t, key.second)])
            t += 1
        end
        t = 1
        while (Pair(key.first + t, key.second + t) in p.tiles)  # down right
            push!(tileDiagUp[value], tileId[Pair(key.first + t, key.second + t)])
            t += 1
        end
        t = 1
        while (Pair(key.first, key.second + t) in p.tiles)  # right
            push!(tileRow[value], tileId[Pair(key.first, key.second + t)])
            t += 1
        end
        t = 1
        while (Pair(key.first - t, key.second + t) in p.tiles)  # up right
            push!(tileDiagDown[value], tileId[Pair(key.first - t, key.second + t)])
            t += 1
        end
    end

    model = Model(HiGHS.Optimizer)  # construct linear integer programm
    set_optimizer_attribute(model, "log_to_console", false)
    @variable(model, x[1 : length(p.tiles)], Bin)
    for (key, value) in tileId
        @constraint(model, sum(x[i] for i in tileRow[value]) <= 1)  # one queen per row
        @constraint(model, sum(x[i] for i in tileColumn[value]) <= 1)  # one queen per column
        @constraint(model, sum(x[i] for i in tileDiagDown[value]) <= 1)  # one queen per diagonal
        @constraint(model, sum(x[i] for i in tileDiagUp[value]) <= 1)
    end
    @objective(model, Max, sum(x))

    optimize!(model)

    return Int(sum(round.(value.(x)))), tileIdRev[round.(value.(x)) .== 1]  # number, set
end


"""
Minimal guarding rook set problem
- NP complete problem, solve as LIP with HiGHS optimizer
"""
function minRooks(p::Poly)
    tileId = Dict{Pair{Int64, Int64}, Int64}()  # enumerate tiles
    tileIdRev = Pair{Int64, Int64}[]
    t = 1
    for i in p.tiles
        tileId[i] = t
        push!(tileIdRev, i)
        t += 1
    end

    tileAttack = Dict{Int64, Vector{Int64}}()  # key: tile id, value: ids of attackable tiles
    for (key, value) in tileId
        tileAttack[value] = Vector{Int64}([value])

        t = 1
        while (Pair(key.first - t, key.second) in p.tiles)  # up
            push!(tileAttack[value], tileId[Pair(key.first - t, key.second)])
            t += 1
        end
        t = 1
        while (Pair(key.first, key.second - t) in p.tiles)  # left
            push!(tileAttack[value], tileId[Pair(key.first, key.second - t)])
            t += 1
        end
        t = 1
        while (Pair(key.first + t, key.second) in p.tiles)  # down
            push!(tileAttack[value], tileId[Pair(key.first + t, key.second)])
            t += 1
        end
        t = 1
        while (Pair(key.first, key.second + t) in p.tiles)  # right
            push!(tileAttack[value], tileId[Pair(key.first, key.second + t)])
            t += 1
        end
    end

    model = Model(HiGHS.Optimizer)  # construct linear integer programm
    set_optimizer_attribute(model, "log_to_console", false)
    @variable(model, x[1 : length(p.tiles)], Bin)
    for (key, value) in tileId
        @constraint(model, sum(x[i] for i in tileAttack[value]) >= 1)  # no two rooks attack each other
    end
    @objective(model, Min, sum(x))

    optimize!(model)

    return Int(sum(round.(value.(x)))), tileIdRev[round.(value.(x)) .== 1]  # number, set
end


"""
Minimal guarding queen set problem
- NP complete problem, solve as LIP with HiGHS optimizer
"""
function minQueens(p::Poly)
    tileId = Dict{Pair{Int64, Int64}, Int64}()  # enumerate tiles
    tileIdRev = Pair{Int64, Int64}[]
    t = 1
    for i in p.tiles
        tileId[i] = t
        push!(tileIdRev, i)
        t += 1
    end

    tileAttack = Dict{Int64, Vector{Int64}}()  # key: tile id, value: ids of attackable tiles
    for (key, value) in tileId
        tileAttack[value] = Vector{Int64}([value])

        t = 1
        while (Pair(key.first - t, key.second) in p.tiles)  # up
            push!(tileAttack[value], tileId[Pair(key.first - t, key.second)])
            t += 1
        end
        t = 1
        while (Pair(key.first - t, key.second - t) in p.tiles)  # up left
            push!(tileAttack[value], tileId[Pair(key.first - t, key.second - t)])
            t += 1
        end
        t = 1
        while (Pair(key.first, key.second - t) in p.tiles)  # left
            push!(tileAttack[value], tileId[Pair(key.first, key.second - t)])
            t += 1
        end
        t = 1
        while (Pair(key.first + t, key.second - t) in p.tiles)  # down left
            push!(tileAttack[value], tileId[Pair(key.first + t, key.second - t)])
            t += 1
        end
        t = 1
        while (Pair(key.first + t, key.second) in p.tiles)  # down
            push!(tileAttack[value], tileId[Pair(key.first + t, key.second)])
            t += 1
        end
        t = 1
        while (Pair(key.first + t, key.second + t) in p.tiles)  # down right
            push!(tileAttack[value], tileId[Pair(key.first + t, key.second + t)])
            t += 1
        end
        t = 1
        while (Pair(key.first, key.second + t) in p.tiles)  # right
            push!(tileAttack[value], tileId[Pair(key.first, key.second + t)])
            t += 1
        end
        t = 1
        while (Pair(key.first - t, key.second + t) in p.tiles)  # up right
            push!(tileAttack[value], tileId[Pair(key.first - t, key.second + t)])
            t += 1
        end
    end

    model = Model(HiGHS.Optimizer)  # construct linear integer programm
    set_optimizer_attribute(model, "log_to_console", false)
    @variable(model, x[1 : length(p.tiles)], Bin)
    for (key, value) in tileId
        @constraint(model, sum(x[i] for i in tileAttack[value]) >= 1)  # no two queens attack each other
    end
    @objective(model, Min, sum(x))

    optimize!(model)

    return Int(sum(round.(value.(x)))), tileIdRev[round.(value.(x)) .== 1]  # number, set
end