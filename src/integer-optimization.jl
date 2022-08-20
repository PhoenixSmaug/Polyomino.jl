"""
Convert Minimal Rook Set problem to integer programm
"""
function minRooksEq(p::Poly)
    tileId = Dict{Pair{Int64, Int64}, Int64}()  # enumerate tiles
    tileIdRev = Pair{Int64, Int64}[]
    t = 1
    for i in p.tiles
        tileId[i] = t
        push!(tileIdRev, i)
        t += 1
    end

    tileAttack = Dict{Int64, Vector{Int64}}()  # attack patterns

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

    model = Model(HiGHS.Optimizer)
    @variable(model, x[1 : length(p.tiles)], Bin)
    
    for (key, value) in tileId
        @constraint(model, sum(x[i] for i in tileAttack[value]) >= 1)  # one rook per row
    end

    @objective(model, Min, sum(x))

    optimize!(model)

    println(sum(round.(value.(x))))
end


"""
Convert Minimal Queen Set problem to integer programm
"""
function minQueensEq(p::Poly)
    tileId = Dict{Pair{Int64, Int64}, Int64}()  # enumerate tiles
    tileIdRev = Pair{Int64, Int64}[]
    t = 1
    for i in p.tiles
        tileId[i] = t
        push!(tileIdRev, i)
        t += 1
    end

    tileAttack = Dict{Int64, Vector{Int64}}()  # attack patterns

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

    model = Model(HiGHS.Optimizer)
    @variable(model, x[1 : length(p.tiles)], Bin)
    
    for (key, value) in tileId
        @constraint(model, sum(x[i] for i in tileAttack[value]) >= 1)  # one rook per row
    end

    @objective(model, Min, sum(x))

    optimize!(model)

    println(sum(round.(value.(x))))
end


"""
Convert Maximal Queen Set problem to integer programm
"""
function maxQueensEq(p::Poly)
    tileId = Dict{Pair{Int64, Int64}, Int64}()  # enumerate tiles
    tileIdRev = Pair{Int64, Int64}[]
    t = 1
    for i in p.tiles
        tileId[i] = t
        push!(tileIdRev, i)
        t += 1
    end

    tileRow = Dict{Int64, Vector{Int64}}()  # attack patterns
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

    model = Model(HiGHS.Optimizer)
    @variable(model, x[1 : length(p.tiles)], Bin)
    
    for (key, value) in tileId
        @constraint(model, sum(x[i] for i in tileRow[value]) <= 1)  # one queen per row
        @constraint(model, sum(x[i] for i in tileColumn[value]) <= 1)  # one queen per column
        @constraint(model, sum(x[i] for i in tileDiagDown[value]) <= 1)  # one queen per diagonal
        @constraint(model, sum(x[i] for i in tileDiagUp[value]) <= 1)
    end

    @objective(model, Max, sum(x))

    optimize!(model)

    println(sum(round.(value.(x))))
end
