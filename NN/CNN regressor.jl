using Flux, CSV, DataFrames, Plots
using MLJ: unpack, partition
using Flux: @epochs

function get_data()
    RealtivePath = "Data/Energies w 16050 even spread.csv"
    df_energies = CSV.read("$RealtivePath", DataFrame)
    y, X = unpack(df_energies, ==(:energies), !=(:energies))

    X = convert(Array, X)
    # train, test = partition(eachindex(y), 0.25, shuffle=true)     
    train = 1:15000
    test = 0:0
    return train, test, X, y
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
    Dense(125, 1),
    )
end

# train, test, X, y = get_data()

# println(sort(unique(y)))
# E = Dict([(i,[]) for i in Es])
# for i in y 
#     push!(E[i],i)
# end
# h=[]
# for i in Es
#     push!(h, size(E[i])[end])
# end
# plot(h)
# train_dat_hits = bar(Es, h, bins=17, bar_width=3 , title="Histogram of training Data", legend=false)
# savefig(train_dat_hits, "Mardowns/CNN_train_dat_hits.png")

function trains()
    train, test, X, y = get_data()


    model = build_model() |> gpu
    ps = Flux.params(model)
    data = [(reshape(X[i,:],4,4,1,:),y[i]) for i in train ]
    # model(ones(4,4,1,1))
    
    opt = ADAM(0.001) #learning rate
    loss(x,y) = Flux.mse(model(x), y)
    @epochs 20 Flux.train!(loss, ps, data, opt )
    return model
end

function load_testing_data()
    RealtivePath = "Data/Energy w All_4x4_flat.csv"
    df_energies = CSV.read("$RealtivePath", DataFrame)
    y_all, X_all = unpack(df_energies, ==(:energies), !=(:energies))

    X_all = convert(Array, X_all)
    return X_all, y_all
end

function model_analysis()
    trained_model = trains()
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
    avg_error_per_E = [sum(error_per_E[i])/size(error_per_E[i])[end] for i in Es]

    return Es, errormines, avg_error_per_E, ys, ŷs


end
Es, errormines, avg_error_per_E, ys, ŷs = model_analysis()

avxg_error = bar(Es, avg_error_per_E, bins=15, legend=false, title="Avg Error per Energy", xlabel="Energy", ylabel="Average error")
savefig(avg_error, "Mardowns/CNN_avg_error.png")
error_hist = histogram(errormines)
savefig(error_hist, "Mardowns/CNN_error_hist.png")
yvspredy = plot(ys, ŷs, seriestype=:scatter, xlims=(-32,32),ylims=(-32,32),legend=false)
savefig(yvspredy, "Mardowns/CNN_yvspredy.png")