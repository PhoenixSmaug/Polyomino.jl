include("polyomino.jl")

println("<Polyomino Generation (n = 40)>")

println("Shuffling (p = 0):")
show(Polyomino(40, 0.0, true))

println("Shuffling (p = 0.8):")
show(Polyomino(40, 0.8, true))

println("Eden Model:")
show(Polyomino(40, 0.0, false))


println("<Polyomino Analysis>")
polyomino = Polyomino(40, 0.6, true)

println("Minimal Rook Setup")
printMinRooks(polyomino)

println("Maximal Rook Setup")
printMaxRooks(polyomino)

println("Minimal Line Cover")
printMinLineCover(polyomino)
