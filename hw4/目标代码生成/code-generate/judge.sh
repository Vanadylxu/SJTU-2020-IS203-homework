#!/bin/bash
cd test
for filename in *.seal; do
    echo "--------Test using" $filename "--------"
    name=${filename//.seal}
    ../cgen $filename -o $name.s
    gcc $name.s -o $name
    ./$name > tempfile
    ../test-answer/$name > tempfile2
    diff tempfile tempfile2 > /dev/null
    if [ $? -eq 0 ] ; then
        echo passed
    else
        echo NOT passed
    fi
    rm -f $name
done

rm -f tempfile tempfile2
cd ..