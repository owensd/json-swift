swiftc -emit-library -module-name JSONLib -Xfrontend -debug-time-function-bodies ../Sources/JSONLib/* 2> timings.txt
cat timings.txt | sort -nr | head -n 20 > problems.txt
rm libJSONLib.dylib 
cat problems.txt
