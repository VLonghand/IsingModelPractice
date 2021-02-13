include("Energy.jl")

β = 1/T

function w(T, σ_trial, σ_0)
    return exp(-β*(H(σ_trial) - H(σ_0)))
end
