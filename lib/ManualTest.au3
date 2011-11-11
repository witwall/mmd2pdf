Global Const $APPTITLE = "ManualTest"
Global $DOCNAME = "MMD2PDF Manual"
Global $MMDEXE = @ScriptDir & "\mmd\multimarkdown.exe"
Global $HTML2PDFEXE = @ScriptDir & "\wkhtmltopdf\wkhtmltopdf.exe"
Global $DIR = @ScriptDir
Global $WKPARAMS = "--print-media-type --margin-top 5mm --margin-bottom 5mm --margin-right 5mm --margin-left 5mm --encoding A4 --page-size A4 --orientation Portrait --disable-external-links"
Global $AUTOOVERWRITE = 1 ; Default: Ask to overwrite
Global $NEWLINE = 1 ; AutoNewLine
Global $MMDHEADER = "";
Global $PAGEBREAK = "[PAGEBREAK]";
Global $OUTPUT = "pdf";
Global $CSS = "templates/default.css";
Global $OFFICE = "";

#include "MMDLib.au3"
#include "manual.au3"

Manual()
