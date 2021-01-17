
 Pkg.add("MLJDecisionTreeInterface")
 using CSV
 using DataFrames
 using MLJ
# Load Data ---------------------------------------------------------
RealtivePath = "Data/Energies_even_spread_20.csv"
df_energies = CSV.read("$RealtivePath", DataFrame)

n = convert(Int,sqrt(size(df_energies)[2]-1))
N = convert(Int,size(df_energies)[1])
#-------------------------------------------------------------------

# scitype(df_energies)

coerce!(df_energies, autotype(df_energies))
y, X = unpack(df_energies, ==(:energies), !=(:energies))

# models(matching(X,y))

tree_model = @load DecisionTreeClassifier

tree = machine(tree_model, X, y)

train, test = partition(eachindex(y), 0.7, shuffle=true)

fit!(tree, rows=train)

predic_set = predict(tree, rows=test)
vec(y[test,:])
to_save = DataFrame(y_test = vec(y[test,:]),
                    y_new = predic_set)

to_save |> CSV.write("Training$RealtivePath")
# X[test,:]
