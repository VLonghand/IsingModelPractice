using CSV
using DataFrames
using Plots

# get data 



# plot first elements as a histogram
function histog_csv(Path::String, which_col, binnies)
    local df = CSV.read("$Path", DataFrame)
    histogram(df[:,"$which_col"], bins=binnies, bar_width=3, xticks=[-32:32])
    xlabel!("energy")
    ylabel!("#")
end

histog_csv("Data/Energy w 10000 rand_flat 8 x 8.csv","energies", 64)
