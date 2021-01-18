import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import concurrent.futures
plt.style.use('dark_background')

# shared variables
n = 4
N = 10000

# get and order data-----------------------------------------

dataset = pd.read_csv("Data/Energy w 15000 rand_flat 4 x 4.csv")

energies = dataset['energies']
examples = dataset.iloc[:,1:n*n]

from sklearn.model_selection import train_test_split
#------------------------------------------------------------


# train and evaluate-----------------------------------------
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score


def RFR_etimators(num_of_trees_training_size):
    # num_of_trees = num_of_trees_training_size[0]
    num_of_trees = 300
    training_size = num_of_trees_training_size[1]
    testing_size = N - training_size
    X_train, X_test, y_train, y_test = train_test_split(examples, energies,train_size=training_size, test_size=testing_size)
    model = RandomForestClassifier(n_estimators=num_of_trees, oob_score=True)
    model.fit(X_train, y_train)
    return [num_of_trees, training_size, model.oob_score_]

#------------------------------------------------------------


# train the model with different number of trees and evalueate effectiveness
eval_data = ([[],[],[]])
args = []
for i in np.linspace(40,500,10):   # number of trees n*n is min
    for j in np.linspace(100,8000,100):    # number of training examples 
        args.append((i,j))
args = [(int(i[0]),int(i[1])) for i in args]

with concurrent.futures.ProcessPoolExecutor() as executor:
    results = executor.map(RFR_etimators, args)


    for p1 in results:
        eval_data[0].append(p1[0]) # number of trees
        eval_data[1].append(p1[1]) # training size
        eval_data[2].append(p1[2]) # OBB score
#------------------------------------------------------------



# plot the data----------------------------------------------
from mpl_toolkits import mplot3d
ax = plt.axes(projection="3d")
I = 10
J = 100
x, y, z = np.reshape(eval_data[0], (I,J)), np.reshape(eval_data[1], (I,J)), np.reshape(eval_data[2], (I,J))

# more resolution, and better colours 
ax.plot_surface(x,y,z)

ax.set_xlabel('Number of trees')
ax.set_ylabel('training size')
ax.set_zlabel('oob score')
plt.show()
#------------------------------------------------------------
