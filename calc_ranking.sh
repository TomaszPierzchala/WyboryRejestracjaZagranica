#!/bin/bash

function zestawienie(){
suma=$1

cat > zestawienie.out <<< `date`": $suma"
sum=0
while IFS= read -r linia
do
  # Podziel linię na części, używając spacji jako separatora
  # Wynik zostanie umieszczony w tablicy
  IFS=',' read -ra czesci <<< "$linia"

  # Możesz teraz odwoływać się do poszczególnych części za pomocą indeksów
  kraj="${czesci[0]}"
  ilosc="${czesci[1]// /}"
  sum=$((sum + ilosc))
  procent=$(awk "BEGIN {printf \"%.1f\", ($sum / $suma) * 100}")
 echo $kraj '+'$ilosc $sum $procent'%' >> zestawienie.out
done < ranking.sorted
}
