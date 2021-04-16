using   Plots
# Simple harmonic oscilator to test slover 

function SHO(kx,ky,cx=0,cy=0)
    xy = -20:0.01:20

    # Potential of SHO at x,y
    function SHO_V(x,y)
        V = 0.5 * (kx*(x-cx)^2 + ky*(y-cy)^2)
    end

    heatmap(xy,xy, SHO_V, c=:amp)
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

function slove(potential)

    V = sparse([L^2:L^2])
end