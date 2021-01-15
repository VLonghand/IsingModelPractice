# generate N grids with random distribution of -1,1 spins 
# save a to a CSV file as flat vectors 

using CSV
using DataFrames

N = 30000
n = 4

#----------IMPORTANT----------------
# The previous file will be removed
# Make a copy to retain data
#-----------------------------------
    # if "$N/rand_flat$n/x$n.csv" in readdir("Data")
    #     rm("Data/$N/rand_flat$n/x$n.csv")
    # end
# add names

# g = [i*j for i = 1, j=1:1:n*n]
# lables = convert(Vector{Any}, [i*j for i = 1, j=1:1:n*n])
# f = DataFrame(lables)

# push!(f, lables)

# f |> CSV.write("Data/rand_flat.csv", append = true)


# appending vectors to a CSV; check it's more efficient to save a list of vectors instead 
function saveSlow()
    for i in 1:N
        local flat = rand(-1:2:1, (1, n*n))
        local df = DataFrame(flat)
        df |> CSV.write("Data/rand_flat.csv", append = true)
    end
end

# This is much faster
function saveAfter()
    local df = DataFrame(rand(-1:2:1, (1, n*n)))
    for i in 1:(N-1)
        local flat = rand(-1:2:1, (1, n*n))
        push!(df, flat)
    end
    df |> CSV.write("Data/$N rand_flat $n x $n.csv")
    df = nothing
end

saveAfter()