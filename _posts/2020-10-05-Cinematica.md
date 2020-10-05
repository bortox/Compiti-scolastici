---
layout:  post
title:  "Inizio del percorso LSS riguardante il moto. "
date: 2020-10-04 20:30:00
categories:  compiti
materia: fisica
description: "Diario di Bordo sul Laboratorio del Sapere Scientifico riguardante Acidi e Basi. Resoconto della seconda lezione, in cui proviamo a far solubilizzare carbonato di calcio in acqua, acido cloridrico e aceto. Successivamente osserviamo la solubilizzazione di metalli in polvere in una soluzione contenente acido cloridrico."
---
<sub> Non avevo carta millimetrata, quindi ho fatto al computer. </sub><br>
<sub> Non mi è riuscito inserire le barre di errore nel primo grafico, poiché se le inserivo le varie tracce dei quattro moti si dividevano in più grafici.  </sub>
<sub> Ho usato il modulo matplotlib  per python, ma è molto macchinoso da utilizzare e il design non è molto bello. Punto a migrare verso Plotly. </sub>

# Fisica, Cinematica

##### Le medie delle camminate e delle corse fatte dai miei compagni sotto il portico, misurate da 3 cronometri diversi. Sono tutti dei moti regolari.

![Grafico di camminata regolare]({{ "/data/img/fisica/lss/moto/graficida1a4.png" | absolute_url }})

Arancione : moto 1
blu: moto 2
rosso: moto 3
verde: moto 4

## Tabelle di Macina convertite


### 1) Camminata regolare


| N° Pilone | Cronometro 1 | Cronometro 2 | Cronometro 3 | Tempo Medio |
|---|:---:|:---:|:---:|:---:|
0|0|0|0|0s
1|5.44|5.30|5.56|(5.43±0.13)s
2|11.03|11.21|11.25|(11,63±0.11)s
3|16.63|16.64|16.65|(16.64±0.01)s
4|21.83|22.34|21.82|(22.09±0.26)s
5|27.80|27.35|27.28|(27.54±0.26)s

![Grafico di camminata regolare]({{ "/data/img/fisica/lss/moto/grafico1.png" | absolute_url }})


### 2) Corsa lenta

| N° Pilone | Cronometro 1 | Cronometro 2 | Cronometro 3 | Tempo Medio |
|---|:---:|:---:|:---:|:---:|
0|0|0|0|0s
1|2.89|3.08|2.75|(2.92±0.17)s
2|5.90|5.48|5.82|(5.69±0.21)s
3|8.90|8.91|8.99|(8.95±0.04)s
4|11.92|11.34|11.99|(11.66±0.33)s
5|14.50|14.40|14.63|(14.52±0.12)s

![Grafico di corsa lenta]({{ "/data/img/fisica/lss/moto/grafico2.png" | absolute_url }})

### 3) Corsa veloce

| N° Pilone | Cronometro 1 | Cronometro 2 | Cronometro 3 | Tempo Medio |
|---|:---:|:---:|:---:|:---:|
0|0|0|0|0s
1|1.31|1.24|1.90|(1.6±0.29)s
2|2.45|2.30|2.05|(2.25±0.20)s
3|3.49|3.54|3.53|(3.52±0.02)s
4|4.23|4.46|4.57|(4.4±0.17)s
5|5.58|5.64|5.56|(5.6±0.04)s

![Grafico di corsa veloce]({{ "/data/img/fisica/lss/moto/grafico3.png" | absolute_url }})


### 4)  Camminata dal pilone 2

| N° Pilone | Cronometro 1 | Cronometro 2 | Cronometro 3 | Tempo Medio |
|---|:---:|:---:|:---:|:---:|
0|0|0|0|0s
3|5.90|5.95|5.92|(5.94±0.02)s
4|11.40|11.40|12.42|(11.91±0.51)s
5|17.19|17.43|17.28|(17.31±0.12)s

[^1]: Not an Error, non è un errore, non ci sono dati.

![Grafico di camminata regolare dal pilone 2]({{ "/data/img/fisica/lss/moto/grafico4.png" | absolute_url }})


### 5)  Camminata irregolare

| N° Pilone | Cronometro 1 | Cronometro 2 | Cronometro 3 | Tempo Medio |
|---|:---:|:---:|:---:|:---:|
0|0|0|0|0s
1|3.21|3.58|3.94|(3.58±0.36)s
2|7.45|7.33|6.70|(7.08±0.38)s
3|11.04|11.10|11.07|(11.07±0.03)s
4|13.68|14.90|14.61|(14.29±0.61)s
5|18.65|18.91|18.92|(18.79±0.14)s

### 6) Camminata irregolare con fermata

| N° Pilone | Cronometro 1 | Cronometro 2 | Cronometro 3 | Tempo Medio |
|---|:---:|:---:|:---:|:---:|
0|0|0|0|0s
1|4.39|5.72|4.47|(5.05±0.67)s
2|13.05|13.92|13.67|(13.48±0.43)s
3|18.31|18.90|18.87|(18.6±0.29)s
4|21.03|21.22|21.72|(21.38±0.34)s
5|30.29|30.21|30.27|(30.25±0.04)s

### 7) Camminata irregolare andata e ritorno

| N° Pilone | Cronometro 1 | Cronometro 2 | Cronometro 3 | Tempo Medio |
|---|:---:|:---:|:---:|:---:|
0|0|0|0|0s
1 ( andata )|5.70|5.76|5.72|(5.73±0.03)s
2 ( andata )|10.64|10.50|10.44|(10.54±0.10)s
3 ( andata )|15.70|15.74|15.76|(15.73±0.03)s
5 ( ritorno )|26.51|26.66|26.88|(26.70±0.18)s
3 ( ritorno )|38.62|38.49|38.43|(38.52±0.09)s
2 ( ritorno )|36.34|36.25|34.36|(35.35±0.99)s
1 ( ritorno )|49.68|49.80|49.95|(49.81±0.14)s

## Risposte alle domande

> Quante e quali informazioni contiene ciascun punto del grafico?

Ciascun punto del grafico contiene tre informazioni: l'incertezza - attraverso le barre di errore - , la media del numero di secondi passati, sull' asse y, e il numero del pilone su cui è stata effettuata la misurazione. Siccome i piloni sono equidistanti, potremmo chiamare l' asse x l' asse della distanza.

>  Che tipo di andamento hai ottenuto per i moti da 1 a 3? Che cosa puoi dire confrontando i grafici 1), 2), 3) tra loro?

Per i moti da uno a tre ho ottenuto un andamento lineare, direttamente proporzionale alla velocità della camminata. Anche i grafici sono direttamente proporzionali, e sono regolari, poiché tracciando una linea, con un' incertezza, tutti i valori possono essere pressoché compresi in essa.

