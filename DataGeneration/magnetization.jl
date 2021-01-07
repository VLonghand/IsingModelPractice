# takes a CSV with flattened nxn examples 
# returns a CSV with magnetization in front of every example
include("config.jl")
using CSV
using DataFrames

df_exmpls = CSV.read("Data/rand_flat.csv", DataFrame)
exmpls = convert(Matrix, df_exmpls[:,:])
mags = []
j = 0
for i in 1:N
    append!(mags, sum(exmpls[i,:]))
end

# uncomment to if need only magnitizations
            # df_mags = DataFrame()
            # insertcols!(df_mags, 1, :mags => mags)
            # df_mags |> CSV.write("Data/Magnitizatoins.csv")
#

insertcols!(df_exmpls, 1, :mags => mags)
df_exmpls |> CSV.write("Data/Magnitizatoins_with_flat_exampels.csv")