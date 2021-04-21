using Flux, MLJ, DataFrames, Plots, CSV
using MLJ: unpack, partition
using Flux: @epochs, onehotbatch, onecold
using Flux.Losses: logitcrossentropy
using Flux.Data:DataLoader
using Statistics: mean

function get_data()
    # Loads data as DataFrame
    RealtivePath = "Data/Energy w All_4x4_flat.csv"
    df_energies = CSV.read("$RealtivePath", DataFrame)

    

    # n = convert(Int,sqrt(size(df_energies)[2]-1))
    # N = convert(Int,size(df_energies)[1])

    # separates energies and states 
    y, X = unpack(df_energies, ==(:energies), !=(:energies))
    y = Float32.(y) # there is an issue with unmatched types


    Es = [-32, -24, -20, -16, -12, -8, -4, 0,4,8,12,16,20,24,32]

    # train ans test indexes within set
    train, test = partition(eachindex(y), 0.25, shuffle=true)

    # input of Conv is an (n,m,ch,i) nxm image, ch channels and i - index within data set
    X = convert(Matrix, X) # dataframe into matricies 
    X_train, X_test = reshape(X[train,:], 4,4,1,:), reshape(X[test, :],4,4,1,:)
    # working with a classifier so onehot, and onehotbatch to apply to set, not an element
    Y_train, Y_test = onehotbatch(y[train], Es), onehotbatch(y[test], Es) 

    train_loader = DataLoader((X_train, Y_train), batchsize=100) # no need to shuffle, already atchieved through rand
    test_loader = DataLoader((X_test, Y_test), batchsize=100)

    # x_test, y_test will be used for train! to calculate loss after every epoch
    # right now they are random, but should include at least one of each E
    x_test, y_test = [X_test[:,:,:,1]], [Y_test[:,1]]
    for i in 2:100
        append!(x_test, [X_test[:,:,:,i]])
        append!(y_test, [Y_test[:,i]])
    end

    return train_loader, test_loader, reshape.(x_test, 4,4,1,:), y_test
end

train_loader, test_loader, x_test, y_test = get_data()


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
    Dense(64, 15)
    )
end

# returns the energy representation of the onehot and result of model
function onehot_to_E(onehot_vec)
    Es = [-32, -24, -20, -16, -12, -8, -4, 0,4,8,12,16,20,24,32]
    E = Es[onecold(onehot_vec)[end]] #onecold returns the index of labels
    return E
end

function trains()
    data = train_loader

    model = build_model()
    ps = Flux.params(model)
    print(model(ones(4,4,1,1)))

    loss(x, y) = logitcrossentropy(model(x), y)

    test_x, test_y = [(x,y) for (x,y) in train_loader]
    loss2(x,y) = (onehot_to_E(y)-onehot_to_E(model(x)))^2
    losses = [] 
    function evalcb()
        avg_loss = mean([loss(x,y) for x in x_test for y in y_test])
        push!(losses, avg_loss)
        @show(avg_loss)

    end

    opt = ADAM(0.001) #learning rate
    
    @epochs 200 Flux.train!(loss2, ps, data, opt, cb = Flux.throttle(evalcb,1))
    return model, losses
end

model, losses = trains()

# Evaluate ---------------------------------------------------------

# pass all testing data into model
function pass_test()
    ŷs = []
    ys = []
    error1 = []
    for (x,y) in test_loader
        Ŷ = onehot_to_E(model(x))
        Y = onehot_to_E(y)
        push!(ŷs, Ŷ)
        push!(ys, Y)
        err = Y - Ŷ
        append!(error1, err)
    end
    return ŷs, ys, error1 
end
ŷs, ys, error1  = pass_test()
# function plotandsave_results()

# loss per epoch
plot( 1:200, losses, title="Loss per epoch", xlabel="epoch", ylabel="log(loss)", legend=false)

#Es, errormines, avg_error_per_E, ys, ŷs = model_analysis()


# avg_error = bar(Es, avg_error_per_E, bins=15, legend=false, title="Avg |Error| per Energy", xlabel="Energy", ylabel="Average error")
# savefig(avg_error, "Mardowns/CNN-rand_avg_error.png")
error_hist = histogram(error1, title="Histogram of errors", legend=false)
# savefig(error_hist, "Mardowns/CNNv-rand_error_hist.png")
yvspredy = plot(ys, ŷs, seriestype=:scatter,
                title="Known energies vs predicted energies",
                xlabel="Known E", ylabel="Predicted E",
                xlims=(-32,32),ylims=(-32,32),legend=false)
# savefig(yvspredy, "Mardowns/CNN-rand_yvspredy.png")
# end

# plotandsave_results()