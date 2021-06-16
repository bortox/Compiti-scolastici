TESTER = document.getElementById('moto5');
Plotly.newPlot( TESTER, [{
x: [0,3.21,7.45,11.04,13.68,18.65],
y: [0,1,2,3,4,5],
error_x: {
    type: 'data',
    array: [0,0.36,0.38,0.03,0.61,0.14],
    visible: true,
    
    }
}], 
{
title: 'Moto numero 5<br> Camminata irregolare',
yaxis: {
    title: ' Numero del pilone ( posizione )'
},
xaxis: {
    title: ' Secondi passati ( tempo )'
},
plot_bgcolor: 'rgba(0,0,0,0)',
paper_bgcolor: 'rgba(0,0,0,0)',
    } );
TESTER2 = document.getElementById('moto7');
Plotly.newPlot( TESTER2, [{
x: [0,5.73,10.54,15.73,26.70,38.52,35.35,48.81],
y: [0,1,2,3,5,3,2,1],
error_x: {
    type: 'data',
    array: [0,0.03,0.10,0.03,0.18,0.09,0.99,0.14],
    visible: true,
    
    }
}], 
{
title: 'Moto numero 7<br> Corsa irregolare<br>Andata e ritorno',
yaxis: {
    title: ' Numero del pilone ( posizione )'
},
xaxis: {
    title: ' Secondi passati ( tempo )'
},
plot_bgcolor: 'rgba(0,0,0,0)',
paper_bgcolor: 'rgba(0,0,0,0)',
    } );
    TESTER1 = document.getElementById('moto6');
Plotly.newPlot( TESTER1, [{
x: [0,5.05,13.48,18.6,21.38,30.25],
y: [0,1,2,3,4,5],
error_x: {
    type: 'data',
    array: [0,0.67,0.43,0.29,0.34,0.04],
    visible: true,
    
    }
}], 
{
title: 'Moto numero 6<br> Corsa irregolare',
yaxis: {
    title: ' Numero del pilone ( posizione )'
},
xaxis: {
    title: ' Secondi passati ( tempo )'
},
plot_bgcolor: 'rgba(0,0,0,0)',
paper_bgcolor: 'rgba(0,0,0,0)',
    } );
