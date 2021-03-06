<p align="center">
    <img src="./docs/src/assets/logo.png" alt="DiscreteLog.jl" />
    </p>

# DiscreteLog.jl

A work-in-progress Julia package to implement the degree 3-to-2 and 
degree 4-to-3 procedures from this [paper](https://arxiv.org/pdf/1906.10668.pdf) 
by Kleinjung and Wesolowski.

In addition, in the vein of [Hecke.jl](https://github.com/thofma/Hecke.jl), 
this aims to implement general as well as finite field 
elliptic curve projective and affine point arithmetic, as well as 
structs for divisors on elliptic curves up to linear equivalence (e.g. principal divisors of rational functions on the curve et al.), as well as 
for models of elliptic curves with a specific divisor and points on them of a 
fixed degree.

Also incorporates standard cryptographic fare like point counting and elliptic curve 
generation procedures.

A future goal is to broaden the scope of the library to be a comprehensive 
collection of efficient algorithms for group law computations of points
for elliptic curves (genus `g = 1`) as well as hyperelliptic curves (genus `g = 2`)
and for their Jacobians.

## Dependencies

[AbstractAlgebra.jl](https://github.com/wbhart/AbstractAlgebra.jl)

## References

<table style="border:0px">
<tr>
    <td valign="top"><a name="ref-kleinjung-wesolowski-2015"></a>[KW2019]</td>
    <td>Thorsten Kleinjung and Benjamin Wesolowski.
    <a href=https://arxiv.org/pdf/1906.10668.pdf>
        Discrete logarithms in quasi-polynomial time in finite fields of fixed characteristic</a>.
    In <i>arXiv preprint, 2019.</td>
</tr>
</table>
