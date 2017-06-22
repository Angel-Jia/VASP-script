#!/bin/bash
for i in 0 1 2 3
do
  echo "ln$i:"
  ssh ln$i-gn0 "uptime"
done

read -p "chose one node: " node
ssh ln$node-gn0
