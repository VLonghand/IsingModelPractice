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

![](NN_yvspredy.png)<br/>
<br/>


![](NN_error_hist.png)<br/>
<br/><br/>

![](NN_avg_error.png) <br/><br/>
The lopsided error at extrema is explained by 32 or -32 not being included into the training set due to random selection

Noteworthy peculiarity 
when running
```julia
    model = build_model() |> gpu
    @epochs 20 Flux.train!(loss, ps, data, opt )
```
and gpu isn't set up
cpu runns very fast i.e. 
<br/><br/>
![](speedy_cpu.png)<br/>

This doesn't happen when running a CNN<br/>
even though the code is virtually the same<br/><br/>
![](regular_cpu.png)<br/>


<br/><br/>


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

### Trained on **Flat** energy distribution distribution of data

for 20 epochs

![](CNN-rand_train_dat_hits.png)

When evaluated over all data

the results are much worse

![](CNN-rand_yvspredy.png)

There is clearly less error on the boundareis where there were a lot of examples 32 and -32

![](CNN-rand_avg_error.png)
&nbsp;

&nbsp;

### Then repeated over **Random** data distribution 




Finally, NN on random vs NN on random vs CNN on random vs CNN on flat
