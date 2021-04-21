using Plots


function SHO(kx=1, ky=1, cx=0, cy=0)
    kx=1
    ky=1
    cx=0
    cy=0
    xy = -20:0.1:20
    # Simple harmonic oscilator
    function SHO_V(x,y)
        # x = -20:0.1:20 
        
        # y = -20:0.1:20
        V = 0.5.*(kx.*(x.-cx).^2 .+ ky.*(y.-cy).^2)
        return V
    end
    heatmap!(xy, xy, SHO_V, c=:reds)
end
SHO()