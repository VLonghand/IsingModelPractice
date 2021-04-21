using   Plots, LinearAlgebra, SparseArrays, UnicodePlots
# Simple harmonic oscilator to test slover 

function SHO(kx,ky,cx=0,cy=0)
    xy = -20:0.01:20

    # Potential of SHO at x,y
    function SHO_V(x,y)
        V = 0.5 * (kx*(x-cx)^2 + ky*(y-cy)^2)
    end

    Plots.heatmap(xy,xy, SHO_V, c=:amp)
end

SHO(2,1,0,0)

# Analysical vs finite difference
L = 256
limit=20
x=range(-limit, limit, length=L)
y=similar(x)
dx = x[2]-x[1]
dy = y[2]-y[1]

# constructing second derivative matrix
dia_len = sqrt(L^2^2*2)



# (-∇²+V̂)ψ = εψ
# T̂ = -∇²
T̂ = Tridiagonal([-1 for i in 1:(L^2-1)],
                [4 for i in 1:L^2],
                [-1 for i in 1:(L^2-1)] ) 
T̂ = convert(SparseMatrixCSC,T̂)
for i in 0:L
    T̂[L^2-i,L^2+i-L] = -1
    T̂[L^2+i-L,L^2-i] = -1
end
# T̂ = convert(Tridiagonal, T̂)

UnicodePlots.spy(T̂[L^2-L,:])

# println(T̂[L^2-100,:,:,:])


function slove(potential)

    V = sparse([L^2:L^2])
end