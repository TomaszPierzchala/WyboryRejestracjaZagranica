#!/bin/sh

./pickup_data.sh no_progress >> wyniki.out
#python3 plot.py
sleep 5
#git add wyniki.out zestawienie.out wyniki.png zmiana.out
git add wyniki.out zestawienie.out
git commit -m "results update"; git push
