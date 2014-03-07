##############################
Llista de millores/correccions
##############################

Millores i correccions a realitzar:

* comprovar si et trobes a un dels bordes d'una secció, de manera que
  no calgui trobar-se exàctament al títol de la secció per canviar el
  seu nivell.

    Títol secció
    ------------        < aquí el cursor

    Text de la secció

* opcions per anar a la secció anterior i a la següent

* opcions per etiquetar seccions.

  Exemple: pots indicar que ^Exercici és una "secció etiquetada". Si
  és el primer cop que apareix al document, no farà res. Si hi ha
  alguna altra aparició d'aquesta etiqueta, la funció copiarà el
  nivell de secció de l'anterior, incrementarà el nr. si n'hi ha (ex.
  ^Exercici 3. .*$ recolliria el 3 i li afegiria (o corregiria) el nr.
  de l'actual al 4. A més a més, corregiria la numeració de les
  etiquetes posteriors (en aquest cas només els ^Exercici que estiguin
  numerats i amb el nivell de secció esperat)
