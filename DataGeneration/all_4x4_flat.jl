# generates all possible 4x4 exmaple and exports as a CSV
using CSV
using DataFrames

v = ones(1,16)
n = 4

arr = DataFrame(ones(1,16))

    # while size(arr)[1] < 655#36
    #     local A = rand(-1:2:1, (1,16))
    #     if size(findall(x -> x == A, arr))[1] == 0
    #         push!(arr, A)
    #     end
    # end

for i1=[-1,1], i2=[-1,1], i3=[-1,1], i4=[-1,1], i5=[-1,1] ,i6=[-1,1] ,i7=[-1,1], i8=[-1,1],i9=[-1,1],i10=[-1,1],i11=[-1,1],i12=[-1,1],i13=[-1,1],i14=[-1,1],i15=[-1,1],i16=[-1,1]
    local L = [i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16]
    push!(arr, L)
end
delete!(arr, 1)

arr |> CSV.write("Data/All_4x4_flat.csv")


# function mark1(v, q)
#     if q < 16
#         push!(df, v)
#         mark1(v,q+1)

#         v[q] *= -1

#         push!(df, v)
#         mark1(v,q+1)
#     end
# end

# mark1(v,1)
print(size(arr))
findall(nonunique(arr))