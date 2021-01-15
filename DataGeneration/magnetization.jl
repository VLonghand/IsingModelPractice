# takes a CSV with flattened nxn examples 
# returns a CSV with magnetization in front of every example
using CSV
using DataFrames

#--------IMPORTANT--------------------------------------------------
#-Only change the FileName------------------------------------------
FileName = "10000 rand_flat 8 x 8.csv"
#-------------------------------------------------------------------

# Get Data
df_exmpls = CSV.read("Data/$FileName", DataFrame)
exmpls = convert(Matrix, df_exmpls[:,:])

n = convert(Int,sqrt(size(df_exmpls)[2]))
N = convert(Int,size(df_exmpls)[1])

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