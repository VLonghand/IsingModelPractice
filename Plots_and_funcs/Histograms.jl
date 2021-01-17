using CSV
using DataFrames
using Plots

# get data



# plot first elements as a histogram
function histog_csv(Path::String, which_col, binnies)
    local df = CSV.read("$Path", DataFrame)
    histogram(df[:,"$which_col"], bins=binnies, bar_width=3, legend = false)
    xlabel!("energy")
    ylabel!("# of samples")
    print(maximum(df.energies))
end
