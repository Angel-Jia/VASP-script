#!/bin/bash
echo ""
if [ -e output ]
then
  result=`tail -20 output |grep "reached required accuracy"`
  if [ "$result" != "" ]
  then
    echo "YES"
    echo ""
  else
    echo "NO"
    echo ""
  fi
elif [ "$1" != "" ]
then
  for i in $@
  do
    for j in `find $i -name output |sort`
    do
      echo "$j"
      result=`tail -20 $j |grep "reached required accuracy"`
      if [ "$result" != "" ]
      then
        echo "YES"
        echo ""
      else
        echo "NO"
        echo ""
      fi
    done
  done
else
  for i in `find ./ -name output| sort`
  do
    echo "$i"
    result=`tail -20 $i |grep "reached required accuracy"`
    if [ "$result" != "" ]
    then
      echo "YES"
      echo ""
    else
      echo "NO"
      echo ""
    fi
  done
fi

