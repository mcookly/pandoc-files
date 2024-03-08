#!/bin/bash

# Args:
# 1.  Input file
# 2.  Output file (no extension)
# 3.  Bibliography

echo "Beginning conversion to DOCX …"
echo "=============================="

pandoc -i $1 -o $2.docx \
  --bibliography $3 \
  --csl Resources/Styles/SBL2_full_note.csl \
  --reference-doc Resources/Templates/SBL2.docx \
  --lua-filter Resources/Filters/SBL2.lua \

echo "=============================="
echo "Finished conversion to DOCX …"
