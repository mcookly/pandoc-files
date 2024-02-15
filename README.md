# Pandoc files

Things I use with [Pandoc](https://pandoc.org/).
Most of these are for academic aims.


## Dependencies

Template-specific dependencies are mentioned later.

- [Pandoc](https://pandoc.org/)


## How to use

Convenient scripts can be found in `Scripts`.  Most of these take at least two arguments: input and output.  **You must specify the filetype of the input only.**  For example,

```=bash
./Scripts/SBL-pdf.sh manuscript.md paper
```
Some scripts will require more arguments.  Check the source file!

## Templates

All conversions take Markdown as the file format of their input.

### SBL 2

#### Dependencies

- [LibreOffice](https://www.libreoffice.org/)
- Times New Roman

#### Filetypes

##### ODT

```=bash
./Scripts/SBL-odt.sh <input.md> <output> <bibliography file>
```

##### PDF

```=bash
./Scripts/SBL-pdf.sh <input.md> <output> <bibliography file>
```