################################################################################
#
#          EllCrv/FieldsRings.jl : Fields of definition for Elliptic Curves,
#           Field Extensions --> Number Fields
#           Local Rings --> Function Fields
#
# This file is part of Hecke.
#
# Copyright (c) 2015, 2016: Claus Fieker, Tommy Hofmann
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# (C) 2016 Tommy Hofmann
# (C) 2016 Robin Ammon
# (C) 2016 Sofia Brenner
#
################################################################################


################################################################################
#
#  Imports
#
################################################################################

import AbstractAlgebra
using Markdown

include("EllCrv.jl")

################################################################################
#
#  Exports
#
################################################################################

export Field, Loc, LocElem, FuncField

################################################################################
#
#  Abstract Types/Structs
#
################################################################################

mutable struct Field{T} <: AbstractAlgebra.Field
    is_finite::Bool
    prime::T # IF is_finite = true.
    power::T # If is_finite = true.
    characteristic::T # 0 if is_finite = false. prime if is_finite = true.
    order::T # prime^power if is_finite = true

    # Finite
    function Field{T}(p::T, q::T, check::Bool = true) where {T}
        if check
            char = p
            ord = p^q
            F = new{T}()
            F.is_finite = true
            F.characteristic = deepcopy(char)
            F.order = deepcopy(ord)
        else
            F = new{T}()
            F.is_finite = false
            F.characteristic = 0
        end
        return F
    end
end

mutable struct ExtField{T} <: Field
   degree::T 
   is_primitive::Bool
   primitive_element::AbstractAlgebra.FieldElem
   #...
end

#prime might be product of several primes if localized at several primes, those primes are in array primes
mutable struct Loc{T} <: AbstractAlgebra.Ring
   base_ring::AbstractAlgebra.Ring
   prime::T
   primes::Array{T,1}  # in general, not set.
   comp::Bool  # false: den has to be coprime to prime
               # true:  den can ONLY use prime (and powers)

   function Loc{T}(prime::T, primes::Array{T,1}, cached::Bool = true, comp::Bool = false) where 
    {T <: AbstractAlgebra.RingElem}
      length(primes) == 0 && error("No element to localize at since array of primes is empty")
      if cached && haskey(LocDict, (parent(prime), prime, comp))
         return LocDict[parent(prime), prime, comp]::Loc{T}
      else
         z = new(parent(prime), prime, primes, comp)
         if cached
            LocDict[parent(prime), prime, comp] = z
         end
         return z
      end
   end

   function Loc{T}(prime::T, cached::Bool = true, comp::Bool = false) where 
    {T <: AbstractAlgebra.RingElem}
     isunit(prime) && error("no-point")
     if cached && haskey(LocDict, (parent(prime), prime, comp))
       return LocDict[parent(prime), prime, comp]::Loc{T}
     else
       r = new()
       r.base_ring = parent(prime)
       r.prime = prime
       r.comp = comp
       if cached
          LocDict[parent(prime), prime, comp] = r
       end
       return r
     end
   end
end

const LocDict = Dict{Tuple{AbstractAlgebra.Ring, AbstractAlgebra.RingElement, Bool}, 
AbstractAlgebra.Ring}()

function isin(a, L::Loc{T}) where {T <: AbstractAlgebra.RingElem}
  iszero(a) && return true
  L.comp || (!isone(gcd(denominator(a), prime(L))) && return false)
  L.comp && ppio(denominator(a), prime(L))[1] != denominator(a.data) && return false
  return true
end

mutable struct LocElem{T} <: AbstractAlgebra.RingElem
   data::AbstractAlgebra.FieldElem
   parent::Loc{T}
   function LocElem{T}(data::AbstractAlgebra.FracElem{T}, par::Loc, checked::Bool = true) where 
    {T <: AbstractAlgebra.RingElem}
     checked && (isin(data, par) || error("illegal elt"))
     return new{T}(data,par)
   end
end


# Function fields of curves.
mutable struct FuncField <: Loc
    # The function field K[E] of the elliptic curve E 
    # consists of ratios of polynomials. Taking an 
    # elliptic curve E as an integral, regular scheme of 
    # finite type, then the function field K[E] is 
    # just the local ring of the generic point.
    
    base_curve::EllCrv
    generic_point::EllCrvPt
end

###############################################################################
#
#   Data type and parent object methods
#
###############################################################################

elem_type(::Type{Loc{T}}) where {T} = LocElem{T}

parent_type(::Type{LocElem{T}}) where {T} = Loc{T}

base_ring(L::Loc) = L.base_ring

base_ring(a::LocElem) = base_ring(parent(a))

parent(a::LocElem) = a.parent

function check_parent(a::LocElem{T}, b::LocElem{T})  where 
    {T <: AbstractAlgebra.RingElem}
    parent(a) !== parent(b) && error("Parent objects do not match")
end