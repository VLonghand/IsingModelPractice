

# Function to calculate Hamiltonian of an Ising Model state

function H(spin_vec)
    acc = 0
    n = 4
    J = 1
    spin_vec = reshape(spin_vec, (n,n))

    for i = 1:n, j = 1:n
        local i_1 = i-1
        local j_1 = j-1
        if i == 1
            i_1 = n
        end
        if j == 1
            j_1 = n
        end
        acc += spin_vec[i,j]*spin_vec[i_1,j]*(-J)
        acc += spin_vec[i,j]*spin_vec[i,j_1]*(-J)
    end
    return acc
end
