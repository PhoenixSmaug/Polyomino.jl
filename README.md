# Polyomino library

A short presentation of all implemented functions is available with calling `demo()`. The details of all algorithms are described in the paper (insert link).

## Functions

### Polyomino generation

Polyominoes can be generated with `Poly(size::Int64, p::Float64, shuffling::Bool)`.

* `size` is the number of tiles in the polyomino

* `p` is the perculation paramater choosen between 0 and 1

* `shuffling` if the computationally intensive shuffling algorithm should be used for the generation

### Rook setups

* `maxRooks(p::Poly)` get number of maximal rooks and their position

* `printMaxRooks(p::Poly)` print out maximal rook setup in ASCII art

* `minRooks(p::Poly)` get number of maximal rooks and their position

* `printMinRooks(p::Poly)` print out minimal rook setup in ASCII art

### Polyomino analysis

* `minimalLineCover(p::Poly)` get lines part of a minimal line cover

* `printMinLineCover(p::Poly)` print out minimal line cover in ASCII art

(c) Christoph Muessig
