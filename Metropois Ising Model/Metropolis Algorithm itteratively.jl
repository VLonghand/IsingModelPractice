
#include("FunsForSquareInsingModel.jl")
using Distributed
@everywhere using Plots, Statistics, CSV, DataFrames

# Funtions to be moved to a module to use @everywhere --------------
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
#-------------------------------------------------------------------


# global varaible declaration -------------------------------------- 
begin
    # @everywhere σ_00 = [-1 1 -1 1
    #         1 -1 1 -1
    #         -1 1 -1 1
    #         1 -1 1 -1]
    # @everywhere σ_trial = similar(σ_00)
    # @everywhere Ms = []
    # @everywhere Ts = []
    # Mmeans = []
    @everywhere k = ones(1,501)
    # for i in 1:501
    #     k[i] = i
    # end  
    @everywhere dfMmeans = DataFrame(k)
    delete!(dfMmeans,1)
end
#-------------------------------------------------------------------

# main functions of the algorithm ----------------------------------
@everywhere function algotithm(T,σ_00, σ_trial, Ms )
    @inbounds for i in 1:1_000_000
        push!(Ms, sum(σ_00))

        σ_trial = copy(σ_00)
        σ_trial[rand(1:16)] *= -1

        r = rand()

        if r <= w(T, σ_trial, σ_00) 
            σ_00 = σ_trial
        end    
    end
end

@everywhere function itter_over_Temps()
    local Mmeans = []
    local σ_00 = [-1 1 -1 1
                   1 -1 1 -1
                   -1 1 -1 1
                   1 -1 1 -1]
    local σ_trial = similar(σ_00)
    local Ts = []
    local Ms =[]

   @inbounds for T in 0:0.01:5
        algotithm(T, σ_00, σ_trial, Ms)
        push!(Mmeans, abs(mean(Ms)/16)) # /16 to 'normalize' or average magnetization over all spins
        push!(Ts, T)
        Ms = []
    end

    return Mmeans # saves as rows
end
#-------------------------------------------------------------------

# multiprocessing troubleshooting tools ----------------------------
using Distributed
# addprocs(7) # one runs from init, (cores not processsors)
print(nprocs())
print(nworkers())
#-------------------------------------------------------------------

function itter_via_workers()
    for i in workers()
        r = remotecall_fetch(itter_over_Temps, WorkerPool(workers()))
        j = Symbol(i-2)
        push!(dfMmeans, r) #using dfMeans.j uses j as symb, not a var
    end
end


function write_to_file()
    itter_via_workers()
    dfMmeans |> CSV.write("Metropois Ising Model/Phase Transition Data/Mmeans.csv",
                           append=true)
end

write_to_file()

# PLots, but you knew that already ---------------------------------
# plot(Ts, Mmeans, label=M)
# xlabel!("Temperature")
# ylabel!("Magnetization")
# title!("Magnetization vs Temperature")  
#-------------------------------------------------------------------
