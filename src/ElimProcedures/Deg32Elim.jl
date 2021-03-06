################################################################################
#
#  Submodules
#
################################################################################

include("../EllCrv/FieldsRings.jl")
include("../EllCrv/EllCrv.jl")
include("../EllCrv/EllCrvDiv.jl")
include("../EllCrv/EllCrvMap.jl")
include("../EllCrv/EllCrvModel.jl")

################################################################################
#
#  Imports
#
################################################################################

import AbstractAlgebra


# An aside from the proof of Proposition 4.4, verifying 
# the non-vanishing of a constructed determinant given 
# a divisor D1 on E

function verify(prime::UInt128)

    if prime == 2
        
        # Fix a field of prime order.
        Z = AbstractAlgebra.GF(prime)

        # Fix homogeneous coordinates [x:y:z] for an elliptic curve, 
        # where x, y, z are in Z.
        coords = ("x1", "y1", "z1")

        # Fix coefficients A, B in Z for the Weierstrass form of the
        # elliptic curve, i.e. in homogenous coordinates [x:y:z],
        # EllCrv := x^3 + Ax^2 + B - x*y.

        coeff = (A, B)



        # Instantiate Polynomial Rings.
        R0, (A, B, xQ, yQ, coords) = AbstractAlgebra.PolynomialRing(Z, 
            ["A",
            "B",
            "xQ",
            "yQ",
            "x1",
            "y1",
            "z1"])
        
            # R1, aq1, aq, a1, a0, r = AbstractAlgebra.PolynomialRing(R0,
        #    "aq1",
        #    "aq",
        #    "a1",
        #    "a0",
        #    "r")

        
        # Instantiate Short-form Weierstrass Elliptic Curve.
        check = true
        EllCrvWeier = EllipticCurve(coeff, check)
        
        
    end
    
end