
 Pkg.add("MLJDecisionTreeInterface")
 using CSV
 using DataFrames
 using MLJ
# Load Data ---------------------------------------------------------
RealtivePath = "Data/Energy w 15000 rand_flat 4 x 4.csv"
df_energies = CSV.read("$RealtivePath", DataFrame)

n = convert(Int,sqrt(size(df_energies)[2]-1))
N = convert(Int,size(df_energies)[1])
#-------------------------------------------------------------------

y, X = unpack(df_energies, ==(:energies), !=(:energies))

y = coerce(y, OrderedFactor)
levels(y)

tree = @load DecisionTreeClassifier
forest = EnsembleModel(atom=tree)


#-------------------------------------------------------------------
#r1 = range(forest, :(atom.n_subfeatures), lower=40, upper=400)
r2 = range(forest, :bagging_fraction, lower=0.4, upper=1.0)
iterator(r1,100)
iterator(r2, 5)


self_tuning_forest = TunedModel(model=forest,
                                      tuning=Grid(),
                                      resampling=CV(nfolds=6),
                                      range=[r2],
                                      measures=BrierLoss())


mach = machine(self_tuning_forest, X, y)
fit!(mach, verbosity=0)

fitted_params(mach).best_model

report(mach).best_history_entry


train, test = partition(eachindex(y), 0.7, shuffle=true)

fit!(tree, rows=train)

ŷ = predict(tree, rows=test)
vec(y[test,:])
to_save = DataFrame(y_test = vec(y[test,:]),
                    ŷ = ŷ)

to_save |> CSV.write("Training$RealtivePath")
# X[test,:]

evaluate(tree_model, X, y, resampling=CV(nfolds=5), measure=[rms, mav])   #[2][1]
