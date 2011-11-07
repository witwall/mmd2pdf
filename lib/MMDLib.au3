#include-once
#include "Encode.au3"

Func TXT2HTML($inTXT)
	Local $in, $out, $dia, $line, $Header, $tempTXT, $tempHTML, $tempDIA, $page = 0, $image = 0
	; open File
	$in = FileOpen($inTXT, 0)

	If $in = -1 Then
		MsgBox(0, $APPTITLE, "Error opening " & $inTXT)
		Exit
	EndIf

	$tempTXT = @TempDir & "\MMDWin\Temp" & $page & ".txt"
	$tempHTML = @TempDir & "\MMDWin\Temp" & $page & ".html"

	$out = FileOpen($tempTXT, 2 + 8 + 256) ;Write New, Create Dir, UTF-8 (No BOM)

	If $out = -1 Then
		MsgBox(0, $APPTITLE, "Error opening " & $tempTXT)
		Exit
	EndIf

	; Read first line
	$line = FileReadLine($in)
	If @error = -1 Then
		MsgBox(0, $APPTITLE, "Error reading " & $inTXT)
		Exit
	EndIf

	; Write the Base Header - This is needed to include Images in the document directory
	; Path must end with "\"
	$Header = 'HTML Header: <base href="' & $DIR & "\" & '" />  ' & @CRLF
	;FileWriteLine($out, 'HTML Header: <base href="' & $DIR & "\" & '" />  ')

	; Write CSS, overruled by CSS in MMD definition
	$Header &= 'CSS: ' & $CSS & @CRLF
	;FileWriteLine($out, 'CSS: ' & $CSS)

	; MMD Header in file?
	If StringRegExp($line, '\w*:.*') <> 1 Then
		If StringRegExp($MMDHEADER, 'Title:') <> 1 Then
			$Header &= "Title: " & StringUpper(StringLeft($DOCNAME, 1)) & StringMid($DOCNAME, 2) & "  " & @CRLF
			;FileWriteLine($out, "Title: " & StringUpper(StringLeft($DOCNAME, 1)) & StringMid($DOCNAME, 2) & "  ")
		EndIf
		$Header &= $MMDHEADER & @CRLF
		;FileWriteLine($out, $MMDHEADER)
	EndIf

	FileWrite($out, $Header)
	FileWriteLine($out, $line & "  ")

	; Read in lines of text until the EOF is reached
	While 1
		$line = FileReadLine($in)
		If @error = -1 Then ExitLoop

		If StringLen($PAGEBREAK) > 0 And StringLeft($line, StringLen($PAGEBREAK)) = $PAGEBREAK Then
			$page += 1
			If $page > 0 Then
				FileClose($out)

				MMD($tempTXT, $tempHTML)

				$tempTXT = @TempDir & "\MMDWin\Temp" & $page & ".txt"
				$tempHTML = @TempDir & "\MMDWin\Temp" & $page & ".html"

				$out = FileOpen($tempTXT, 2 + 8 + 256) ;Write New, Create Dir, UTF-8 (No BOM)
				If $out = -1 Then
					MsgBox(0, $APPTITLE, "Error opening " & $tempTXT)
					Exit
				EndIf
				FileWrite($out, $Header)
			EndIf
			; Next line, don't print this
			ContinueLoop
		EndIf

		If $line = "[ditaa]" Then
			$image += 1
			$tempDIA = @TempDir & "\MMDWin\image" & $image

			$dia = FileOpen($tempDIA & ".txt", 2 + 8 + 256) ;Write New, Create Dir, UTF-8 (No BOM)
			If $dia = -1 Then
				MsgBox(0, $APPTITLE, "Error opening " & $tempDIA & ".txt")
				Exit
			EndIf

			While 1
				$line = FileReadLine($in)
				If @error = -1 Then ExitLoop
				If $line = "[!ditaa]" Then ExitLoop
				FileWriteLine($dia, $line)
			WEnd

			FileClose($dia)

			DITAA($tempDIA & ".txt", $tempDIA & ".png")

			FileWriteLine($out, "![Image" & $image & "](file:///" & $tempDIA & ".png)")

			; Next line, don't print closing tag
			ContinueLoop
		EndIf

		If $OUTPUT = "pdf" Then
			$line = Encode($line)
		EndIf
		If $NEWLINE Then $line &= "  " ; break - end line with 2 spaces
		FileWriteLine($out, $line)
	WEnd

	FileClose($in)
	FileClose($out)

	MMD($tempTXT, $tempHTML)

	Return $page
EndFunc   ;==>TXT2HTML

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; NEW ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func ReadFiles($files)
	Local $Text, $i, $in, $fileList

	$fileList = StringSplit($files, """ """, 1)
	For $i = 1 To $fileList[0]
		; open File
		$in = FileOpen(StringReplace($fileList[$i],"""","", 0))

		If $in = -1 Then
			ConsoleWriteError("Error opening " & $fileList[$i])
			Exit
		EndIf

		; Read text
		$Text &= FileRead($in)

		If $i < $fileList[0] Then
			$Text &= $PAGEBREAK & @CRLF
		EndIf

		FileClose($in)
	Next

	ConsoleWrite($Text)

	Return Text2HTML($Text)
EndFunc

Func Text2HTML($inTXT)
	Local $out, $dia, $line, $Header, $tempTXT, $tempHTML, $tempDIA, $fileList, $page = 0, $image = 0

	; Split text on $PAGEBREAK
	$pageList = StringSplit($inTXT, $PAGEBREAK & @CRLF, 1)
ConsoleWrite($pageList[0])
	For $page = 1 To $pageList[0]

		$tempTXT = @TempDir & "\MMDWin\Temp" & $page & ".txt"
		$tempHTML = @TempDir & "\MMDWin\Temp" & $page & ".html"
        ; Don't use full path (CSS)
		$fileList &= "Temp" & $page & ".html "

		$out = FileOpen($tempTXT, 2 + 8 + 256) ;Write New, Create Dir, UTF-8 (No BOM)

		If $out = -1 Then
			MsgBox(0, $APPTITLE, "Error opening " & $tempTXT)
			Exit
		EndIf

		; Write the Base Header - This is needed to include Images in the document directory
		; Path must end with "\"
		$Header = 'HTML Header: <base href="' & $DIR & "\" & '" />  ' & @CRLF
		;FileWriteLine($out, 'HTML Header: <base href="' & $DIR & "\" & '" />  ')

		; Write CSS, overruled by CSS in MMD definition
		$Header &= 'CSS: ' & $CSS & @CRLF
		;FileWriteLine($out, 'CSS: ' & $CSS)

		; MMD Header in text?
		If StringRegExp($pageList[$page], '^\w*:.*') <> 1 Then
			If StringRegExp($MMDHEADER, 'Title:') <> 1 Then
				$Header &= "Title: " & StringUpper(StringLeft($DOCNAME, 1)) & StringMid($DOCNAME, 2) & "  " & @CRLF
				;FileWriteLine($out, "Title: " & StringUpper(StringLeft($DOCNAME, 1)) & StringMid($DOCNAME, 2) & "  ")
			EndIf
			$Header &= $MMDHEADER & @CRLF
			;FileWriteLine($out, $MMDHEADER)
		EndIf

		FileWriteLine($out, $Header)
		FileWriteLine($out, "")

		; Read in lines of text until the end is reached
		$linePos = 1
		While 1
			$linePosEnd = StringInStr($pageList[$page], @CRLF, 2, 1, $linePos) - 1
			If $linePosEnd < 0 Then $linePosEnd = StringLen($pageList[$page])
			$line = StringMid($pageList[$page], $linePos, $linePosEnd - $linePos + 1)

			;ConsoleWrite($linePos & "-" & $line & @CRLF)

			If $OUTPUT = "pdf" Then
				$line = Encode($line)
			EndIf

			If $NEWLINE Then $line &= "  " ; break - end line with 2 spaces
			FileWriteLine($out, $line)

			If Not StringInStr($pageList[$page], @CRLF, 2, 1, $linePos) Then
				ExitLoop
			Else
				$linePos = $linePosEnd + 3
			EndIf
		WEnd

		FileClose($out)

		MMD($tempTXT, $tempHTML)
	Next

    ; Don't use full path (CSS)
	Return StringStripWS($fileList, 2)
EndFunc   ;==>TXT2HTML

Func MMD($inMMD, $outHTML)
	Local $odtFile, $params = ""

	; multimarkdown -t latex -b test1.txt test2.txt

	; Batch mode: overrides output (-o), all to same dir!
	;$params &= "-b "
	If StringRight($outHTML, 5) = ".html" Then
		$params &= "-o " & '"' & $outHTML & '"'
	Else
		; odt
		$odtFile = $DIR & "\" & $DOCNAME & ".fodt"
		$params &= " -t odf "
		$params &= "-o " & '"' & $odtFile & '"'
	EndIf
	$params &= ' "' & $inMMD & '"'

	;MsgBox(0x1010, $APPTITLE, "MMD Params:" & @CRLF & @CRLF & $params)
	ShellExecuteWait($MMDEXE, $params, "", "Open", @SW_HIDE)
EndFunc   ;==>MMD

Func DITAA($inTXT, $inImage)
	Local $JAVAEXE, $params = ""

	;java -jar ditaa.jar <inpfile> [outfile] [-A] [-d] [-E] [-e <ENCODING>] [-h] [--help] [-o] [-r] [-s <SCALE>] [-S] [-t <TABS>][-v]

	;Find JRE
	If FileExists(@ProgramFilesDir & "\Java") Then
		$JAVAEXE = @ProgramFilesDir & "\Java\jre6\bin\java.exe"
		If FileExists($JAVAEXE) Then
			FileChangeDir(@ScriptDir & "\ditaa")
			$params = "-jar ditaa0_9.jar"
			$params &= ' "' & $inTXT
			$params &= '" "'
			$params &= $inImage & '"'
			;MsgBox(0x1010, $APPTITLE, "DITAA Params:" & @CRLF & @CRLF & $params)
			ShellExecuteWait($JAVAEXE, $params, @ScriptDir & "\ditaa", "Open", @SW_HIDE)
		EndIf
	EndIf
EndFunc   ;==>DITAA

Func HTML2PDF($inHTMLs, $outPDF)
	; wkhtmltopdf --print-media-type --margin-top 4mm --margin-bottom 4mm --margin-right 0mm --margin-left 0mm --encoding A4 --page-size A4 --orientation Portrait --redirect-delay 100 test1.html test.pdf

	; TO USE CSS don't use full path for HTML Files!
	$WKPARAMS &= " " & $inHTMLs & " "
	$WKPARAMS &= '"' & $outPDF & '"'

	;MsgBox(0x1010, $APPTITLE, "WK Params:" & @CRLF & @CRLF & $WKPARAMS & @CRLF & @CRLF & $DIR)
	;Set working directory to HTML File for included files!
	FileChangeDir(@TempDir & "\MMDWin")

	; Debug: RunWait(@ComSpec & " /k " & '"' & $HTML2PDFEXE & '" ' & $WKPARAMS, $DIR)
	ShellExecuteWait($HTML2PDFEXE, $WKPARAMS, @TempDir & "\MMDWin", "Open", @SW_HIDE)
EndFunc   ;==>HTML2PDF

Func getIni()
	Local $iniFile, $ini, $line, $section = 0

	$iniFile = $DIR & '\mmdwin.ini'

	; check ini file
	If Not FileExists($iniFile) = 1 Then $iniFile = @ScriptDir & '\mmdwin.ini'
	If Not FileExists($iniFile) = 1 Then Return

	; open File
	$ini = FileOpen($iniFile, 0)
	If $ini = -1 Then Return

	; Read in lines of text until the EOF is reached
	While 1
		$line = FileReadLine($ini)
		If @error = -1 Then ExitLoop
		If $line = "[MMDWin]" Then
			$section = 1
			ContinueLoop
		EndIf
		If $line = "[MultiMarkDown]" Then
			$section = 2
			ContinueLoop
		EndIf
		If $line = "[wkhtmltopdf]" Then
			$section = 3
			$WKPARAMS = ""
			ContinueLoop
		EndIf
		If $section = 1 Then
			If StringRegExp($line, '(O|o)pen(D|d)ocument') = 1 And StringRegExp($line, '^[^;]*true') <> 1 Then $OPENDOC = 0
			If StringRegExp($line, '(A|a)uto(O|o)verwrite') = 1 And StringRegExp($line, '^[^;]*true') = 1 Then $AUTOOVERWRITE = 0
			If StringRegExp($line, '(A|a)uto(N|n)ew(L|l)ines') = 1 And StringRegExp($line, '^[^;]*true') = 1 Then $NEWLINE = 1
			If StringRegExp($line, '(P|p)age(B|b)reak') = 1 Then
				$PAGEBREAK = StringRegExpReplace($line, ".*=[ ]*", "")
			EndIf
			If StringRegExp($line, '(O|o)utput') = 1 Then
				$OUTPUT = StringLower(StringRegExpReplace($line, ".*=[^\w]*(f|)", ""))
			EndIf
			If StringRegExp($line, '(T|t)emplate') = 1 Then
				$CSS = "file:///" & @ScriptDir & "\templates\" & StringRegExpReplace($line, ".*=[^\w]*", "") & ".css"
			EndIf
			If StringRegExp($line, '(O|o)ffice(E|e)xe') = 1 Then
				$OFFICE = StringRegExpReplace($line, ".*=[^\w]*", "")
			EndIf
		EndIf
		If $section = 2 Then
			$MMDHEADER &= $line & "  " & @CRLF
		EndIf
		If $section = 3 Then
			$WKPARAMS &= $line & " "
		EndIf
	WEnd

	FileClose($ini)
EndFunc   ;==>getIni
