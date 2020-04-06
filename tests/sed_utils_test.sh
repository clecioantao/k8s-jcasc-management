#!/bin/bash

######### test sed script errors
testSedUtilsWithoutFirstArgument() {
    expected=$(. ../scripts/sed_utils.sh && replaceStringInFile "" "second" "myfile" > /dev/null)

    assertEquals "sed validation" "1" "$?"
}

testSedUtilsWithoutSecondArgument() {
    expected=$(. ../scripts/sed_utils.sh && replaceStringInFile "first" "" "myfile" > /dev/null)

    assertEquals "sed validation" "1" "$?"
}

testSedUtilsWithoutThirdArgument() {
    expected=$(. ../scripts/sed_utils.sh && replaceStringInFile "first" "second" "" > /dev/null)

    assertEquals "sed validation" "1" "$?"
}

. shunit2