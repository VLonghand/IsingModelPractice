using Distributed
using SharedArrays
using ProgressMeter
using Interpolations

function func1()
    n = 2000000
    arr = SharedArray{Float64}(n)
    @sync @distributed for i = 1:n
        arr[i] = i^2
    end
    res = sum(arr)
    return res
end

function print_nprocs()
    return nworkers()
end

addprocs(2)

print_nprocs()

func1()
