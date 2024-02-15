#!/bin/bash

# Args:
# 1.  Input file
# 2.  Output file
# 3.  Bibliography

echo "Beginning conversion to ODT …"
echo "============================="

pandoc -i $1 -o $2 \
  --bibliography $3 \
  --reference-doc Resources/Templates/SBL2.odt \
  --lua-filter Resources/Filters/SBL2.lua

echo "============================="
echo "Finished conversion to ODT …"