RealtivePath = "Data/Energy w All_4x4_flat.csv"
df_energies = CSV.read("$RealtivePath", DataFrame)
y, X = unpack(df_energies, ==(:energies), !=(:energies))

X = convert(Array, X)
train, test = partition(eachindex(y), 16000//65336, shuffle=true)   
train1 = copy(train)  
# train = 1:15000
# test = 0:0
function make_batches(size=100)
    arr_bat = []
    fun() = 100 < (size(train1)[end])
    while fun()
        bat = []
        for i in 1:size
            push!(bat, [X[]])
        
    end




    return arr_bat
end

arr_bat = make_batches()

size(train1)[end]