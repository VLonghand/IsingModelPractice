using HDF5, Random, Distributions
include("TISE solver.jl")

# purpose is to generate potentials, i.e. greyscale images
# and to solve for corresponding energies 
# to train a CNN


# -20 - 20 domain, 256x256 grid, SHO potentials
T̂ = undef # can be later redefined as anything 

function SHO_potentails_gen(N_k_per_axis)
    kx = rand(Uniform(0,1),N_k_per_axis)
    ky = rand(Uniform(0,1),N_k_per_axis)
    cx = rand(Uniform(-10,10), N_k_per_axis)
    cy = rand(Uniform(-10,10), N_k_per_axis)
    L = 256
    V = ones(L,L) #preallocation
    xy = collect(range(-20,20,length=L)) #preallocation
    potentials = []

    # it's more convinient to define T̂ here 
    global T̂ = second_der_oper(L, xy[1]-xy[2])

    for i in 1:N_k_per_axis
        potential = SHO(V, xy, L, kx[i], ky[i],cx = cx[i],cy = cy[i])
        push!(potentials, potential)
    end
    
    return potentials
end


potentials = SHO_potentails_gen(10)

unique(potentials)

size(potentials)[end]

function Es_gen()
    L = 256
    emptyV̂ = spzeros(L^2,L^2) #preallocation
    Es = []

    for i in 1:size(potentials)[end]
        push!(Es, solve1(potential_oper!(potentials[i], emptyV̂), T̂))
        if i%10 == 0
            println("Completed $i ")
        end
    end
    return Es
end

Es = Es_gen()


minimum(Es)

function write()
    h5open("schrodinger_data_mine.h5", "w") 

end




# generate potentials

