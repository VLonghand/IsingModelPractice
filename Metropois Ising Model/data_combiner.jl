using Statistics
using Plots, CSV, DataFrames

# Initiate Mmeans.csv
function init_Mmeans_csv()
    k = (ones(1,501))
    for i in 1:501
        k[i] = i
    end 
    dfMmeans = DataFrame(k)
    delete!(dfMmeans,1)
    dfMmeans |> CSV.write("Metropois Ising Model/Phase Transition Data/Mmeans.csv")
end

init_Mmeans_csv()


# Run the algorithm N times
include("/home/vv/IsingModelPractice/Metropois Ising Model/Metropolis Algorithm itteratively.jl")

for i in 1:10
    run(`julia -p 16 "Metropois Ising Model/Metropolis Algorithm itteratively.jl" '&'`)
end


df = CSV.read("Metropois Ising Model/Phase Transition Data/Mmeans.csv", DataFrame)

col1 = df[!,4]
Ts = []
for T in 0:0.01:5  #increase
    push!(Ts, T)
end 

for row in eachrow(df)
    println(length(row))
end


d = [[],[],[]]

for col in eachcol(df)

    # get mean
    mEan = mean(col)
    push!(d[1], mEan)
    # get upper bound

    # get lower bound
end

#plot(Ts,col1)
plot(Ts, convert(Array, df[30,1:501]), label=M)
# xlabel!("Temperature")
# ylabel!("Magnetization")
# title!("Mean over N runs")  
