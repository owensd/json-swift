#!/bin/bash

ScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TestHarness=$ScriptDir/../.build/debug/ParserTestHarness
TestCollateral=$ScriptDir/../TestCollateral

SuccessCount=0
FailureCount=0

for f in $TestCollateral/JSONTestSuite/test_parsing/y_*.json; do
    $TestHarness $f
    if [ $? -eq 0 ]; then
        SuccessCount=$(expr $SuccessCount + 1)
    else
        FailureCount=$(expr $FailureCount + 1)
    fi
done

for f in $TestCollateral/JSONTestSuite/test_parsing/n_*.json; do
    $TestHarness $f
    if [ $? -eq 0 ]; then
        SuccessCount=$(expr $SuccessCount + 1)
    else
        if [ $? -eq 139 ]; then
            echo "!!!!! Crash while testing: $f"
        fi
        FailureCount=$(expr $FailureCount + 1)
    fi
done

Total=$(expr $SuccessCount + $FailureCount)
echo "Results: $SuccessCount/$Total tests passed"

if [ $Total -eq $SuccessCount ]; then
    exit 0
else
    exit -1
fi