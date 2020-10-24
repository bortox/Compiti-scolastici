# Lo so, questo codice fa schifo al cazzo.

print('Script avviato')
import time
start0 = time.time()
import pandas as pd
end = time.time()
print(f'Pandas è stato importato in {round(end - start0,4)} secondi')
inc_pos = 0.01
# while True:
#     try:
#         inc_pos = float(input('Inserisci l\' incertezza della posizione -->').replace(',','.'))
#         print(f'Hai inserito {inc_pos}. Ok')
#         break
#     except:
#         print('Errore. Non hai inserito un numero valido.')
start = time.time()
dfull = pd.read_html(r'/home/borto/Notable - Export (6EBA)/Cinematica.html')
end = time.time()
print(f'Le tabelle sono state lette in {round(end - start,4)} secondi')
rangeo = 7
start = time.time()

for i in range(rangeo):
    df = dfull[i]
    df['minimo'] = df[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(min, axis=1).round(decimals=2)
    df['massimo'] = df[['Cronometro 1','Cronometro 2','Cronometro 3']].apply(max,axis=1).round(decimals=2)
    # se il valore di massimo è diverso da zero e l' incertezza è minore di incertezza_cronometro, allora impostala a incertezza_cronometro
    # nota incertezza_cronometro ancora da definire.
    df['incertezza_istante_di_tempo'] = ((df['massimo'] - df['minimo'])/2).round(decimals=2)
    df['valore_istante_di_tempo'] = (df['minimo'] + df['incertezza_istante_di_tempo']).round(decimals=2)
    df['Istante di Tempo'] = [f'({x}±{y})s' for x, y in zip (df['valore_istante_di_tempo'].round(decimals=2), df['incertezza_istante_di_tempo'].round(decimals=2))]
    df['valore_intervallo_di_tempo'] = df['valore_istante_di_tempo'].diff().fillna(0)
    df['incertezza_intervallo_di_tempo'] = df['incertezza_istante_di_tempo'].rolling(2).sum().fillna(0)
    df['Intervallo di Tempo'] = [f'({x}±{y})s' for x, y in zip (df['valore_intervallo_di_tempo'].round(decimals=2), df['incertezza_intervallo_di_tempo'].round(decimals=2))]
    df['incertezza_posizione'] = inc_pos
    df.loc[df['N° Pilone'] == 0, 'incertezza_posizione'] = 0
    df['valore_posizione']  = df['N° Pilone']
    df['Posizione'] = [f'({x}±{y})m' for x, y in zip (df['valore_posizione'].round(decimals=2), df['incertezza_posizione'].round(decimals=2))]
    df['valore_spostamento'] = df['valore_posizione'].diff().fillna(0)
    df['incertezza_spostamento'] = df['incertezza_posizione'].rolling(2).sum().fillna(0)
    df['Spostamento'] = [f'({x}±{y})m' for x, y in zip (df['valore_spostamento'].round(decimals=2), df['incertezza_spostamento'].round(decimals=2))]
    df['valore_velocità'] = df['valore_spostamento']/df['valore_intervallo_di_tempo'].fillna(0).round(decimals=3)
    df['errore_relativo_spostamento'] = df['incertezza_spostamento']/df['valore_spostamento']
    df['errore_relativo_intervallo_di_tempo'] = df['incertezza_intervallo_di_tempo']/df['valore_intervallo_di_tempo']
    df['errore_relativo_velocità'] = df['errore_relativo_intervallo_di_tempo'] + df['errore_relativo_spostamento']
    df['incertezza_velocità'] = (df['errore_relativo_velocità'] * df['valore_velocità']).round(decimals=3)
    df['Velocità'] = [f'({x}±{y})m/s' for x, y in zip (df['valore_velocità'].round(decimals=2), df['incertezza_velocità'].round(decimals=2))]
    
    df.to_csv(f'data{i}_long.csv', index=False)
    del df['N° Pilone']
    del df['Cronometro 1']
    del df['Cronometro 2']
    del df['Cronometro 3']
    del df['valore_posizione']
    del df['valore_spostamento']
    del df['incertezza_spostamento']
    del df['incertezza_posizione']
    del df['valore_istante_di_tempo']
    del df['incertezza_istante_di_tempo']
    del df['valore_velocità']
    del df['errore_relativo_spostamento']
    del df['errore_relativo_intervallo_di_tempo']
    del df['errore_relativo_velocità']
    del df['incertezza_velocità']
    del df['minimo']
    del df['massimo']
    del df['incertezza_intervallo_di_tempo']
    del df['valore_intervallo_di_tempo']
    del df['Tempo Medio']
    df.to_csv(f'data{i}_long.csv', index=False)
end = time.time()
print(f'{rangeo} tabelle processate in {round(end - start,4)} secondi, con una media di {round((end - start)/rangeo,4)} secondi per tabella.')
print(f'Tempo totale: {round(end - start0,4)} secondi')
#plt.show()
