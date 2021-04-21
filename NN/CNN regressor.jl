using Flux, CSV, DataFrames, Plots, Statistics
using MLJ: unpack, partition
using Flux: @epochs

function get_data()
    RealtivePath = "Data/Energy w All_4x4_flat.csv"
    df_energies = CSV.read("$RealtivePath", DataFrame)
    y, X = unpack(df_energies, ==(:energies), !=(:energies))

    X = convert(Array, X)
    train, test = partition(eachindex(y), 0.25, shuffle=true) 
        
    # train = 1:15000
    # test = 0:0

    train1 = copy(train)
    bats = []
    N_bat = 160
    per_bat = Int(floor(size(train)[end]/160))
    for i in 1:N_bat
        push!(bats, [train[1:per_bat]])
        deleteat!(train1, 1:per_bat)
    end




    return bats, test, X, y
end 

function build_model()
    return Chain(
    Conv((2,2),1=>5,relu),
    Conv((2,2), 5=>3,pad=(1,1), relu),
    Conv((2,2), 3=>3,pad=(1,1), relu),
    Conv((2,2), 3=>5,relu),
    Conv((2,2), 5=>3,pad=(1,1), relu),
    Conv((2,2), 3=>3,pad=(1,1), relu),
    Conv((2,2), 3=>5,relu),
    Flux.flatten,
    Dense(125, 64),
    Dense(64, 1)
    )
end

function plotandsave_training()
    train, test, X, y = get_data()
    Es = [-32, -24, -20, -16, -12, -8, -4, 0, 4, 8, 12, 16, 20, 24, 32]

    println(sort(unique(y)))
    E = Dict([(i,[]) for i in Es])
    for i in y 
        push!(E[i],i)
    end
    h=[]
    for i in Es
        push!(h, size(E[i])[end])
    end
    plot(h)
    train_dat_hits = bar(Es, h, bins=17, bar_width=3 , title="Histogram of training Data", legend=false)
    savefig(train_dat_hits, "Mardowns/CNN-rand_train_dat_hits.png")
end

function trains()
    bats, test, X, y = get_data()
    losses = []
    model = build_model()
    ps = Flux.params(model)
    # data = [(reshape(X[i,:],4,4,1,:),y[i]) for i in train ]
    model(ones(4,4,1,1))
    
    opt = ADAM(0.001) #learning rate
    loss(x,y) = Flux.mse(model(x), y)

    for i in 1:160
        train_bat = bats[i]

        function evalcb()
            x_test = [reshape(X[i,:],4,4,1,:) for i in train_bat]
            y_test = [y[i] for i in train_bat ]
                              
            # loss2(x,y) = (y - model(x))^2
            # avg_loss = mean([loss2(x,y) for x in x_test for y in y_test])
            avg_loss = mean([loss(x,y) for x in x_test for y in y_test])
            push!(losses, avg_loss)
            @show(avg_loss)             
        end
        
        data = [(reshape(X[i,:],4,4,1,:),y[i]) for i in train_bat ]
        @epochs Flux.train!(loss, ps, data, opt, cb = Flux.throttle(evalcb, 1))
    end
    return model, losses
end

trained_model, losses = trains()

function load_testing_data()
    RealtivePath = "Data/Energy w All_4x4_flat.csv"
    df_energies = CSV.read("$RealtivePath", DataFrame)
    y_all, X_all = unpack(df_energies, ==(:energies), !=(:energies))

    X_all = convert(Array, X_all)
    return X_all, y_all
end

function model_analysis()
    # trained_model = trains()
    X,y = load_testing_data()

    Es = [-32, -24, -20, -16, -12, -8, -4, 0, 4, 8, 12, 16, 20, 24, 32]
    errormines = []
    error_per_E = Dict([(i,[]) for i in Es])
    ys = []
    ŷs = []
    for i in 1:65536 
        ŷ = trained_model(reshape(X[i,:],4,4,1,:))[1]
        errormine = y[i] - ŷ
        push!(errormines, errormine)
        push!(error_per_E[y[i]], errormine)
        push!(ys, y[i])
        push!(ŷs, ŷ)
    end
    avg_error_per_E = [sum(abs.(error_per_E[i]))/size(error_per_E[i])[end] for i in Es]

    return Es, errormines, avg_error_per_E, ys, ŷs


end
# function plotandsave_results()

Es, errormines, avg_error_per_E, ys, ŷs = model_analysis()

avg_error = bar(Es, avg_error_per_E, bins=15, legend=false, title="Avg |Error| per Energy", xlabel="Energy", ylabel="Average error")
# savefig(avg_error, "Mardowns/CNN-rand_avg_error.png")
error_hist = histogram(errormines, title="Histogram of errors", legend=false)
# savefig(error_hist, "Mardowns/CNNv-rand_error_hist.png")
yvspredy = plot(ys, ŷs, seriestype=:scatter,
title="Known energies vs predicted energies", xlabel="Known E", ylabel="Predicted E",
xlims=(-32,32),ylims=(-32,32),legend=false)
# savefig(yvspredy, "Mardowns/CNN-rand_yvspredy.png")
# end

plotandsave_results()

plot(log10.(1:16000), losses, legend=false, xlabel="log10(cycles)", ylabel="loss as MSE")