#!/usr/bin/env bash
while read SCRIPT
do
    echo "Checking for script $SCRIPT.sh"
    if [ -e $SCRIPT.sh ]
    then
        echo "Running $SCRIPT.sh"
        source ./$SCRIPT.sh $@ && echo "$SCRIPT.sh succeeded" || (echo "$SCRIPT.sh failed" && exit 1)
    fi
done < ../../node_tags

