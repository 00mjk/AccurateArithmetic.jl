# this is "TwoSum"
@inline function add_hilo(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    v = s - a
    e = (a - (s - v)) + (b - v)
    return s, e
end

function add_hilo(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_hilo(b, c)
    x, u = add_hilo(a, s)
    y, z = add_hilo(u, t)
    x, y = add_hilo_hilo(x, y)
    return x, y, z
end

function add_hilo(a::T,b::T,c::T,d::T) where {T<: AbstractFloat}
    t0, t1 = add_hilo(a ,  b)
    t0, t2 = add_hilo(t0,  c)
    a,  t3 = add_hilo(t0,  d)
    t0, t1 = add_hilo(t1, t2)
    b,  t2 = add_hilo(t0, t3)
    c,  d  = add_hilo(t1, t2)
    return a, b, c, d
end

# this is TwoDiff
@inline function sub_hilo(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    v = s - a
    e = (a - (s - v)) - (b + v)
    return s, e
end

function sub_hilo(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = sub_hilo(-b, c)
    x, u = add_hilo(a, s)
    y, z = add_hilo(u, t)
    x, y = add_hilo_hilo(x, y)
    return x, y, z
end

# this is QuickTwoSum, requires abs(a) >= abs(b)
@inline function add_maxmin_hilo(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    e = b - (s - a)
    return s, e
end

function add_maxmin_hilo(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = add_maxmin_hilo(b, c)
    x, u = add_maxmin_hilo(a, s)
    y, z = add_maxmin_hilo(u, t)
    x, y = add_maxmin_hilo(x, y)
    return x, y, z
end

# this is QuickTwoDiff, requires abs(a) >= abs(b)
@inline function sub_maxmin_hilo(a::T, b::T) where {T<:AbstractFloat}
    s = a - b
    e = (a - s) - b
    s, e
end

function sub_maxmin_hilo(a::T,b::T,c::T) where {T<:AbstractFloat}
    s, t = sub_maxmin_hilo(-b, c)
    x, u = add_maxmin_hilo(a, s)
    y, z = add_maxmin_hilo(u, t)
    x, y = add_maxmin_hilo(x, y)
    return x, y, z
end

# this is TwoProdFMA
@inline function mul_hilo(a::T, b::T) where {T<:AbstractFloat}
    p = a * b
    e = fma(a, b, -p)
    p, e
end

function mul_hilo(a::T, b::T, c::T) where {T<:AbstractFloat}
    y, z = mul_hilo(a, b)
    x, y = mul_hilo(y, c)
    z, t = mul_hilo(z, c)
    return x, y, z, t
end

"""
    mul_hilo3(a, b, c)

similar to mul_hilo(a, b, c)
returns a three tuple
"""
function mul_hilo3(a::T, b::T, c::T) where {T<:AbstractFloat}
    y, z = mul_hilo(a, b)
    x, y = mul_hilo(y, c)
    z    *= c
    return x, y, z
end

# a squared 
@inline function sqr_hilo(a::T) where {T<:AbstractFloat}
    p = a * a
    e = fma(a, a, -p)
    p, e
end

# a cubed
@inline function cub_hilo(a::T) where {T<:AbstractFloat}
    hi, lo = sqr_hilo(a)
    hihi, _hilo = mul_hilo(hi, a)
    lohi, lolo = mul_hilo(lo, a)
    _hilo, lohi = add_maxmin_hilo(_hilo, lohi)
    hi, lo = add_maxmin_hilo(hihi, _hilo)
    lo += lohi + lolo
    return hi, lo
end

#=
   fma_hilo algorithm from
   Sylvie Boldo and Jean-Michel Muller
   Some Functions Computable with a Fused-mac
=#

"""
    fma_hilo(a, b, c) => (x, y, z)

Computes `x = fl(fma(a, b, c))` and `y, z = fl(err(fma(a, b, c)))`.
"""
function fma_hilo(a::T, b::T, c::T) where {T<:AbstractFloat}
     x = fma(a, b, c)
     y, z = mul_hilo(a, b)
     t, z = add_hilo(c, z)
     t, u = add_hilo(y, t)
     y = ((t - x) + u)
     y, z = add_maxmin_hilo(y, z)
     return x, y, z
end

"""
    fms_hilo(a, b, c) => (x, y, z)

Computes `x = fl(fms(a, b, c))` and `y, z = fl(err(fms(a, b, c)))`.
"""
@inline function fms_hilo(a::T, b::T, c::T) where {T<:AbstractFloat}
     return fma_hilo(a, b, -c)
end

