using   Plots, LinearAlgebra, SparseArrays, UnicodePlots
using Arpack

# This should be include friendly

# Simple harmonic oscilator to test slover 
function SHO(L, kx,ky,cx=0,cy=0)
    xy = range(-20,20,length=L)

    # TODO: find a way to make this more efficient 
    V = ones(L,L)
    for i in 1:L
        for j in 1:L
        V[j,i] = 0.5 * (kx*(xy[i]-cx)^2 + ky*(xy[j]-cy)^2)
        end
    end
    return V
end

# V = SHO(L,2,1,0,0)
# Plots.heatmap(V, c=:amp)

begin
    # Analysical vs finite difference
    L = 256
    limit=20
    x=range(-limit, limit, length=L)
    y=copy(x)
    dx = x[2]-x[1]
    dy = y[2]-y[1]

    # constructing second derivative matrix
    dia_len = sqrt(L^2^2*2)
end


# (-∇²+V̂)ψ = εψ
# T̂ = -∇²

begin
    # di = (2*dx*dy) 
    # this constructs the enire second derivative operator 
    T̂ = spdiagm(0=>[4 for i in 1:L^2], 1=>[-1 for i in 1:(L^2-1)],
                -1=>[-1 for i in 1:(L^2-1)], L=>[-1 for i in 1:(L-1)^2],
                -L=>[-1 for i in 1:(L-1)^2])

    # UnicodePlots.spy(T̂) # quick way to check the diagonals

    T̂ = T̂/(2*dx*dy)
end

# julia is does column major everything 
# I thought it might cause an error, but I'm wrong 
# this is useless
function row_major_flatten(mop::Matrix)
    vesc=[]
    for rows in eachrow(mop)
        append!(vesc, rows)
    end
    return vesc
end


# T̂ = convert(SparseMatrixCSC{Float32,Int64},T̂)
function solve1(potential)
    V = spdiagm(0=>potential[:])
    # V is an Array{Any,2}, I don't know why {Any}
    V = convert(SparseMatrixCSC{Float32,Int64},V) # without this eigs spits arror about {Any}

    H = V + T̂

    # TODO: 𝜓 is a waste of memory
    𝜆, 𝜓 = eigs(H, nev=1, which=:SM) # nev=1 cause we don't need others
    return 𝜆, 𝜓
end


# Testing solver on SHO
function test_solver_w_SHO()

    num = 10
    kx = rand(num)*0.16
    ky = rand(num)*0.16
    cx = (rand(num).-0.5).*16
    cy = (rand(num).-0.5).*16

    for i in 1:num
        𝜆, 𝜓 = solve1(SHO(L, kx[i],ky[i],cy[i],cx[i]))
        # print(𝜆)
        numerical = round(real(𝜆[1]), digits=5)
        analytical = round(0.5 * (sqrt(kx[i]) + sqrt(ky[i])), digits=5)
        error = round(100*abs(numerical-analytical)/analytical, digits=5)
        print("Numerical: $numerical,  Analysical: $analytical, Error: $error% \n")
    end 
end
# test_solver_w_SHO()