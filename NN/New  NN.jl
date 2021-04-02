using Flux, CSV, DataFrames, Plots
using MLJ: unpack, partition
using Flux: @epochs


function get_data()
    RealtivePath = "Data/Energy w All_4x4_flat.csv"
    df_energies = CSV.read("$RealtivePath", DataFrame)
    y, X = unpack(df_energies, ==(:energies), !=(:energies))

    X = convert(Array, X)
    train, test = partition(eachindex(y), 0.25, shuffle=true)     
    return train, test, X, y
end 
train, test, X, y = get_data()

function build_model()
    return Chain(
    Dense(16,32,relu),
    Dense(32, 64, relu),
    Dense(64, 150),
    Dense(150,30),
    Dense(30, 1),
    )
end




function trains()
    model = build_model() |> gpu
    ps = Flux.params(model)
    data = [(X[i,:],y[i]) for i in train ]
    model(ones(1,16))

    opt = ADAM(0.001) #learning rate
    loss(x,y) = Flux.mse(model(x), y)
    @epochs 20 Flux.train!(loss, ps, data, opt )
    return model
end

# trained_model = trains()


function model_analysis()
    trained_model = trains()

    Es = [-32, -24, -20, -16, -12, -8, -4, 0, 4, 8, 12, 16, 20, 24, 32]
    errormines = []
    error_per_E = Dict([(i,[]) for i in Es])
    ys = []
    ŷs = []
    for i in 1:65536
        ŷ = trained_model(X[i,:])[1]
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

avg_error = bar(Es, avg_error_per_E, bins=15, legend=false, title="Avg Error per Energy", xlabel="Energy", ylabel="Average error")
savefig(avg_error, "Mardowns/NN_avg_error.png")
error_hist = histogram(errormines, title="Error Histogram")
savefig(error_hist, "Mardowns/NN_error_hist.png")
yvspredy = plot(ys, ŷs, seriestype=:scatter, title="Known vs Predicted",
 xlabel="Known energies", ylabel="Predicted energies", xlims=(-32,32),ylims=(-32,32),legend=false)
savefig(yvspredy, "Mardowns/NN_yvspredy.png")