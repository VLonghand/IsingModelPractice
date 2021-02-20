using Colors, Plots, Images, Statistics, StaticArrays
include("Funs.jl")

σ_00 = [-1 1 -1 1
        1 -1 1 -1
        -1 1 -1 1
        1 -1 1 -1]
σ_trial = similar(σ_00)

Ms = []
Ts = []
Mmeans = []

function algotithm(T)
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

function itter_over_Temps()
    for T in 0:0.01:3
        algotithm(T)
    
        push!(Mmeans, abs(mean(Ms)/16)) # /16 to 'normalize' or average magnetization over all spins
        push!(Ts, T)
        global Ms = []
    end

end

itter_over_Temps()

plot(Ts, Mmeans, label=M)
xlabel!("Temperature")
ylabel!("Magnetization")
title!("Magnetization vs Temperature")