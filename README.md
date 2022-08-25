# Max's pandoc files

Files for various pandoc outputs.

**Clone repo to** `$HOME/pandoc-files`

## MD  &rarr;  DOCX

Requires `defaults/mla9.yaml` and `templates/mla9.docx` in current directory

Run using: ```pandoc <input>.md \

--defaults $HOME/pandoc-files/defaultsmla9.yaml --reference-doc \

$HOME/pandoc-files/templates mla9.docx \

-o <output>.docx```

**Note: Change the last name in the header of the `mla9.docx`  for correct last name.**
