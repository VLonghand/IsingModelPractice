using CSV, MLJ, DataFrames

# using Distributed
# addprocs(16)
# print(nprocs())
# print(nworkers())


# Change from CPU1, so all that can utilize multiprocessing 
using ComputationalResources, Distributed
MLJ.default_resource(CPUProcesses())


# Load Data ---------------------------------------------------------
RealtivePath = "Data/Energy w All_4x4_flat.csv"
df_energies = CSV.read("$RealtivePath", DataFrame)

n = convert(Int,sqrt(size(df_energies)[2]-1))
N = convert(Int,size(df_energies)[1])

y, X = unpack(df_energies, ==(:energies), !=(:x1))
# 'Scientific Type' has to be continuous for regression
y = coerce(y, Continuous) # The special data types for Training

train, test = partition(eachindex(y), 0.3, shuffle=true) # "Energy w All_4x4_flat" is not randomly distributed, so shuffle=true

#-------------------------------------------------------------------



# Set up model -----------------------------------------------------
@load DecisionTreeRegressor
tree = DecisionTreeRegressor() # this is a single tree, not a forest
forest = EnsembleModel(atom=tree) # 400 is the number of trees
# mach = machine(forest, X, y)

#-------------------------------------------------------------------

#evaluate!(mach, measures=RootMeanSquaredError())


# Fit and tune -------------------------------------------------
forest_tuning = TunedModel(model = forest,
                        tuning=Grid(goal=10),
                        resampling=CV(nfolds=3),
                        range=[range(forest, :n, lower=10, upper=400, scale=:log),
                               range(forest, :(atom.post_prune), values=[true, false]),
                               range(forest, :bagging_fraction, values=[0.1,0.2,0.3]) 
                               ],
                        measures=rms,

                        acceleration=CPUProcesses(),
                        check_measure=true

                    )

mach = machine(forest_tuning, X, y)

# for 1 hyperparameter investigation -------------------------------
# curve = MLJ.learning_curve(mach;
#                             range = r_trees,
#                             resampling=CV(nfolds=3),
#                             measures=RootMeanSquaredError())



fit!(mach, rows=train)

report(mach).best_report
#-------------------------------------------------------------------


# Plot results -----------------------------------------------------
using Plots

# plot(curve.parameter_values,
#     curve.measurements,
#     xlab=curve.parameter_name,
#     xscale=curve.parameter_scale,
#     ylab = "CV estimate of RMS error")

y_new = predict(mach, X[test,:])
y_old  = y[test]
error1 = y_old - y_new

histogram(error1)
plot(y_old,y_new)

# evaluate!(mach, measure=rms, rows=test)

#-------------------------------------------------------------------


# Save model -------------------------------------------------------
using JLD

save("RandomForestJulia/models/RFR_rand_distrib.jld", "model", mach)


#-------------------------------------------------------------------