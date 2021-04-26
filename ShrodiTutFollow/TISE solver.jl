using   Plots, LinearAlgebra, SparseArrays, UnicodePlots
using Arpack

# This should be include friendly

# Simple harmonic oscilator to test slover 
function SHO(grid1, xy, L, kx, ky;cx=0,cy=0)
    

    # TODO: find a way to make this more efficient 
    
    for i in 1:L
        for j in 1:L
        grid1[j,i] = 0.5 * (kx*(xy[i]-cx)^2 + ky*(xy[j]-cy)^2)
        end
    end

    return grid1
end

# V = SHO(ones(256,256), collect(range(-20,20,length=256)) , 256,2,1)
# Plots.heatmap(V, c=:amp)

# begin
#     # Analysical vs finite difference
#     L = 256
#     limit=20
#     x=range(-limit, limit, length=L)
#     y=copy(x)
#     dx = x[2]-x[1]
#     dy = y[2]-y[1]

#     # constructing second derivative matrix
#     dia_len = sqrt(L^2^2*2)
# end


# (-∇²+V̂)ψ = εψ
# T̂ = -∇²

begin
    # di = (2*dx*dy) 
    # this constructs the enire second derivative operator 
    # T̂ = (spdiagm(0=>[4 for i in 1:L^2], 1=>[-1 for i in 1:(L^2-1)],
    #             -1=>[-1 for i in 1:(L^2-1)], L=>[-1 for i in 1:(L-1)^2],
    #             -L=>[-1 for i in 1:(L-1)^2]))/(2*dx*dy)


    # UnicodePlots.spy(T̂) # quick way to check the diagonals


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

function second_der_oper( L, 𝑑) #assuming square grid, i.e. dx = dy = 𝑑
    dx = 𝑑
    dy = 𝑑
    T̂ = (spdiagm(0=>[4 for i in 1:L^2], 1=>[-1 for i in 1:(L^2-1)],
                -1=>[-1 for i in 1:(L^2-1)], L=>[-1 for i in 1:(L-1)^2],
                -L=>[-1 for i in 1:(L-1)^2]))/(2*dx*dy)    

    return T̂
end

function potential_oper!(potential, emptyV̂::SparseMatrixCSC)
     # V is an Array{Any,2}, I don't know why {Any}
    # without conversion eigs spits arror about {Any}
    emptyV̂ = convert(SparseMatrixCSC{Float32,Int64}, spdiagm(0=>potential[:]))
    return emptyV̂
end


function solve1(V̂, T̂)   
    Ĥ = V̂ + T̂

    # TODO: 𝜓 is a waste of memory
    𝜆, 𝜓 = eigs(Ĥ, nev=1, which=:SM, ritzvec=false) # nev=1 cause we don't need others
    return 𝜆
end


# Testing solver on SHO
function test_solver_w_SHO()
    grid1 = ones(256,256)
    xy = collect(range(-20,20,length=256))
    L = 256
    num = 10
    limit = 20
    x⚥=range(-limit, limit, length=L)      #apparently 40/256 far enough away from actual Δ to cause major error
    T̂ = second_der_oper(L, x⚥[1]-x⚥[2])
    emptyV̂ = spzeros(L^2,L^2) #preallocation

    kx = rand(num)*0.16
    ky = rand(num)*0.16
    cx = (rand(num).-0.5).*16
    cy = (rand(num).-0.5).*16


    for i in 1:num
        potential = SHO(grid1, xy, L, kx[i],ky[i],cx = cx[i],cy = cy[i]) 
        𝜆 = solve1(potential_oper!(potential, emptyV̂), T̂)
        # println(𝜆[1]) 
        numerical = round(real(𝜆[1]), digits=8)
        analytical = round(0.5 * (sqrt(kx[i]) + sqrt(ky[i])), digits=8)
        error = round(100*abs(numerical-analytical)/analytical, digits=5)
        print("Numerical: $numerical,  Analysical: $analytical, Error: $error% \n")
    end 
end
# test_solver_w_SHO()