#!/bin/bash
function getCountry(){
  kraj=`cat kraje | grep $1 | head -1 | sed  -r "s/[0-9]+[ ]+//g"`
  echo $kraj
}
