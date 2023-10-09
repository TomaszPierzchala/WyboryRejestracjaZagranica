# Wybory 2023
Główny skrypt `pickup_data.sh` czyta dane z https://ewybory.msz.gov.pl/zmien-miejsce-glosowania
i produkuje dwa piki wyników - można stąd łatwo pobrać:
```
wyniki.out
```
zawierający historię zapisów:
```
data, suma, ilość krajów, ilość obwodów
czw 5 paź 14:00:41 2023 CEST,350709,92,410
czw 5 paź 14:30:48 2023 CEST,351277,92,410
...
```
oraz `zestawienie.out` zawierający ostatnie/najnowsze, rozłożenie zapisów segregując po krajach:
```
pon 9 paź 10:30:45 2023 CEST: 476164
Wielka Brytania +122385 122385 25,7%
Niemcy +84582 206967 43,5%
Stany Zjednoczone Ameryki +36949 243916 51,2%
Holandia +28517 272433 57,2%
...
```
