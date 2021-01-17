using CSV
using DataFrames
using Plots



# Load Data ---------------------------------------------------------
RealtivePath = "TrainingData/Energy w All_4x4_flat.csv"
df_test_new= CSV.read("$RealtivePath", DataFrame)

n = convert(Int,sqrt(size(df_energies)[2]-1))
N = convert(Int,size(df_energies)[1])
#-------------------------------------------------------------------

y_test = df_test_new.y_test
ŷ = df_test_new.ŷ

y_error = abs.(y_test - ŷ)

histogram(y_error, legend=false, bins=25,background_color=:grey15,
          seriescolor=:"mediumpurple4")
xlabel!("|error|")
ylabel!("# of occurences")
title!("$N total 0.7 $n x $n  even spread")
