#!/bin/bash
function getCountry(){
  row=`cat kraje | head -$1 |tail -1 `
  echo $row
}
