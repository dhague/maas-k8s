#/bin/bash
while read SCRIPT
do
    if [ -e $SCRIPT.sh ]
    then
        ./$SCRIPT.sh $@
    fi
done < ../../node_tags

