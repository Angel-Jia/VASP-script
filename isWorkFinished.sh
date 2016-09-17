#!/bin/bash
echo ""
if [ -e output ]
then
  result=`grep "reached required accuracy" output`
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
      result=`grep "reached required accuracy" $j`
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
    result=`grep "reached required accuracy" $i`
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

