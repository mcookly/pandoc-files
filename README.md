# Max's pandoc files

Files for various pandoc outputs.

**Clone repo to** `$HOME/pandoc-files`

## Available templates
- [x] MLA 9
- [ ] APA 7
- [ ] Chicago
- [ ] Mail letter

## Conversion instructions
### `.md`  &rarr;  `.docx`
```
pandoc <input>.md \
--defaults $HOME/pandoc-files/defaultsmla9.yaml \
--reference-doc $HOME/pandoc-files/templates mla9.docx \
-o <output>.docx
```
Note: Change the header of the `mla9.docx` for correct last name if you don't want to make any adjustments post-conversion.


### `.md` &rarr; `.pdf`
#### MLA 9
1. Convert to `.docx`
2. Convert `.docx` to `.pdf` using LibreOffice, Microsoft Word, or a command line tool.
