module FunsForSquareInsingModel

export H, M, w

# Function to calculate Hamiltonian of an Ising Model state
# Input: a flatened 4x4 grid
function H(spin_grid)
    acc = 0
    n = 4
    J = 1
    #spin_grid = reshape(spin_vec, (n,n))


    for i = 1:n, j = 1:n
        local i_1 = i-1
        local j_1 = j-1
        if i == 1
            i_1 = n
        end
        if j == 1
            j_1 = n
        end
        acc += spin_grid[i,j]*spin_grid[i_1,j]*(-J)
        acc += spin_grid[i,j]*spin_grid[i,j_1]*(-J)
    end
    return acc
end


# Calculate magentization of an Ising state
function M(spin_grid)
    return sum(spin_grid)
end


# π(σ_trial)/π(σ_0)
# function to calculate ratio or probability dencities, w
function w(T, σ_trial, σ_0)
    β = 1/T
    return exp(-β*(H(σ_trial) - H(σ_0)))
end

end