# takes a csv of flat Ising Model examples 
# returns a csv with a column of corresponding energies for every example
include("config.jl")
using CSV
using DataFrames

# add simpler way to switch between different data files 
df_exmpls = CSV.read("Data/rand_flat.csv", DataFrame)
exmpls = convert(Matrix, df_exmpls[:,:])

# flat to nxn
lst_grids = []
for i in 1:N
    append!(lst_grids, [reshape(exmpls[i,:], (n,n))])
end

J = -1
energies = []
acc = 0

# calculate energies
for A in lst_grids
    for i = 1:n, j = 1:n
        local i_1 = i-1
        local j_1 = j-1
        if i == 1
            i_1 = n
        end
        if j == 1
            j_1 = n
        end
        global acc += A[i,j]*A[i_1,j]*(-J)
        global acc += A[i,j]*A[i,j_1]*(-J)
    end
    append!(energies, acc)
    global acc = 0
end

# export with original data
insertcols!(df_exmpls, 1, :energies => energies)
df_exmpls |> CSV.write("Data/Energies_with_flat_exampels.csv")