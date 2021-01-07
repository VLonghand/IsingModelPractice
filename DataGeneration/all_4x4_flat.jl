# generates all possible 4x4 exmaple and exports as a CSV
using CSV
using DataFrames
v = ones(1,16)

df = DataFrame(v*-1)


function mark1(v, q)
    if q < 16
        push!(df, v)
        mark1(v,q+1)

        v[q] *= -1

        push!(df, v)
        mark1(v,q+1)
    end
end

mark1(v,1)

df |> CSV.write("Data/All_4x4_flat.csv")
findall(nonunique(df))