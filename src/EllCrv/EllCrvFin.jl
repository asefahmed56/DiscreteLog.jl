################################################################################
#
#          EllCrv/EllCrvFin.jl : Elliptic curves over finite fields
#
################################################################################


################################################################################
#
#  Submodules
#
################################################################################

include("EllCrv.jl")
include("../src/Misc/BigIntInterface.jl")
include("../src/Misc/PolyFac.jl")

################################################################################
#
#  Imports
#
################################################################################

using Random

################################################################################
#
#  Exports
#
################################################################################

export order, order_via_schoof, rand_point, crypto_curve

################################################################################
#
#  Random Point Generator
#
################################################################################

function issquare(x::Union{AbstractAlgebra.gfelem{Int32}, AbstractAlgebra.FinFieldElem})
    k = parent(x)
    S, t = AbstractAlgebra.PolynomialRing(k, "t", cached = false)

    f = t^2 - x
    
    # Distinct Degree Factorization for now.
    fac = factor_ddf(f)

    p = first(keys(fac.fac))

    if fac[p] == 2
        root = -AbstractAlgebra.coeff(p, 0)
        return true, k(root)
    elseif length(fac) == 2
        root = -coeff(p, 0)
        return true, k(root)
    else
        return false, zero(k)
    end
end

function rand_point(E::EllCrv)
    k = E.base_field
    (a4, a6) = a_invars(E)

    if E.short == false
        error("Not implemented for long form.")
    end

    while true

        x = rand(k)
        square = x^3 + a4*x + a6

        a = AbstractAlgebra.issquare(square)
        if a[1] == true
            y = a[2]
            P = E((x, y))
            return P
        end
    end
end

################################################################################
#
#  Elliptic Curve Generator over Finite Fields (Naive implementation at first.)
#  https://pdfs.semanticscholar.org/c60c/46a9ee6f90958f609f464723f6bf92835feb.pdf
#
################################################################################

function crypto_curve(r0::BigInt, k0::BigInt, h0::BigInt)
    if prod(r0, k0, h0) <= 0
        error("r0, k0, h0 must be positive integers.")
    end

    if r0 < 2^BigInt(159) || k0 < 4 || h0 < 200
        error("Invalid input.")
    end

    (d, p, r, k) = find_prime(r0, k0, h0)
    
    (E, G) = find_curve(d, p, r, k)

    return (d, p, r, k, E, G)
end

function find_prime(r0::BigInt, k0::BigInt, h0::BigInt)
    print("Enter a (rational) prime p: ")
    input = readline()
    p = parse(BigInt, chomp(input))
    
    m = 50
    
    if p == 0
        find_prime_delta_fixed(r0, k0, h0)
    elseif is_prime(p, m) == true && floor(log2(p)) == floor(log2(r0*k0))
        find_discriminant(p, r0, k0, h0)
    else
        error("Invalid prime.")
    end
end

function find_prime_delta_fixed(r0::BigInt, k0::BigInt, h0::BigInt)
    print("Enter a discriminant: ")
    input = readline()
    d = parse(BigInt, chomp(input))

    abs_d = abs(d)
    
    if k0 >= 4
        if mod(d, 8) == 1 || mod(abs_d, 8) == 7
            b = BigInt(floor(log2(4*r0)))
            i0 = 2^b
            i1 = 2^(b + 1) - 1
            interval = collect(BigInt, i0:i1)
            
            if find_prime_1_mod_8(r0, 4, d, interval)
                return true
            else
                error("Unable to find prime.")
            end
        else
            error("Get discriminant congruent to 1 mod 8, 
            or its norm congruent to 7 mod 8.")
        end
    elseif k0 >= 2
        if mod(d, 16) == 8 || 12
            b = BigInt(floor(log2(r0*k0)))
            i0 = 2^b
            i1 = 2^(b + 1) - 1
            interval = collect(BigInt, i0:i1)

            if find_prime_0_mod_4(r0, k0, d, interval)
                return true
            else
                error("Unable to find prime.")
            end
        else
            error("Get discriminant congruent to 8 or 12 modulo 16.")
        end
    else
        if mod(d, 8) == 5
            b = BigInt(floor(log2(r0)))
            i0 = 2^b
            i1 = 2^(b + 1) - 1
            interval = collect(BigInt, i0:i1)

            if find_prime_5_mod_8(r0, 1, d, interval)
                return true
            else
                error("Unable to find prime.")
            end
        else
            error("Get discrimint congruent to 5 mod 8.")
        end
    end
end

function find_prime_0_mod_4(r0::BigInt, k0::BigInt, d::BigInt, 
    interval::Array{BigInt, 1})
    # Number of successive tested pairs (t, y).
    # If not successful after T tries, init a new pair.
    const T = 2000

    # Bit of 2 in binary representation of t.
    t_bit_1 = Int

    abs_delta = assign(d)
    
    ###
end