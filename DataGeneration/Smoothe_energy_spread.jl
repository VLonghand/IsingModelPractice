using CSV
using DataFrames


function smoothe_energy(Dir, Name, num_of_examples)

    # Get Data----------------------------------------------------------
    df_energies = CSV.read("$Dir/$Name", DataFrame)

    n = convert(Int,sqrt(size(df_energies)[2]-1))
    N = convert(Int,size(df_energies)[1])
    #-------------------------------------------------------------------


    # via map function
    # check first element in row if COND true then export and edit looking_for dict
    # COND = element belongs to set p


    # make looking_for dict
    looking_for = Dict()
    for i in -(n*n*2):2:(n*n*2)
        looking_for["$i"] = num_of_examples #first entry "-32" => 12
    end

    df_energies_even_spread = DataFrame()

    # make function to map
    function row_checker_expoter(row)
        # check the first against dict and export
        local energy = convert(Int, row[1])
        if looking_for["$energy"] > 0
            push!(df_energies_even_spread, row)
            looking_for["$energy"] -= 1
        end
    # could make faster, by it stop when number of exaples is num_of_exmaples_per*(n*n-2)-4
    # -2 for empty 28, -28 and -4 for only 2 32 and 2 -32 examples
    end

    map(row_checker_expoter, eachrow(df_energies))

    # only 2 exmpeles for each of -32, 32; fix that
    while looking_for["32"] + looking_for["-32"] > 0
        map(row_checker_expoter, eachrow(df_energies_even_spread))
    end
    df_energies_even_spread_tosave = Int8.(df_energies_even_spread)
    # save file
    df_energies_even_spread_tosave |> CSV.write("$Dir/even spread $num_of_exmaples_per $FileName.csv")
end
