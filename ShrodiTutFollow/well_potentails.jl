using Plots, Distributions, SparseArrays, JLD2
using StatsBase: sample

## Infinite well (IW)
# Following the tutorial generate energies and Lx -> solve when possible -> randomly swap Lx Ly

# Lx is the width of a well, Lxs is a list of width for many wells
# same for Ly and Lys
# E is the energy, Es is the list of energies 
# V is the potentials of IW as a 2D sparse matrix
# matching E to corresponding Lx and Ly is done through indexing


# takes generated energies and generated Lx
# returns energies and Lxs that satisfy the equation, not all combinations do 
# and the resulting Lys
function Lys_gen(Es,Lxs)
    Lys = []
    in_sqrt = 0
    Es_new = []
    Lxs_new = []
    len = size(Es)[end]

    for i in 1:len

        in_sqrt = (2*Es[i])/(pi^2) - 1/(Lxs[i]^2)

        if in_sqrt > 0
            push!(Lys, 1/sqrt(in_sqrt))
            push!(Lxs_new, Lxs[i])
            push!(Es_new, Es[i])
        end
    end

    return Es_new, Lxs_new, Lys 
end

# takes Lxs and Lys
# modifies two lists, swaps half of the values in between lists
# returns the two lits
function Lys_Lxs_rand_swap!(Lxs, Lys)
    len = size(Lxs)[end]
    swap_index = sample(1:len, Int(round(len/2, digits=0)), replace=false )
    temp = 0.0
    for i in swap_index
        temp = Lxs[i]
        Lxs[i] = Lys[i]
        Lys[i] = temp
    end
    return Lxs, Lys
end


# Infinite well potentials from determined Lxs and Lys
# 256x256 grid as per SHO

# takes Lxs and Lys 
function IW_potential(Lxs, Lys)
    lim = 256
    len = size(Lxs)[end]
    Vs = []

    # takes max, min and val, if out of bounds equates to closest boundary 
    # also converts val to int
    function constrain_to_boun(val, max = 256, min=256)
        if max < val
            return max
        elseif min > val
            return min
        else
            return trunc(Int, val)
        end
        
    end

    function make_bounds(Lx, Ly, cx, cy)
        to_int(n) = constrain_to_boun(n) # else large L cause negative indices 
        up(L,c) = 0.5*(2*c+L)
        low(L,c) = 0.5*(2*c-L)
        x_lower = to_int(low(Lx,cx))
        x_upper = to_int(up(Lx,cx))
        y_lower = to_int(low(Ly,cy))
        y_upper = to_int(up(Ly,cy))
        return x_lower, x_upper, y_lower, y_upper
    end

    # offset the well from center of image
    
    cxs = rand(Uniform(15,lim-15),len)
    cys = rand(Uniform(15,lim-15),len)
    # itterates to make a wells, 4 parameters per
    for i in 1:len
        V = spzeros(lim,lim)
        x_lower, x_upper, y_lower, y_upper = make_bounds(Lxs[i], Lys[i], cxs[i], cys[i])
        V[x_lower:x_upper, y_lower:y_upper] .= 20
        # convert(SparseMatrixCSC{Float32,Int64}, V)
        push!(Vs,V)
    end
    # Vs = convert(Array{Array{Float32, 2}, 1} , Vs)
    return Vs
end

# Vs = IW_potential(Lxs,Lys)
# heatmap(Matrix(Vs[17]))

# takes number of energies to start with, since only some satisfy the equation
# the final # of images will be less
# returns nothing; generates potential and saves potentials and energies to an h5 file
function generate_and_save(num_Es)
    # energies in range = [0,0.4]
    Es = rand(Uniform(0,0.4), num_Es)
    # Lx in range = [4,15]
    Lxs = rand(Uniform(4,15), num_Es)
    # redefine Es, Lxs that satisfy the equation for Ly and create Lys
    Es, Lxs, Lys  = Lys_gen(Es, Lxs)
    # "swap the values of Lx and Ly with a 50% probability to prevent one dimension from always being larger"(K. Mills, 2017) 
    Lys_Lxs_rand_swap!(Lxs,Lys)

    # generate potentials from Es, Lxs, Lys; cx, cy are random for each
    Vs = IW_potential(Lxs,Lys)

    jldopen("ShrodiTutFollow/finite_well_schrodinger.jld2", "w") do file
        file["energies"] = Es
        file["potentials"] = Vs
    end
    # jldsave("ShrodiTutFollow/finite_well_schrodinger.jld2"; energies = Es, potentials = Vs)

end
# generate_and_save(10000)

# test if Es are right
# err = []
# for i in 1:size(Lxs)[end]
#     newE = (pi^2)/(2*Lxs[i]^2) + (pi^2)/(2*Lys[i]^2)
#     if Es[i] != newE
#         push!(err, Es[i]-newE)
#     end
# end
# err
# maximum(err)
# Es


# Ef(Lx,Ly) = (pi^2)/(2*Lx^2) + (pi^2)/(2*Ly^2)

# LY(E,Lx) = 1/sqrt((2*E)/(pi^2) - 1/(Lx^2))

# Ef(15, LY(0.4,15))

