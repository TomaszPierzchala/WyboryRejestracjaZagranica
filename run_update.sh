#!/bin/sh

cd /Users/tomek/git/WyboryRejestracjaZagranica/
./pickup_data.sh no_progress >> wyniki.out
python3 plot.py

#git add wyniki.out zestawienie.out; git commit -m "results update"; git push
