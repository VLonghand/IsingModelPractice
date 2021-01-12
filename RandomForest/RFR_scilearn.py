import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt
import multiprocessing 
import concurrent.futures


# get and order data-----------------------------------------
dataset = pd.read_csv("Data/Energies_with_flat_exampels.csv")

energies = dataset['energies']
examples = dataset.iloc[:,1:16]

from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(examples, energies, test_size=0.2, random_state=0)
#------------------------------------------------------------

# train and evaluate-----------------------------------------
from sklearn.ensemble import RandomForestRegressor

error = []
estimators = []
eval_data = pd.DataFrame(columns=['# of trees', 'Error'])

def RFR_etimators(num_of_trees):
    model = RandomForestRegressor(n_estimators=num_of_trees, oob_score=True, random_state=0)
    model.fit(X_train, y_train)
    return [num_of_trees, model.oob_score_]

#------------------------------------------------------------



# train the model with different number of trees and evalueate effectiveness
eval_data1 = [[],[]]

with concurrent.futures.ProcessPoolExecutor() as executor:
    results = executor.map(RFR_etimators, range(20,1000,10))


    for p1 in results:
        #p1 = executor.submit(RFR_etimators, i)
        eval_data1[0].append(p1[0])
        eval_data1[1].append(p1[1])
#------------------------------------------------------------




# plot the data

plt.plot(eval_data1[0],eval_data1[1])
plt.xlabel('Number of trees')
plt.ylabel('oob score')
plt.show()

#---------------------------
#print(eval_data)