# Polyomino library

A short presentation of all implemented functions is available by calling `Polyomino.demo()`.

## Functions

### Polyomino generation

* `Poly(size::Int64)`: Eden model, O(n)

* `Poly(size::Int64, p::Float64)`: Shuffling model for uniformly random polyominoes, O(n^3)

### Chess problems

* `maxRooks(p::Poly)`: Solves the maximal non-attacking rook set problem, O(n^4)

* `maxQueens(p::Poly)`: Solves the maximal non-attacking queen set problem, NP-complete

* `minRooks(p::Poly)`: Solves the minimal guarding rook set problem, NP-complete

* `minQueens(p::Poly)`: Solves the minimal guarding queen set problem, NP-complete

### Polyomino analysis

* `minimalLineCover(p::Poly)`: Calculate minimal line cover, O(n^4)

(c) Christoph Muessig
