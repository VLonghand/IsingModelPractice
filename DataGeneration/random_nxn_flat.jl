# generate N grids with random distribution of -1,1 spins 
# save a to a CSV file as flat vectors 

include("config.jl")
using CSV
using DataFrames

#----------IMPORTANT----------------
# The previous file will be removed
# Make a copy to retain data
#-----------------------------------
if "rand_flat.csv" in readdir("Data")
    rm("Data/rand_flat.csv")
end

# appending vectors to a CSV; check it's more efficient to save a list of vectors instead 
for i in 1:N
    local flat = rand(-1:2:1, (1, n*n))
    df = DataFrame(flat)
    df |> CSV.write("Data/rand_flat.csv", append = true)
end

