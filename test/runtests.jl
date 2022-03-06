using Test
using DataStructures
using MatrixNetworks
using Combinatorics

import Polyomino

# polyomino generation
polyominoA = Polyomino.Poly(30, 0.0, false)
polyominoB = Polyomino.Poly(20, 0.6, true)

@test length(polyominoA.tiles) == 30
@test length(polyominoB.tiles) == 20

# min and max rooks
polyomino = Polyomino.Poly(Set([-2 => 1, -2 => 0, -4 => 2, 3 => -2, -2 => -1, -2 => -2, 1 => -4, -1 => 1, -1 => 0, -1 => -1, -3 => 2, -4 => 1, 0 => 1, 1 => -3, 0 => 0, 0 => -1, 1 => 0, 1 => -1, 0 => -2, 2 => -3, 1 => -2, 2 => 1, -3 => 1, 2 => 0, -3 => 0, 2 => -1, -3 => -1, -5 => 2, 3 => -1, 2 => -2]))
min, _ = Polyomino.minRooks(polyomino)
max, _ = Polyomino.maxRooks(polyomino)

@test min == 5
@test max == 8

# minimal line cover
mlc = Polyomino.minimalLineCover(polyomino)

@test issetequal(mlc, Set(Array{Pair{Int64, Int64}}[[0 => -2, 1 => -2, 2 => -2, 3 => -2], [-3 => -1, -2 => -1, -1 => -1, 0 => -1, 1 => -1, 2 => -1, 3 => -1], [-5 => 2, -4 => 2, -3 => 2], [-3 => 0, -2 => 0, -1 => 0, 0 => 0, 1 => 0, 2 => 0], [1 => -4, 1 => -3, 1 => -2, 1 => -1, 1 => 0], [2 => -3, 2 => -2, 2 => -1, 2 => 0, 2 => 1], [-4 => 1, -3 => 1, -2 => 1, -1 => 1, 0 => 1], [-2 => -2, -2 => -1, -2 => 0, -2 => 1]]))
