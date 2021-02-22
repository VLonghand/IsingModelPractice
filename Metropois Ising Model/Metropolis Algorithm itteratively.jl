@everywhere using Plots, Statistics
#include("FunsForSquareInsingModel.jl")
using Distributed

@everywhere function H(spin_grid)
    acc = 0
    n = 4
    J = 1
    #spin_grid = reshape(spin_vec, (n,n))


    for i = 1:n, j = 1:n
        local i_1 = i-1
        local j_1 = j-1
        if i == 1
            i_1 = n
        end
        if j == 1
            j_1 = n
        end
        acc += spin_grid[i,j]*spin_grid[i_1,j]*(-J)
        acc += spin_grid[i,j]*spin_grid[i,j_1]*(-J)
    end
    return acc
end
@everywhere function M(spin_grid)
    return sum(spin_grid)
end
@everywhere function w(T, σ_trial, σ_0)
    β = 1/T
    return exp(-β*(H(σ_trial) - H(σ_0)))
end

@everywhere σ_00 = [-1 1 -1 1
        1 -1 1 -1
        -1 1 -1 1
        1 -1 1 -1]
@everywhere  σ_trial = similar(σ_00)

@everywhere Ms = []
@everywhere Ts = []
@everywhere Mmeans = []

@everywhere function algotithm(T)
    for i in 1:1_000_000
        push!(Ms, sum(σ_00))

        global σ_trial = copy(σ_00)
        global σ_trial[rand(1:16)] *= -1

        r = rand()

        if r <= w(T, σ_trial, σ_00)
            global σ_00 = σ_trial
        end    
    end
end

@everywhere function itter_over_Temps()
    for T in 0:0.01:3
        algotithm(T)
    
        push!(Mmeans, abs(mean(Ms)/16)) # /16 to 'normalize' or average magnetization over all spins
        push!(Ts, T)
        global Ms = []
    end

end

addprocs(7)
print(nprocs())
print(nworkers())

for i in workers()
    r = remotecall_fetch(itter_over_Temps, WorkerPool(workers()))
end

# itter_over_Temps()

plot(Ts, Mmeans, label=M)
xlabel!("Temperature")
ylabel!("Magnetization")
title!("Magnetization vs Temperature")