# Lo so, questo codice fa schifo al cazzo.

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
plt.rc('xtick', labelsize=20) 
plt.rc('ytick', labelsize=20)
plt.rcParams.update({'font.size': 30})

dfull = pd.read_html(r'/home/borto/Notable - Export (6EBA)/Cinematica.html')
for i in range(6):
    df = dfull[i]
    df['minimo'] = df[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(min, axis=1).round(decimals=2)
    df['massimo'] = df[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(max,axis=1).round(decimals=2)
    df['incertezza'] = ((df['massimo'] - df['minimo'])/2).round(decimals=2)
    df['media'] = df['minimo'] + df['incertezza'].round(decimals=2)
    print(df.to_string())
print('Finito!')
#plt.show()
