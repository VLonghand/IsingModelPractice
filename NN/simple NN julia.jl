using Flux, CSV, DataFrames
using Flux.Data:DataLoader
using Flux: onehotbatch, onecold
using MLJ: unpack, partition
using Flux.Losses: logitcrossentropy
using Plots


labels = [-32, -24, -20, -16, -12, -8, -4, 0, 4, 8, 12, 16, 20, 24, 32]
# Load Data --------------------------------------------------------
test = []
train = []

RealtivePath = "Data/Energy w All_4x4_flat.csv"
df_energies = CSV.read("$RealtivePath", DataFrame)



# n = convert(Int,sqrt(size(df_energies)[2]-1))
# N = convert(Int,size(df_energies)[1])

y, X = unpack(df_energies, ==(:energies), !=(:energies))


X = convert(Matrix, X)
global train, test = partition(eachindex(y), 0.25, shuffle=true) 
X_train, X_test = reshape(X[train,:], 4,4,1,:), reshape(X[test, :],4,4,1,:)
y_train, y_test = onehotbatch(y[train], labels), onehotbatch(y[test], labels)

train_loader = DataLoader((X_train, y_train), batchsize=100) # no need to shuffle, already atchieved through rand
test_loader = DataLoader((X_test, y_test))
# ------------------------------------------------------------------

# loss(ŷ, y) = logitcrossentropy(ŷ, y)

loss(ŷ, y) = Flux.mse(ŷ, y)

model =  Chain(
    # Conv((2,2),1=>1,pad=(1,1),relu),
    Flux.flatten,
    Dense(16,150,relu),
    Dense(150, 15)
    )
print(model(ones(4,4,1,1))) #this precomples the model

opt = ADAM()

ps = Flux.params(model) 
acc=0
ntot=0
for epoch in 1:3
    for (x,y) in train_loader
        x, y = x |> gpu, y |> gpu 
        gs = Flux.gradient(ps) do 
            ŷ = model(x)
            loss(ŷ, y)                
        end
        Flux.Optimise.update!(opt, ps, gs)
    end
    return (loss)
end


ladles = Dict([(i,[]) for i in labels])
ys = []
y_news = []
for (x,y) in test_loader
    y = Int(onecold(y)[1]) # this returns in 1:15 range
    y = labels[y] #1:15 to [-32, -24, ..., 24, 32]
    push!(ys, y)
    y_new = onecold(model(x))[1]
    y_new = labels[y_new]
    push!(y_news, y_new)
    error_mine = y - y_new
    push!(ladles[y], error_mine)
end

avgs = []
for i in labels
    if size(ladles[i])[end] > 0
        avg = sum(ladles[i])/size(ladles[i])[end]
        push!(avgs, avg)
end
end

# Error
errors = []
for i in 1:size(ys)[end]
    error2 = ys[i] - y_news[i]
    push!(errors, error2)
end

println(sort(unique(y_news)))
println(sort(unique(ys)))

bar(labels, avgs, bins=15, legend=false, title="Avg Error per Energy", xlabel="Energy", ylabel="Average error")
plot(ys,y_news,seriestype = :scatter)
histogram(errors)