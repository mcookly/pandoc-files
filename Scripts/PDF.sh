#!/bin/bash

# Args:
# 1.  Input file
# 2.  Output file (no extension)
# 3.  Bibliography

echo "Beginning conversion to PDF …"
echo "============================="

./Scripts/ODT.sh $1 $2 $3

soffice --convert-to pdf $2.odt

echo "============================="
echo "Finished conversion to PDF …"