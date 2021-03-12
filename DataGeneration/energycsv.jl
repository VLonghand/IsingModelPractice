# takes a csv of flat Ising Model examples
# returns a csv with a column of corresponding energies for every example
using CSV
using DataFrames

# add simpler way to switch between different data files
#--------IMPORTANT--------------------------------------------------
#-Only change the FileName------------------------------------------
# Dir = "Data"
# Name = "Name of file"
# function Get_Dir_NameStr(Dir, Name)
#     global Dir = Dir
#     global Name = Name
# end
#-------------------------------------------------------------------
J = -1
#energies = []
#acc = 0
function import_energy_export_w_grids(Dir, Name)
    energies = []
    acc = 0
    # Get Data
    df_exmpls = CSV.read("$Dir/$Name", DataFrame)
    exmpls = convert(Matrix, df_exmpls[:,:])

    n = convert(Int,sqrt(size(df_exmpls)[2]))
    N = convert(Int,size(df_exmpls)[1])

    # flat to nxn
    lst_grids = []
    for i in 1:N
        append!(lst_grids, [reshape(exmpls[i,:], (n,n))])
    end



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
            acc += A[i,j]*A[i_1,j]*(-J)
            acc += A[i,j]*A[i,j_1]*(-J)
        end
        append!(energies, acc)
        acc = 0
    end

    # export with original data
    insertcols!(df_exmpls, 1, :energies => energies)
    Int8.(df_exmpls) |> CSV.write("$Dir/Energy w $Name")
    DataFrame("energies" => energies) |> CSV.write("$Dir/Energy.csv")
    energies=nothing
    df_exmpls=nothing
end
