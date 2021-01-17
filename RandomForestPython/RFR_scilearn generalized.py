from numpy.lib.function_base import average
import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import concurrent.futures
from pandas.core.frame import DataFrame




# get and order data-----------------------------------------
FileName = "Energy w 30000 rand_flat 4 x 4.csv"

dataset = pd.read_csv("Data/%s" % FileName)

N = int(dataset.shape[0])
n = int(np.sqrt(dataset.shape[1]-1))

energies = dataset['energies']
examples = dataset.iloc[:,1:n*n]


# train and evaluate-----------------------------------------
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from sklearn.metrics import f1_score

# Data Frame: odd rows are test y's follows by predicted y's with rows collumn numbers
y_target_predicted = pd.DataFrame()

def RFR_etimators(num_of_trees_training_size):
    num_of_trees = num_of_trees_training_size[0]
    # training_size = num_of_trees_training_size[1]
    training_size = 5000
    testing_size = 1000
    X_train, X_test, y_train, y_test = train_test_split(examples, energies,train_size=training_size, test_size=testing_size)
    model = RandomForestClassifier(n_estimators=num_of_trees, oob_score=True)
    model.fit(X_train, y_train)
    # y_target_predicted.append(y_test)
    # y_target_predicted.append(model.predict(X_test))

    # y_test_lst = y_test.values.tolist()
    # y_new_lst = model.predict(X_test)
    OBBscore = model.obb_score_
    # data_to_save = {"y_test_lst": y_test_lst,
    #                 "y_new_lst": y_new_lst}
    # df_to_save = pd.DataFrame(data_to_save,
    #                           columns=[f"OOBscore={OOBscore}", f"lens={len(y_new_lst)}",
    #                                  "y_test_lst","y_new_lst"])
    # df_to_save.to_csv("RandomForestPython/training_related_data/for_more_test.csv", mode='a')
    # del data_to_save
    # del df_to_save

#     f1_score(y_test, model.predict(X_test), average = 'macro' )

    return [num_of_trees, training_size, OBBscore ]




    
#------------------------------------------------------------

#### Multiprossesing 
# train the model with different number of trees and evalueate effectiveness
eval_data = ([[],[],[]])
args = []
for i in np.linspace(100,200,50):   # number of trees n*n is min
    for j in np.linspace(100,8000,100):    # number of training examples 
        args.append((i,j))
args = [(int(i[0]),int(i[1])) for i in args]

with concurrent.futures.ProcessPoolExecutor() as executor:
    results = executor.map(RFR_etimators, args)


    for p1 in results:
        eval_data[0].append(p1[0]) # number of trees
        eval_data[1].append(p1[1]) # training size
        eval_data[2].append(p1[2]) # evaluation OBB score, f1 score
#------------------------------------------------------------

plt.plot(eval_data[0],eval_data[1])
plt.title = f"{FileName}"
plt.xlabel = "Number of trees"
plt.ylabel = "f1 score"
plt.show()


# Plan
# export data as csv from multiple runs and plot it later

#y_target_predicted.to_csv("RandomForestPython/training_related_data/after training %s" % FileName) 




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
