using CSV
using DataFrames
using MLJ


# Load Data ---------------------------------------------------------
FileName = "10000 rand_flat 8 x 8.csv"
df_energies = CSV.read("Data/$FileName", DataFrame)

n = convert(Int,sqrt(size(df_energies)[2])-1)
N = convert(Int,size(df_energies)[1])
#-------------------------------------------------------------------


