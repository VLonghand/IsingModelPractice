## Neural networks in julia

Simple neural net

There is a thing for nets in LaTeX

NN set up

```juila
Dense(16,32,relu),
    Dense(32, 64, relu),
    Dense(64, 150),
    Dense(150,30),
    Dense(30, 1),
```

Trained of ~16000 randomly sellected exaples
for 20 epochs on the same set
![](NN_train_dat_hist.png)

#### Results

Tested on all available data

![](NN_yvspredy.png)

![](NN_error_hist.png)


![](NN_avg_error.png)
The greater error at 32 is explained by 32 not being included into the training set due to random selection

Noteworthy peculiarity 
when running
```julia
    model = build_model() |> gpu
    @epochs 20 Flux.train!(loss, ps, data, opt )
```
and gpu isn't set up
cpu runns very fast i.e. 

![](speedy_cpu.png)

This doesn't happen when running a CNN even though the code is virtually the same
![](regular_cpu.png)




# CNN

```julia
    Conv((2,2),1=>5,relu),
    Conv((2,2), 5=>3,pad=(1,1), relu),
    Conv((2,2), 3=>3,pad=(1,1), relu),
    Conv((2,2), 3=>5,relu),
    Conv((2,2), 5=>3,pad=(1,1), relu),
    Conv((2,2), 3=>3,pad=(1,1), relu),
    Conv((2,2), 3=>5,relu),
    Flux.flatten,
    Dense(125, 1),
```

Trained on Flat energy distribution distribution of data

![](CNN_train_dat_hits.png)

the results are much worse

![](CNN_yvspredy.png)

There is clearly less error on the boundareis where there were a lot of examples 32 and -32

![](CNN_avg_error.png)



Finally, NN on random vs NN on random vs CNN on random vs CNN on flat
