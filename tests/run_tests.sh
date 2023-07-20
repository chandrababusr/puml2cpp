#! /bin/bash

parser=../puml2cpp
test_dir=./pumls

files=$(ls $test_dir/*.wsd)

for file in ${files}
do
    echo "-------------------- Start: ${parser} ${file} --------------------"
    cat ${file}
    echo
    echo "-------------------- End: ${parser} ${file} ----------------------"
    ${parser} $file
    echo
done
