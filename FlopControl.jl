# This is where you import other files and run functoins

include("DataGeneration/random_nxn_flat.jl")
saveAfter(90000, 7)


include("DataGeneration/energy.jl")
import_energy_export_w_grids("Data", "90000 rand_flat 7 x 7.csv")


include("DataGeneration/Smoothe_energy_spread.jl")
smoothe_energy("Data","Energy w 90000 rand_flat 7 x 7.csv", 99)



include("Plots_and_funcs/Histograms.jl")
histog_csv("Data/Energy w 90000 rand_flat 7 x 7.csv","energies", 64)
