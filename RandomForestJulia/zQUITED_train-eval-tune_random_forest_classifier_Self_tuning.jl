 using CSV
 using DataFrames
 using MLJ
# Load Data ---------------------------------------------------------
RealtivePath = "Data/Energy w All_4x4_flat.csv"
df_energies = CSV.read("$RealtivePath", DataFrame)

n = convert(Int,sqrt(size(df_energies)[2]-1))
N = convert(Int,size(df_energies)[1])
#-------------------------------------------------------------------

y, X = unpack(df_energies, ==(:energies), !=(:energies))
train, test = partition(eachindex(y), 0.3, shuffle=true)


y = coerce(y, Continuous)

tree = @load DecisionTreeRegressor
forest = EnsembleModel(atom=tree, n=100)


#-------------------------------------------------------------------
r1 = range(forest, :(atom.n_subfeatures), lower=10, upper=400)
r2 = range(forest, :(atom.min_samples_leaf), lower=1, upper=5)
# iterator(r1,100)
#iterator(r2, 5)


self_tuning_forest = TunedModel(model=forest,
                                      tuning=Grid(resolution=10),
                                      resampling=CV(nfolds=6),
                                      range=[r1,r2],
                                      measures=RootMeanSquaredError())


mach = machine(self_tuning_forest, X, y)
fit!(mach, verbosity=0)

fitted_params(mach).best_model

report(mach).best_history_entry



# fit!(tree, rows=train)

# ŷ = predict(tree, rows=test)
# vec(y[test,:])
# to_save = DataFrame(y_test = vec(y[test,:]),
#                     ŷ = ŷ)

# to_save |> CSV.write("Training$RealtivePath")
# # X[test,:]

evaluate(tree_model, X, y, resampling=CV(nfolds=5), measure=[rms, mav])   #[2][1]
