# Lo so, questo codice fa schifo al cazzo.

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
dfull = pd.read_html(r'/home/borto/Notable - Export (6EBA)/Cinematica.html')
for i in range(4):
    df = dfull[i]
    df['minimo'] = df[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(min, axis=1).round(decimals=2)
    df['massimo'] = df[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(max,axis=1).round(decimals=2)
    df['incertezza'] = ((df['massimo'] - df['minimo'])/2).round(decimals=2)
    df['media'] = df['minimo'] + df['incertezza'].round(decimals=2)
    print(df.to_string())
    fig = plt.figure()
    ax = fig.gca()
    ax.set_title(f'Moto numero {i+1}')
    ax.set_xticks([1,2,3,4,5])
    ax.set_xlabel('Numero del pilone')
    ax.set_ylabel('Misurazione in secondi')
    ax.set_yticks(np.arange(0,50,0.5))
    plt.errorbar( df['N° Pilone'],df['media'], yerr=df['incertezza'], xerr=0,marker = 'o',mfc='red',mec='orange',ms=7, linewidth=3, solid_capstyle='round')
    plt.savefig(f'grafico{i+1}')
plt.grid()
plt.show()
