MMD2PDF, a command line utility, converts MultiMarkDown text files to PDF documents, adding a few extra's like options to include webpages and support for page-breaks. It is a portable utility, it will leave no traces in registry or on your file system.

All executables and the manual are included in the download.

## Usage ##
Syntax:
```
MMD2PDF.exe InputFile1.txt InputFile2.txt ... 
```

**MMD2PDF** can easily be used in a text editor.
For example in Notepad++, create this Execute command:
```
`$(NPP_DIRECTORY)\MMD2PDF\MMD2PDF.exe "$(FULL_CURRENT_PATH)"`
```

## Markdown ##
[MultiMarkDown](http://fletcherpenney.net/multimarkdown) is a superset of the [Markdown](http://daringfireball.net/projects/markdown) syntax, originally created by John Gruber. It adds multiple syntax features (tables, footnotes, and citations, to name a few). Additionally, it builds in “smart” typography for various languages (proper left- and right-sided quotes, for example).


## Acknowledgements ##
MMD2PDF would not exist without these great software projects:
  * http://fletcherpenney.net/multimarkdown
  * http://code.google.com/p/wkhtmltopdf
  * http://www.autoitscript.com
  * http://blog.kowalczyk.info/software/sumatrapdf/free-pdf-reader.html
  * http://jasonm23.github.com/markdown-css-themes