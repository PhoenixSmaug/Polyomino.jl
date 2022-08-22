"""
    minLineCover(p)

Conversion to Minimal Line Cover (MLC)

(I) Find maximal non-attacking rook set and construct vertical and horizontal line through each rook
(II) If one of the lines of a rook has size 1, add the other to the MLC. Otherwise add random horizontal line to MLC. In both cases delete rook of the line.
(III) Repeat II until no rooks are left.

# Arguments
* `p`: Polyomino to be converted
"""
function minLineCover(p::Poly)
    _, rooksVec = maxRooks(p)
    rooks = Set(rooksVec)
    minLineCover = Set{Array{Pair{Int64, Int64}}}()
    done = Set{Pair{Int64, Int64}}()

    while (!isempty(rooks))
        tilesOneLine = Set{Pair{Int64, Int64}}()  # find all tiles where one line has size 1
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


function printMinLineCover(p::Poly)  # "-" if tile is part of horizontal line, "|" if tile is part of vertical line, "+" if both
    mlc = minLineCover(p)

    minX, maxX, minY, maxY =  dimensionPoly(p)

    for i in minX:maxX
        for j in minY:maxY
            isRow = false; isColumn = false;
            for k in mlc
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