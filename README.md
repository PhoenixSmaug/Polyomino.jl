##DEVELOPERS:

Alexis Langlois-Rémillard ()

Christoph Müßig () 

Erika Roldan (erika.roldan@ma.tum.de) https://www.erikaroldan.net/

DATE: October 8th, 2022

LICENSE: GNU GENERAL PUBLIC LICENSE (see license.txt)

##Overview


Acknowledgements
Erika Roldan received funding from the European Union’s Horizon 2020 research and innovation program under the Marie Skłodowska-Curie grant agreement No. 754462.

Citations
You are welcome to use and adapt this code for your own projects. If you use this code, please cite the paper .


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


