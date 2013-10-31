#include-once

Func getIni()
	Local $file, $handle, $line, $item

	; check ini file
	$file = @ScriptDir & '\mmd2pdf.prf'
	If Not FileExists($file) = 1 Then
		ConsoleWrite("No mmd2pdf.prf preferences file" & @CRLF)
		Return
	EndIf

	If $DEBUG Then ConsoleWrite("Prf file: " & $file & @CRLF)

	; open File
	$handle = FileOpen($file, 0)
	If $handle = -1 Then Return

	; Read in lines of text until the EOF is reached
	While 1
		$line = FileReadLine($handle)
		If @error = -1 Then ExitLoop

		If StringInStr($line, "debug") = 1 Then
			$DEBUG = 1
			If StringInStr($line, "n", 0, 1, 5) <> 0 Then
				$DEBUG = 0
			EndIf
			If $DEBUG Then ConsoleWrite("Debug: " & $DEBUG & @CRLF)
		EndIf
		If StringInStr($line, "closepdfviewerwindowtitle") = 1 Then
			$CLOSE_PDFVIEWER_WINDOWTITLE = StringRegExpReplace($line, ".*=[ ]*", "")
			If $DEBUG Then ConsoleWrite("ClosePdfViewerWindowTitle: " & $CLOSE_PDFVIEWER_WINDOWTITLE & @CRLF)
		EndIf
		If StringInStr($line, "opendocument") = 1 Then
			$OPENDOC = 1
			If StringInStr($line, "n", 0, 1, 12) <> 0 Then
				$OPENDOC = 0
			EndIf
			If $DEBUG Then ConsoleWrite("OpenDocument: " & $OPENDOC & @CRLF)
		EndIf
		If StringInStr($line, "autooverwrite") = 1 Then
			$AUTOOVERWRITE = 1
			If StringInStr($line, "n", 0, 1, 13) <> 0 Then
				$AUTOOVERWRITE = 0
			EndIf
			If $DEBUG Then ConsoleWrite("AutoOverwrite: " & $AUTOOVERWRITE & @CRLF)
		EndIf
		If StringInStr($line, "autonewlines") = 1 Then
			$NEWLINE = 1
			If StringInStr($line, "n", 0, 1, 13) <> 0 Then
				$NEWLINE = 0
			EndIf
			If $DEBUG Then ConsoleWrite("AutoNewlines: " & $NEWLINE & @CRLF)
		EndIf
		; WkHTML2PDF definitions
		If StringInStr($line, "--") = 1 Then
			$item = StringRegExpReplace($line, "\s+\w*", "")
			; override (replace)if exists
			If StringInStr($WKPARAMS, $item) > 0 Then
				$WKPARAMS = StringRegExpReplace($WKPARAMS, $item & "[^-]*", $line & " ")
				If $DEBUG Then ConsoleWrite("wkhtmltopdf param " & $item & " replaced by " & $line & @CRLF)
			Else
				$WKPARAMS = $line & " " & $WKPARAMS
				If $DEBUG Then ConsoleWrite("wkhtmltopdf param: " & $line & @CRLF)
			EndIf
		EndIf
	WEnd

	FileClose($handle)
EndFunc   ;==>getIni

Func getDef()
	Local $file, $handle, $line, $item

	$file = $DIR & "\" & $DOCNAME & ".def"

	; check def file
	If Not FileExists($file) = 1 Then
		ConsoleWrite("No " & $DOCNAME & ".def definitions file found" & @CRLF)
		Return
	EndIf

	If $DEBUG Then ConsoleWrite("Def file: " & $file & @CRLF)

	; open File
	$handle = FileOpen($file, 0)
	If $handle = -1 Then Return

	; Read in lines of text if <key>:value or until the EOF is reached
	While 1
		$line = FileReadLine($handle)
		If @error = -1 Then ExitLoop

		; check for mmd2pdf or wkhtml2pdf definitions
		If Not StringRegExp($line, '^.*:.*') And Not StringInStr($line, "--") = 1 Then ExitLoop

		If StringInStr($line, "style") = 1 Then
			If StringInStr($line, '.css') = 0 Then
				$STYLE = StringStripWS(StringMid($line, StringInStr($line, ":")+1),3)
				$CSS = "file:///" & @ScriptDir & "\styles\" & $style & ".css"
			Else
				$CSS = StringRegExpReplace($line, ".*:[ ]*", "")
			EndIf
			If $DEBUG Then ConsoleWrite("CSS:" & $CSS & @CRLF)
		EndIf
		If StringInStr($line, "pagebreakattoplevel") = 1 Then
			$PAGEBREAKATTOPLEVEL = 1
			If StringInStr($line, "n", 0, 1, 20) <> 0 Then
				$PAGEBREAKATTOPLEVEL = 0
			EndIf
			If $DEBUG Then ConsoleWrite("PageBreakAtTopLevel:" & $PAGEBREAKATTOPLEVEL & @CRLF)
		EndIf
		If StringInStr($line, "title") = 1 Then
			$TITLE = StringStripWS(StringMid($line, StringInStr($line, ":")+1),3)
			If $DEBUG Then ConsoleWrite($line & @CRLF)
		EndIf
		If StringInStr($line, "header") = 1 Then
			$PDF_HEADER = 1
			If StringInStr($line, "n", 0, 1, 20) <> 0 Then
				$PDF_HEADER = 0
			EndIf
			If $DEBUG Then ConsoleWrite("Header:" & $PDF_HEADER & @CRLF)
		EndIf
		If StringInStr($line, "footer") = 1 Then
			$PDF_FOOTER = 1
			If StringInStr($line, "n", 0, 1, 20) <> 0 Then
				$PDF_FOOTER = 0
			EndIf
			If $DEBUG Then ConsoleWrite("Footer:" & $PDF_FOOTER & @CRLF)
		EndIf
		If StringInStr($line, "include") = 1 Then
			$INFILES &= Chr(34) & $DIR & "\" & StringStripWS(StringMid($line, StringInStr($line, ":")+1),3) & Chr(34) & " "
			; More than 1 file --> automatic outline
			$PDF_OUTLINE = 1
		EndIf
		If StringInStr($line, "copyright") > 0 Then
			;$TITLE = StringRegExpReplace($line, ".*=[^\w]*", "")
		EndIf
		; WkHTML2PDF definitions
		If StringInStr($line, "--") = 1 Then
			$item = StringRegExpReplace($line, "\s+\w*", "")
			; override (replace)if exists
			If StringInStr($WKPARAMS, $item) > 0 Then
				$WKPARAMS = StringRegExpReplace($WKPARAMS, $item & "[^-]*", $line & " ")
				If $DEBUG Then ConsoleWrite("wkhtmltopdf param " & $item & " replaced by " & $line & @CRLF)
			Else
				$WKPARAMS = $line & " " & $WKPARAMS
				If $DEBUG Then ConsoleWrite("wkhtmltopdf param: " & $line & @CRLF)
			EndIf
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
	Local $file, $handle, $line, $item

	If StringLen($STYLE) > 0 Then
		$file = @ScriptDir & "\styles\" & $STYLE & ".sty"

		; check style file
		If Not FileExists($file) = 1 Then
			If $DEBUG Then
				ConsoleWrite("No " & $STYLE & ".sty definitions file found" & @CRLF)
			EndIf
			Return
		EndIf

		If $DEBUG Then ConsoleWrite("Style file: " & $file & @CRLF)

		; open File
		$handle = FileOpen($file, 0)
		If $handle = -1 Then Return

		; Read in lines of text until the EOF is reached
		While 1
			$line = FileReadLine($handle)
			If @error = -1 Then ExitLoop

			If StringInStr($line, "pagebreakattoplevel") = 1 Then
				$PAGEBREAKATTOPLEVEL = 1
				If StringInStr($line, "n", 0, 1, 20) <> 0 Then
					$PAGEBREAKATTOPLEVEL = 0
				EndIf
				If $DEBUG Then ConsoleWrite("PageBreakAtTopLevel:" & $PAGEBREAKATTOPLEVEL & @CRLF)
			EndIf
			If StringInStr($line, "--") = 1 Then
				If StringInStr($line, "--header") = 1 Then
					If $PDF_HEADER Then
						$line = StringReplace($line, "[headertitle]", $TITLE)
						$WKPARAMS = $line & " " & $WKPARAMS
						If $DEBUG Then ConsoleWrite("wkhtmltopdf header parameter: " & $line & @CRLF)
					EndIf
				ElseIf StringInStr($line, "--footer") = 1 Then
					If $PDF_FOOTER Then
						$WKPARAMS = $line & " " & $WKPARAMS
						If $DEBUG Then ConsoleWrite("wkhtmltopdf footer parameter: " & $line & @CRLF)
					EndIf
				Else
					$item = StringRegExpReplace($line, "\s+\w*", "")
					; override (replace)if exists
					If StringInStr($WKPARAMS, $item) > 0 Then
						$WKPARAMS = StringRegExpReplace($WKPARAMS, $item & "[^-]*", $line & " ")
						If $DEBUG Then ConsoleWrite("wkhtmltopdf param " & $item & " replaced by " & $line & @CRLF)
					Else
						$WKPARAMS = $line & " " & $WKPARAMS
						If $DEBUG Then ConsoleWrite("wkhtmltopdf param: " & $line & @CRLF)
					EndIf
				EndIf
			EndIf
		WEnd

		If $DEBUG Then ConsoleWrite("wkhtmltopdf parameters: " & $WKPARAMS & @CRLF)

		FileClose($handle)
	EndIf
EndFunc   ;==>getStyle
