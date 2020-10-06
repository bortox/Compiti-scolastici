# Lo so, questo codice fa schifo al cazzo.

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
plt.rc('xtick', labelsize=20) 
plt.rc('ytick', labelsize=20)
plt.rcParams.update({'font.size': 30})

dfull = pd.read_html(r'/home/borto/Notable - Export (6EBA)/Cinematica.html')
for i in range(4):
    df = dfull[i]
    df['minimo'] = df[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(min, axis=1).round(decimals=2)
    df['massimo'] = df[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(max,axis=1).round(decimals=2)
    df['incertezza'] = ((df['massimo'] - df['minimo'])/2).round(decimals=2)
    df['media'] = df['minimo'] + df['incertezza'].round(decimals=2)
    print(df.to_string())
    fig = plt.figure(figsize=(21,9))
    ax = fig.gca()
    ax.set_title(f'Moto numero {i+1}')
    ax.set_yticks([1,2,3,4,5])
    ax.set_ylabel('Numero del pilone')
    ax.set_xlabel('Misurazione in secondi')
    ax.set_xticks(np.arange(0,50,0.75))
    plt.errorbar(df['media'], df['N° Pilone'], xerr=df['incertezza'], yerr=0,marker = 'o',mfc='black',mec='darkblue',ms=7, linewidth=3, solid_capstyle='round', ecolor='red')
    plt.grid()
    plt.savefig(f'grafico{i+1}', dpi=600, transparent=True)
print('Finito!')
#plt.show()
