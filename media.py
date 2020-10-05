nalto = float(input('Inserisci il numero più alto'))
nbasso = float(input('Inserisci il numero più basso'))
result = f'({round((nbasso+nalto)/2,2)}±{round((nalto-nbasso)/2,2)})s'
print(result)
import clipboard
clipboard.copy(result)
