using Colors, Plots, Images
include("Funs.jl")



# 1. Initialize: checkerboeard pattern
#σ_00 = [-1,1,-1,1,    1,-1,1,-1,   -1,1,-1,1,   1,-1,1,-1]
σ_00 = [-1 1 -1 1
         1 -1 1 -1
         -1 1 -1 1
         1 -1 1 -1]


function trial_move(σ_0)
    local σ = copy(σ_0)
    σ[rand(1:16)] *= -1
    return  σ
end


acc = 0
N = 2000
T = 1
images1 = []

function accept_itter(σ_0)
    σ_trial = trial_move(σ_0)
    r = rand()
    global acc +=1

    if acc >= N
        return "Done"
    end

    if r <= w(T, σ_trial, σ_0)  # accept
        append!(images1, [σ_trial])
        accept_itter(σ_trial)
    else
        accept_itter(σ_0)
    end
end

accept_itter(σ_00)
unique(images1)


@gif for i ∈ images1
    heatmap(i)
end
