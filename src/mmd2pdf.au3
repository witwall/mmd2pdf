#NoTrayIcon
#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=mmd2pdf.ico
#AutoIt3Wrapper_Outfile=..\mmd2pdf.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=multimarkdown, wkhtml2pdf
#AutoIt3Wrapper_Res_Description=MultiMarkDown to PDF Converter
#AutoIt3Wrapper_Res_Fileversion=0.7.0.2
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_AU3Check_Parameters=-d
#AutoIt3Wrapper_Run_Tidy=y
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt("TrayMenuMode", 1) ; Default tray menu items (Script Paused/Exit) will not be shown.
Opt("WinTitleMatchMode", 2) ; Match Substring of Window Title

Global Const $APPTITLE = "MMD2PDF"
Global $DEBUG = 0
Global $MMDEXE = @ScriptDir & '\mmd\multimarkdown.exe'
Global $HTML2PDFEXE = @ScriptDir & '\wkhtmltopdf\wkhtmltopdf.exe'
Global $SUMATRAEXE = @ScriptDir & '\sumatrapdf\SumatraPDF.exe'
Global $DIR = @ScriptDir
Global $DOCNAME = ""
Global $INFILES = ""
Global $PDFFILE = ""
Global $WKPARAMS = "--print-media-type --dpi 300 --margin-top 5mm --margin-bottom 5mm --margin-right 5mm --margin-left 5mm --page-size A4 --disable-smart-shrinking"
Global $PDF_HEADER = 0
Global $PDF_FOOTER = 0
Global $PDF_TOC = 0
Global $PDF_OUTLINE = 0
Global $CLOSE_PDFVIEWER_WINDOWTITLE = "Adobe Reader"
Global $OPENDOC = 2 ; 1: Open Document, 2: Open with SumatraPDF (Default)
Global $AUTOOVERWRITE = 0 ; Default: Ask to overwrite
Global $NEWLINE = 1 ; Default: AutoNewLine
Global $TITLE = ""
Global $MMDHEADER = ""
Global $PAGEBREAK = "[PAGEBREAK]"
Global $PAGEBREAKATTOPLEVEL = 0 ; Default: No pagebreak at top level
Global $OUTPUT = "pdf"
Global $STYLE = ""
Global $CSS = "file:///" & @ScriptDir & "\styles\default.css"
Global $OFFICE = ""

#include <file.au3>
#include "parse.au3"
#include "config.au3"

Dim $path, $fullPath, $i, $aPath, $pages = 0, $tempFiles, $document, $var, $fileList

ConsoleWrite($APPTITLE & " V" & FileGetVersion(@ScriptDir & "\" & @ScriptName, "FileVersion") & @CRLF)

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
		$document = $aPath[1]
		; Set Main Document
		If StringLen($DOCNAME) = 0 Then $DOCNAME = $document
		$INFILES &= Chr(34) & $DIR & "\" & $document & "." & $aPath[2] & Chr(34) & " "
		; More than 1 file --> automatic outline
		If $i > 1 Then $PDF_OUTLINE = 1
	Next
Else
	$var = FileOpenDialog("Select one or more (Multi)Markdown documents to convert to pdf", $DIR, "Text (*.txt)|Markdown (*.md;*.mmd)", 1 + 4)
	If Not @error Then
		$fileList = StringSplit($var, "|")
		If $fileList[0] > 1 Then
			$DIR = $fileList[1]
			For $i = 2 To $fileList[0]
				;MsgBox(0x1010, $APPTITLE, $fileList[$i])
				If StringLen($DOCNAME) = 0 Then $DOCNAME = StringLeft($fileList[$i], StringInStr($fileList[$i], ".", 0, -1))
				$INFILES &= Chr(34) & $fileList[$i] & Chr(34) & " "
			Next
			; More than 1 file --> automatic outline
			If $i > 1 Then $PDF_OUTLINE = 1
		Else
			;MsgBox(0x1010, $APPTITLE, $fileList[1])
			; get path array
			$aPath = StringRegExp($fileList[1], '(.*)[\/\\]([^\/\\]+)\.(\w+)$', 1) ; 0=Path, 1=Filename without ext
			$DIR = $aPath[0]
			$document = $aPath[1]
			; Set Main Document
			$DOCNAME = $document
			$INFILES &= Chr(34) & $DIR & "\" & $document & "." & $aPath[2] & Chr(34) & " "
		EndIf
	Else
		ConsoleWrite("usage: " & @ScriptName & " multimarkdownfile.txt [textfile2.txt ...]")
		Exit
	EndIf
EndIf

$PDFFILE = $DIR & "\" & $DOCNAME & ".pdf"
$TITLE = $DOCNAME

getIni()
getDef()
getStyle()

If $DEBUG Then
	ConsoleWrite("File(s): " & $INFILES)
	ConsoleWrite("Output to: " & $OUTPUT & @CRLF)
EndIf

$tempFiles = ReadFiles($INFILES)

; check output file
If FileExists($PDFFILE) = 1 Then
	If Not $AUTOOVERWRITE Then
		If MsgBox(0x1031, $APPTITLE, $PDFFILE & " already exists! Overwrite?") <> 1 Then
			Exit
		EndIf
	EndIf
	If $OPENDOC And StringLen($CLOSE_PDFVIEWER_WINDOWTITLE) > 0 Then
		; Close Viewer
		WinClose($CLOSE_PDFVIEWER_WINDOWTITLE)
	EndIf
EndIf

If $DEBUG Then ConsoleWrite("Temp file(s): " & $tempFiles & @CRLF)
; add include http:// to tempfiles

HTML2PDF($tempFiles, $PDFFILE)

$OPENDOC = 2
If $OPENDOC > 0 Then
	If FileExists($PDFFILE) Then
		If $OPENDOC = 1 Then
			; Close Viewer
			WinClose($CLOSE_PDFVIEWER_WINDOWTITLE)

			; Open a .pdf file with it's default editor
			ShellExecute($PDFFILE, "", $DIR)
		Else
			If Not WinExists($DOCNAME & ".pdf") Then
				Run($SUMATRAEXE & " """ & $PDFFILE & """", $DIR)
			EndIf
			WinActivate($DOCNAME & ".pdf")
		EndIf
	EndIf
EndIf

Exit
