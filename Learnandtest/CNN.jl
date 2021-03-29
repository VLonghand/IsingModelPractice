using Flux, CSV, DataFrames
using Flux.Data:DataLoader
using Flux: onehotbatch, onecold
using MLJ: unpack, partition
using Flux.Losses: logitcrossentropy


labels = [-32, -24, -20, -16, -12, -8, -4, 0,4,8,12,16,20,24,32]
# Load Data ---------------------------------------------------------
function get_data()
    RealtivePath = "Data/Energy w All_4x4_flat.csv"
    df_energies = CSV.read("$RealtivePath", DataFrame)

    

    # n = convert(Int,sqrt(size(df_energies)[2]-1))
    # N = convert(Int,size(df_energies)[1])

    y, X = unpack(df_energies, ==(:energies), !=(:energies))
    y = Float32.(y)


    labels = [-32, -24, -20, -16, -12, -8, -4, 0,4,8,12,16,20,24,32]

    X = convert(Matrix, X)
    train, test = partition(eachindex(y), 0.25, shuffle=true) 
    X_train, X_test = reshape(X[train,:], 4,4,1,:), reshape(X[test, :],4,4,1,:)
    y_train, y_test = onehotbatch(y[train], labels), onehotbatch(y[test], labels)

    train_loader = DataLoader((X_train, y_train), batchsize=100) # no need to shuffle, already atchieved through rand
    test_loader = DataLoader((X_test, y_test), batchsize=100)

    return train_loader, test_loader
end

loss(ŷ, y) = logitcrossentropy(ŷ, y)

model =  Chain(
    Conv((2,2),1=>1,pad=(1,1),relu),
    Flux.flatten,
    Dense(25,64,relu),
    Dense(64, 15)
    )

train_loader, test_loader = get_data()

opt = ADAM()

ps = Flux.params(model) 
acc=0
ntot=0
for epoch in 1:10
    for (x,y) in train_loader
        x, y = x |> cpu, y |> cpu 
        gs = Flux.gradient(ps) do 
            ŷ = model(x)
            loss(ŷ, y)                
        end
        Flux.Optimise.update!(opt, ps, gs)
    end
    return (loss)
end


error1 = []
ŷs = []
ys = []
for (x,y) in test_loader
    x, y = x |> cpu, y |> cpu 
    ŷ = model(x)
    push!(ŷs, onecold(ŷ |> cpu))
    push!(ys, onecold(y |> cpu))
    err = onecold(y |> cpu) - onecold(ŷ |> cpu)
    append!(error1, err)
end

print(model(ones(4,4,1,1)))

using Plots
histogram(abs.(error1), bins=15, bar_width=0.4)
print(sum(error1)/size(error1)[1])

Plots.pyplot()
Plots.PyPlotBackend()
scatter!(ys,ŷs) 
plot(p1)