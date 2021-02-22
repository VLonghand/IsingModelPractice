using CSV, MLJ, DataFrames


# Change from CPU1, so all that can utilize multiprocessing 
using ComputationalResources, Distributed
MLJ.default_resource(CPUProcesses())


# Load Data ---------------------------------------------------------
RealtivePath = "Data/Energy w All_4x4_flat.csv"
df_energies = CSV.read("$RealtivePath", DataFrame)

n = convert(Int,sqrt(size(df_energies)[2]-1))
N = convert(Int,size(df_energies)[1])

@everywhere y, X = unpack(df_energies, ==(:energies), !=(:x1))
# 'Scientific Type' has to be continuous for regression
y = coerce(y, Continuous) # The special data types for Training

train, test = partition(eachindex(y), 0.3, shuffle=true) # "Energy w All_4x4_flat" is not randomly distributed, so shuffle=true

#-------------------------------------------------------------------



# Set up model -----------------------------------------------------
@load DecisionTreeRegressor
tree = DecisionTreeRegressor() # this is a single tree, not a forest
forest = EnsembleModel(atom=tree, bagging_fraction=0.3, n=400) # 400 is the number of trees
mach = machine(forest, X, y)

#-------------------------------------------------------------------

evaluate!(mach, measures=RootMeanSquaredError())


# Fit and evaluate -------------------------------------------------
r_trees = range(ensemble, :(atom.n_subfeatures), lower=10, upper=400, scale=:log)
curve = MLJ.learning_curve(mach;
                            range = r_trees,
                            resampling=CV(nfolds=3),
                            measures=RootMeanSquaredError())



fit!(forest, rows=train)



y_new = predict(mach, X[test,:])
y_old  = y[test]
error1 = y_old - y_new

#-------------------------------------------------------------------


# Plot results -----------------------------------------------------
using Plots

plot(curve.parameter_values,
    curve.measurements,
    xlab=curve.parameter_name,
    xscale=curve.parameter_scale,
    ylab = "CV estimate of RMS error")

#histogram(error1)
#plot(y_old,y_new)


#-------------------------------------------------------------------