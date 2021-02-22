
 Pkg.add("MLJDecisionTreeInterface")
 using CSV
 using DataFrames
 using MLJ
# Load Data ---------------------------------------------------------
RealtivePath = "Data/Energy w All_4x4_flat.csv"
df_energies = CSV.read("$RealtivePath", DataFrame)

n = convert(Int,sqrt(size(df_energies)[2]-1))
N = convert(Int,size(df_energies)[1])
#-------------------------------------------------------------------

schema(df_energies)

# coerce!(df_energies, autotype(df_energies))

y, X = unpack(df_energies, ==(:energies), !=(:energies))
y = coerce(y, OrderedFactor)

tree_model = @load DecisionTreeClassifier

tree = machine(tree_model, X, y)

train, test = partition(eachindex(y), 0.7, shuffle=true)

fit!(tree, rows=train)

ŷ = predict(tree, rows=test)
Ŷ = categorical(mode.(ŷ))

to_save = DataFrame(y_test = vec(y[test,:]),
                    ŷ = Ŷ)



to_save |> CSV.write("Training$RealtivePath")
# X[test,:]

#evaluate(tree_model, X, y, resampling=CV(nfolds=5), measure=[rms, mav])   #[2][1]
