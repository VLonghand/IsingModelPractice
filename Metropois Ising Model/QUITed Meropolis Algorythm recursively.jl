using Colors, Plots, Images, Statistics
include("Funs.jl")



# 1. Initialize: checkerboeard pattern
#σ_00 = [-1,1,-1,1,    1,-1,1,-1,   -1,1,-1,1,   1,-1,1,-1]




function trial_move(σ_0)
    local σ = copy(σ_0)
    σ[rand(1:16)] *= -1
    return  σ
end




N = 13000
acc = 0


function accept_itter(σ_0, T)

    if acc >= N
        append!(meanMs, abs(mean(Ms)))
        return "done"
    end


    local σ_trial = copy(σ_0)
    σ_trial[rand(1:16)] *= -1

    global acc +=1
    r = rand()

    if r <= w(T, σ_trial, σ_0)  # accept
        append!(images1, [σ_trial])
        append!(Ms, M(σ_trial))   #Note, the first M might be skipped, but it doesn't matter
        accept_itter(σ_trial, T)
    else
        accept_itter(σ_0, T) # repeat
    end
end


#accept_itter(σ_00)

images1 = []
meanMs = []
Ts = []
Ms = []


for T ∈ 0:0.1:5
    local σ_00 = [-1 1 -1 1
                1 -1 1 -1
                -1 1 -1 1
                1 -1 1 -1]


    global acc = 0
    global Ms = []
    append!(Ts, T)
    accept_itter(σ_00, T)

end


unique(images1)

plot(Ts,meanMs)

# @gif for i ∈ images1
#     heatmap(i)
# end



# local σ_00 = [-1 1 -1 1 -1 1 -1
#      1 -1 1 -1 1 -1 1
#      -1 1 -1 1 -1 1 -1
#      1 -1 1 -1 1 -1 1
#      -1 1 -1 1 -1 1 -1
#      1 -1 1 -1 1 -1 1
#      -1 1 -1 1 -1 1 -1
#      ]
