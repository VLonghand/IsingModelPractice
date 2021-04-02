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
![](NN_avg_error.png)

#### Results

Tested on all available data

![](NN_yvspredy.png)

![](NN_error_hist.png)
The tail to the left can be explained by random training data distribution, propably because 32 was included as an example and -32 wasn't

![](NN_avg_error.png)
The same explanation follows for avg error


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

##CNN

Trained on Flat energy distribution distribution of data

![](CNN_train_dat_hits.png)

the results are much worse

!


Finally, NN on random vs NN on random vs CNN on random vs CNN on flat
