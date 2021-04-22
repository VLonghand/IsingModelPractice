using   Plots, Arpack, SparseArrays, UnicodePlots

# Simple harmonic oscilator to test slover 
function SHO(L, kx,ky,cx=0,cy=0)
    xy = range(-20,20,length=L)

    # Potential of SHO at x,y
    # function SHO_V(x,y)
    #     V = 0.5 * (kx*(x-cx)^2 + ky*(y-cy)^2)
    # end

    V = Matrix{Float32}(undef,L,L)
    for i in 1:L
        for j in 1:L
        V[j,i] = 0.5 * (kx*(xy[i]-cx)^2 + ky*(xy[j]-cy)^2)
        end
    end
    return V
end

V = SHO(L,2,1,0,0)
row_major_flatten(V)
# V[1,2] = 9
# Plots.heatmap(V, c=:amp)

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
# T̂ = Tridiagonal([-1 for i in 1:(L^2-1)],
#                 [4 for i in 1:L^2],
#                 [-1 for i in 1:(L^2-1)] ) 
# T̂ = convert(SparseMatrixCSC,T̂) #Tridiagonal without fringes


T̂ = spdiagm(0=>[4 for i in 1:L^2], 1=>[-1 for i in 1:(L^2-1)], -1=>[-1 for i in 1:(L^2-1)],
            (L^2-L)=>[-1 for i in 1:L], -(L^2-L)=>[-1 for i in 1:L])

# # to add fringes
# for i in 0:L
#     T̂[L^2-L+i, i+1] = -1 # super-diagonal
#     T̂[i+1, L^2-L+i] = -1 # sub-diagonal
# end
# T̂=Symmetric(T̂)

# UnicodePlots.spy(T̂) # quick way to check the diagonals

mop = [1:4 5:8 9:12 13:16]

function row_major_flatten(mop::Matrix)
    vesc=[]
    for rows in eachrow(mop)
        append!(vesc, rows)
    end
    return vesc
end


function solve1(potential)
    
    V = spdiagm(0=>row_major_flatten(potential))

    H = V + T̂
    𝜆, 𝜓 = eigs(H, nev=1, which=:SM)
    return 𝜆, 𝜓
end

# Testing solver on SHO
num = 10
kx = rand(num)*0.16
ky = rand(num)*0.16
cx = (rand(num).-0.5).*16
cy = (rand(num).-0.5).*16

for i in 1:num
    𝜆, 𝜓 = solve1(SHO(L, kx[i],ky[i],cy[i],cx[i]))
    real1 = real(𝜆[1])/10
    analytical = 0.5 * (sqrt(kx[i]) + sqrt(ky[i]))
    error = 100*abs(real1-analytical)/analytical
    print("Numerical: $real1,  Analysical: $analytical, Error: $error% \n")
end