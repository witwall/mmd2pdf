#include-once

Func getIni()
	Local $file, $handle, $line, $section = 0

	; check ini file
	$file = @ScriptDir & '\mmd2pdf.ini'
	If Not FileExists($file) = 1 Then
		ConsoleWrite("No mmd2pdf.ini preferences file found" & @CRLF)
		Return
	EndIf

	If $TEST Then ConsoleWrite("Ini file: " & $file & @CRLF)

	; open File
	$handle = FileOpen($file, 0)
	If $handle = -1 Then Return

	; Read in lines of text until the EOF is reached
	While 1
		$line = FileReadLine($handle)
		If @error = -1 Then ExitLoop
		If $line = "[MMD2PDF]" Then
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
			If StringInStr($line, "closepdfviewerwindowtitle") = 1 Then
				$CLOSE_PDFVIEWER_WINDOWTITLE = StringRegExpReplace($line, ".*=[ ]*", "")
				If $TEST Then ConsoleWrite("ClosePdfViewerWindowTitle:" & $CLOSE_PDFVIEWER_WINDOWTITLE & @CRLF)
			EndIf
			If StringRegExp($line, 'Test') = 1 And StringRegExp($line, '^[^;]*true') <> 0 Then $TEST = 1
			If StringRegExp($line, '(O|o)pen(D|d)ocument') = 1 And StringRegExp($line, '^[^;]*true') <> 1 Then $OPENDOC = 0
			If StringRegExp($line, '(A|a)uto(O|o)verwrite') = 1 And StringRegExp($line, '^[^;]*true') = 1 Then $AUTOOVERWRITE = 0
			If StringRegExp($line, '(A|a)uto(N|n)ew(L|l)ines') = 1 And StringRegExp($line, '^[^;]*true') <> 1 Then $NEWLINE = 0
			If StringRegExp($line, '(P|p)age(B|b)reak') = 1 Then
				$PAGEBREAK = StringRegExpReplace($line, ".*=[ ]*", "")
			EndIf
			If StringRegExp($line, '(O|o)utput') = 1 Then
				$OUTPUT = StringLower(StringRegExpReplace($line, ".*=[^\w]*(f|)", ""))
			EndIf
			If StringRegExp($line, '(O|o)ffice(E|e)xe') = 1 Then
				$OFFICE = StringRegExpReplace($line, ".*=[^\w]*", "")
			EndIf
		EndIf
		If $section = 2 Then
			;$MMDHEADER &= $line & "  " & @CRLF
		EndIf
		If $section = 3 Then
			$WKPARAMS &= $line & " "
		EndIf
	WEnd

	FileClose($handle)
EndFunc   ;==>getIni

Func getDef()
	Local $file, $handle, $line

	$file = $DIR & "\" & $DOCNAME & ".def"

	; check def file
	If Not FileExists($file) = 1 Then
		ConsoleWrite("No " & $DOCNAME & ".def definitions file found" & @CRLF)
		Return
	EndIf

	If $TEST Then ConsoleWrite("Def file: " & $file & @CRLF)

	; open File
	$handle = FileOpen($file, 0)
	If $handle = -1 Then Return

	; Read in lines of text if <key>:value or until the EOF is reached
	While 1
		$line = FileReadLine($handle)
		If @error = -1 Then ExitLoop

		If Not StringRegExp($line, '^[\w ]*:.*') Then ExitLoop

		If StringInStr($line, "style") = 1 Then
			If StringInStr($line, '.css') = 0 Then
				$STYLE = StringStripWS(StringMid($line, StringInStr($line, ":")+1),3)
				$CSS = "file:///" & @ScriptDir & "\styles\" & $style & ".css"
			Else
				$CSS = StringRegExpReplace($line, ".*:[ ]*", "")
			EndIf
			If $TEST Then ConsoleWrite("CSS:" & $CSS & @CRLF)
		EndIf
		If StringInStr($line, "pagebreakattoplevel") = 1 Then
			$PAGEBREAKATTOPLEVEL = 1
			If StringInStr($line, "n", 0, 1, 20) <> 0 Then
				$PAGEBREAKATTOPLEVEL = 0
			EndIf
			If $TEST Then ConsoleWrite("PageBreakAtTopLevel:" & $PAGEBREAKATTOPLEVEL & @CRLF)
		EndIf
		If StringInStr($line, "title") = 1 Then
			$TITLE = StringStripWS(StringMid($line, StringInStr($line, ":")+1),3)
			If $TEST Then ConsoleWrite($line & @CRLF)
		EndIf
		If StringInStr($line, "header") = 1 Then
			$PDF_HEADER = 1
			If StringInStr($line, "n", 0, 1, 20) <> 0 Then
				$PDF_HEADER = 0
			EndIf
			If $TEST Then ConsoleWrite("Header:" & $PDF_HEADER & @CRLF)
		EndIf
		If StringInStr($line, "footer") = 1 Then
			$PDF_FOOTER = 1
			If StringInStr($line, "n", 0, 1, 20) <> 0 Then
				$PDF_FOOTER = 0
			EndIf
			If $TEST Then ConsoleWrite("Footer:" & $PDF_FOOTER & @CRLF)
		EndIf
		If StringInStr($line, "include") = 1 Then
			$INFILES &= Chr(34) & $DIR & "\" & StringStripWS(StringMid($line, StringInStr($line, ":")+1),3) & Chr(34) & " "
			; More than 1 file --> automatic outline
			$PDF_OUTLINE = 1
		EndIf
		If StringInStr($line, "title") > 0 Then
			;$TITLE = StringRegExpReplace($line, ".*=[^\w]*", "")
		EndIf
		If StringInStr($line, "copyright") > 0 Then
			;$TITLE = StringRegExpReplace($line, ".*=[^\w]*", "")
		EndIf
	WEnd

	; continue - assume the rest to be top of the MMD Document
	$MMDHEADER &= @CRLF
	While 1
		$line = FileReadLine($handle)
		If @error = -1 Then ExitLoop

		$MMDHEADER &= $line
	WEnd

	FileClose($handle)
EndFunc   ;==>getDef

Func getStyle()
	Local $file, $handle, $line

	If StringLen($STYLE) > 0 Then
		$file = @ScriptDir & "\styles\" & $STYLE & ".sty"

		; check style file
		If Not FileExists($file) = 1 Then
			If $TEST Then
				ConsoleWrite("No " & $STYLE & ".sty definitions file found" & @CRLF)
			EndIf
			Return
		EndIf

		If $TEST Then ConsoleWrite("Style file: " & $file & @CRLF)

		; open File
		$handle = FileOpen($file, 0)
		If $handle = -1 Then Return

		; Read in lines of text until the EOF is reached
		While 1
			$line = FileReadLine($handle)
			If @error = -1 Then ExitLoop

			If StringInStr($line, "--") = 1 Then
				If $PDF_HEADER And StringInStr($line, "--header") = 1 Then
					$line = StringReplace($line, "[headertitle]", $TITLE)
					$WKPARAMS &= " " & $line
					If $TEST Then ConsoleWrite("wkhtmltopdf parameter:" & $line & @CRLF)
				ElseIf $PDF_FOOTER And StringInStr($line, "--footer") = 1 Then
					$WKPARAMS &= " " & $line
					If $TEST Then ConsoleWrite("wkhtmltopdf parameter:" & $line & @CRLF)
				ElseIf StringInStr($line, "--orientation") = 1 Then
					$WKPARAMS &= " " & $line
				ElseIf StringInStr($line, "--page") = 1 Then
					$WKPARAMS &= " " & $line
				EndIf
			EndIf
		WEnd

		If $TEST Then ConsoleWrite("wkhtmltopdf parameters: " & $WKPARAMS & @CRLF)

		FileClose($handle)
	EndIf
EndFunc   ;==>getStyle
