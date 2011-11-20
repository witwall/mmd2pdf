#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=mmd2pdf.ico
#AutoIt3Wrapper_Outfile=..\mmd2pdf\mmd2pdf.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=multimarkdown, wkhtml2pdf
#AutoIt3Wrapper_Res_Description=MultiMarkDown to PDF Converter
#AutoIt3Wrapper_Res_Fileversion=0.2.0.1
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Au3Check_Parameters=-d
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt("TrayMenuMode", 1) ; Default tray menu items (Script Paused/Exit) will not be shown.

Global Const $APPTITLE = "MMD2PDF"
Global $TEST = 0
Global $MMDEXE = @ScriptDir & '\mmd\multimarkdown.exe'
Global $HTML2PDFEXE = @ScriptDir & '\wkhtmltopdf\wkhtmltopdf.exe'
Global $DIR = @ScriptDir
Global $DOCNAME = ""
Global $INFILES = ""
Global $PDFFILE = ""
Global $WKPARAMS = "--print-media-type --margin-top 5mm --margin-bottom 5mm --margin-right 5mm --margin-left 5mm --encoding A4 --page-size A4 --orientation Portrait --disable-external-links"
Global $OPENDOC = 1 ; Default: Open Document
Global $AUTOOVERWRITE = 1 ; Default: Ask to overwrite
Global $NEWLINE = 0 ; Default: No AutoNewLine
Global $MMDHEADER = "";
Global $PAGEBREAK = "[PAGEBREAK]";
Global $OUTPUT = "pdf";
Global $CSS = "templates/default.css";
Global $OFFICE = "";

#include <file.au3>
#include "..\lib\MMDLib.au3"
#include "..\lib\Setup.au3"
#include "..\lib\Manual.au3"

Dim $path, $fullPath, $i, $aPath, $pages = 0, $tempFiles

Setup()
Manual()

$path = ""
If $cmdline[0] > 0 Then
	For $i = 1 To $cmdline[0]
		$fullPath = $cmdline[$i]
		If Not StringInStr($fullPath, "\") Then $fullPath = @WorkingDir & "\" & $fullPath
		If Not FileExists($fullPath) Then
			MsgBox(0x1010, $APPTITLE, "File not found:" & @CRLF & @CRLF & $fullPath)
			Exit
		EndIf
		; get path array
		$aPath = StringRegExp($fullPath, '(.*)[\/\\]([^\/\\]+)\.(\w+)$', 1) ; 0=Path, 1=Filename without ext
		;MsgBox(0, "Path part", $fullPath & @LF & $aPath[0] & @LF & $aPath[1])
		$DIR = $aPath[0]
		$DOCNAME = $aPath[1]
		$INFILES &= Chr(34) & $DIR & "\" & $DOCNAME & "." & $aPath[2] & Chr(34) & " "
		If $i = 1 Then
			$PDFFILE = $DIR & "\" & $DOCNAME & ".pdf"
		EndIf
	Next
Else
	ConsoleWrite($APPTITLE & " multimarkdownfile.txt [textfile2.txt ...]")
	Exit
EndIf

If $TEST Then ConsoleWrite("File(s): " & $INFILES)

getIni()

If $TEST Then ConsoleWrite("Output to: " & $OUTPUT & @CRLF)

; check output file
If $AUTOOVERWRITE And FileExists($PDFFILE) = 1 Then
	If MsgBox(0x1031, $APPTITLE, $PDFFILE & " already exists! Overwrite?") <> 1 Then
		Exit
	EndIf
EndIf

$tempFiles = ReadFiles($INFILES)

If $TEST Then ConsoleWrite("Temp file(s): " & $tempFiles & @CRLF)
; add include http:// to tempfiles

HTML2PDF($tempFiles, $PDFFILE)

If $OPENDOC Then
	If FileExists($PDFFILE) Then
		; Open a .pdf file with it's default editor
		ShellExecute($PDFFILE, "", $DIR)
	EndIf
EndIf

Exit