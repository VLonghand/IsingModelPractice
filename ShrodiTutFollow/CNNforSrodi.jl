using HDF5, Flux, Plots

data = h5open("ShrodiTutFollow/schrodinger_data.h5", "r")
data["energy"][1,:]
data["kx"][1]