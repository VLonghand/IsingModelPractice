import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import concurrent.futures




# get and order data-----------------------------------------
FileName = "Energy w 10000 rand_flat 8 x 8.csv"

dataset = pd.read_csv("Data/%s" % FileName)

N = int(dataset.shape[0])
n = int(np.sqrt(dataset.shape[1]-1))

energies = dataset['energies']
examples = dataset.iloc[:,1:n*n]


# train and evaluate-----------------------------------------
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score


# Data Frame: odd rows are test y's follows by predicted y's with rows collumn numbers
y_target_predicted = pd.DataFrame()

def RFR_etimators(num_of_trees_training_size):
    num_of_trees = num_of_trees_training_size[0]
    # training_size = num_of_trees_training_size[1]
    training_size = 7000
    testing_size = N - training_size
    X_train, X_test, y_train, y_test = train_test_split(examples, energies,train_size=training_size, test_size=testing_size)
    model = RandomForestClassifier(n_estimators=num_of_trees, oob_score=True)
    model.fit(X_train, y_train)
    y_target_predicted.append(y_test)
    y_target_predicted.append(model.predict(X_test))


    return [num_of_trees, model.oob_score_]

    
#------------------------------------------------------------

#### Multiprossesing 
# train the model with different number of trees and evalueate effectiveness
eval_data = ([[],[],[]])
args = []
for i in np.linspace(40,500,10):   # number of trees n*n is min
    for j in np.linspace(100,8000,100):    # number of training examples 
        args.append((i,j))
args = [(int(i[0]),int(i[1])) for i in args]

with concurrent.futures.ProcessPoolExecutor() as executor:
    results = executor.map(RFR_etimators, args)


    # for p1 in results:
    #     eval_data[0].append(p1[0]) # number of trees
    #     eval_data[1].append(p1[1]) # training size
    #     eval_data[2].append(p1[2]) # OBB score
#------------------------------------------------------------




# Plan
# export data as csv from multiple runs and plot it later

y_target_predicted.to_csv("RandomForestPython/training_related_data/after training %s" % FileName) 




# # plot the data----------------------------------------------
# from mpl_toolkits import mplot3d
# ax = plt.axes(projection="3d")
# I = 10
# J = 100
# x, y, z = np.reshape(eval_data[0], (I,J)), np.reshape(eval_data[1], (I,J)), np.reshape(eval_data[2], (I,J))

# # more resolution, and better colours 
# ax.plot_surface(x,y,z)

# ax.set_xlabel('Number of trees')
# ax.set_ylabel('training size')
# ax.set_zlabel('oob score')
# plt.show()
# #------------------------------------------------------------
