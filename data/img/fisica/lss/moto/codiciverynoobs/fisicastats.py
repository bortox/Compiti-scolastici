import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
dfull = pd.read_html(r'/home/borto/Notable - Export (6EBA)/Cinematica.html')

df = dfull[1]
df['minimo'] = df[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(min, axis=1).round(decimals=2)
df['massimo'] = df[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(max,axis=1).round(decimals=2)
df['incertezza'] = ((df['massimo'] - df['minimo'])/2).round(decimals=2)
df['media'] = df['minimo'] + df['incertezza'].round(decimals=2)
df1 = dfull[2]
df1['minimo'] = df1[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(min, axis=1).round(decimals=2)
df1['massimo'] = df1[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(max,axis=1).round(decimals=2)
df1['incertezza'] = ((df1['massimo'] - df1['minimo'])/2).round(decimals=2)
df1['media'] = df1['minimo'] + df1['incertezza'].round(decimals=2)
df2 = dfull[3]
df2['minimo'] = df2[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(min, axis=1).round(decimals=2)
df2['massimo'] = df2[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(max,axis=1).round(decimals=2)
df2['incertezza'] = ((df2['massimo'] - df2['minimo'])/2).round(decimals=2)
df2['media'] = df2['minimo'] + df2['incertezza'].round(decimals=2)
df0 = dfull[0]
df0['minimo'] = df0[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(min, axis=1).round(decimals=2)
df0['massimo'] = df0[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(max,axis=1).round(decimals=2)
df0['incertezza'] = ((df0['massimo'] - df0['minimo'])/2).round(decimals=2)
df0['media'] = df0['minimo'] + df0['incertezza'].round(decimals=2)
print(df.to_string())
fig,axs = plt.subplots(figsize=(11,4))
ax = fig.gca()
ax.set_yticks([1,2,3,4,5])
ax.set_ylabel('Numero del pilone')
ax.set_xlabel('Misurazione in secondi')
ax.set_xticks(np.arange(0,50,1))

plt.errorbar(df['media'], df['N° Pilone'], xerr=df['incertezza'], yerr=0,marker = 'o',mfc='black',mec='darkblue',ms=7, linewidth=3, solid_capstyle='round', ecolor='red')

plt.errorbar(df0['media'], df0['N° Pilone'], xerr=df0['incertezza'], yerr=0,marker = 'o',mfc='black',mec='darkblue',ms=7, linewidth=3, solid_capstyle='round', ecolor='red')

plt.errorbar(df2['media'], df2['N° Pilone'], xerr=df2['incertezza'], yerr=0,marker = 'o',mfc='black',mec='darkblue',ms=7, linewidth=3, solid_capstyle='round', ecolor='red')

plt.errorbar(df1['media'], df1['N° Pilone'], xerr=df1['incertezza'], yerr=0,marker = 'o',mfc='black',mec='darkblue',ms=7, linewidth=3, solid_capstyle='round', ecolor='red')
plt.grid()

plt.savefig(f'grafico moti da 1 a 4', dpi=600, transparent=True)

#plt.show()
    #plt.savefig(f'moto_fisica_{i+1}')
