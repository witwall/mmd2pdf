#include-once
#include "encode.au3"

Func ReadFiles($files)
	Local $Text, $line, $i, $in, $pos, $fileList, $firstTopLevel, $getHeader = 1

	If $TEST Then ConsoleWrite("Files: " & $files & @CRLF)

	$fileList = StringSplit($files, """ """, 1)
	For $i = 1 To $fileList[0]
		; open File
		$in = FileOpen(StringReplace($fileList[$i],"""",""), 16384) ; UTF8 BOM Check

		If $in = -1 Then
			ConsoleWriteError("Error opening " & $fileList[$i])
			Exit
		EndIf

		$firstTopLevel = 0
		; Read text
		While 1
			$line = FileReadLine($in)
			If @error = -1 Then ExitLoop

			; Get MMD Header
			If $getHeader Then
				$getHeader = 0

				While StringRegExp($line, '^[\w ]*:.*')
					$MMDHEADER &= $line & @CRLF
					$line = FileReadLine($in)
					If @error = -1 Then ExitLoop
				WEnd

				If $TEST Then ConsoleWrite("MMD Header:" & @CRLF & $MMDHEADER & @CRLF)
			EndIf

			; detect pagebreaks
			If $PAGEBREAKATTOPLEVEL Then
				If StringRegExp($line, '^==*$') Then
					If Not $firstTopLevel Then
						$firstTopLevel = 1
					Else
						$pos = StringInStr($Text, @CRLF, 0, -2)
						If $pos > 0 Then
							$Text = StringLeft($Text, $pos-1) & @CRLF & $PAGEBREAK & StringMid($Text, $pos)
						EndIf
					EndIf
				EndIf
				If StringRegExp($line, "^#[^#]") Then
					If Not $firstTopLevel Then
						$firstTopLevel = 1
					Else
						$Text &= $PAGEBREAK & @CRLF
					EndIf
				EndIf
			EndIf

			$Text &= $line & @CRLF
		WEnd

		If $i < $fileList[0] Then
			$Text &= $PAGEBREAK & @CRLF
		EndIf

		FileClose($in)
	Next

	If $TEST Then ConsoleWrite($Text & @CRLF)

	Return Text2HTML($Text)
EndFunc

Func Text2HTML($inTXT)
	Local $out, $url, $succ, $dia, $line, $lines, $tempTXT, $tempHTML, $tempDIA, $Header, $fileList, $page=0, $image=0, $newFile=0, $start=1, $chars

	; Split text in lines on CRLF
	$lines = StringSplit($inTXT, @CRLF, 1)

	If $TEST Then ConsoleWrite($lines[0] & " lines of text..." & @CRLF)

	For $i = 1 To $lines[0]
		$line = $lines[$i]

		; Find Include HTML
		If StringLeft($line, 9) = "[WEBPAGE=" Then
			$url = StringMid($line, 10, StringLen($line) - 10)
			ConsoleWrite("Downloading " & $url & "..." & @CRLF)
			$succ = InetGet($url, @TempDir & "\MMD2PDF\Temp" & $page + 1 & ".html", 1)
			If $succ Then
				$newFile = 1
				$page = $page + 1
				$fileList &= "Temp" & $page & ".html "
			Else
				$line="    [" & $url & "]" & @CRLF
			EndIf
		EndIf

		; Split text on $PAGEBREAK
		If $line = $PAGEBREAK Or $newFile Or $start Then
			If Not $start Then
				$newFile = 0
				FileClose($out)
				MMD($tempTXT, $tempHTML)
			EndIf

			$start = 0
			$page = $page + 1
			ConsoleWrite("Creating HTML " & $page & "..." & @CRLF)
			$tempTXT = @TempDir & "\MMD2PDF\Temp" & $page & ".txt"
			$tempHTML = @TempDir & "\MMD2PDF\Temp" & $page & ".html"
			; Don't use full path (CSS)
			$fileList &= "Temp" & $page & ".html "

			;$out = FileOpen($tempTXT, 2 + 8 + 256) ;Write New, Create Dir, UTF-8 (No BOM)
			$out = FileOpen($tempTXT, 2 + 8 + 128) ;Write New, Create Dir, UTF-8 (With BOM)

			If $out = -1 Then
				MsgBox(0, $APPTITLE, "Could not create " & $tempTXT)
				Exit
			EndIf

			; Write the Base Header - This is needed to include Images in the document directory
			; Path must end with "\"
			$Header = 'HTML Header: <base href="' & $DIR & "\" & '" />  ' & @CRLF

			; Write CSS, overruled by CSS in MMD definition
			$Header &= 'CSS: ' & $CSS & @CRLF

			If StringRegExp($MMDHEADER, 'Title:') <> 1 Then
				$Header &= "Title: " & StringUpper(StringLeft($DOCNAME, 1)) & StringMid($DOCNAME, 2) & "  " & @CRLF
			EndIf
			$Header &= $MMDHEADER & @CRLF

			FileWriteLine($out, $Header)
			If $TEST Then ConsoleWrite("Header: " & @CRLF & $Header & @CRLF)
		EndIf

		; Don't show Pagebreak command
		If StringLeft($line, 9) = "[WEBPAGE=" Or $line = $PAGEBREAK Then ContinueLoop

		If $OUTPUT = "pdf" Then
			$line = Encode($line)
		EndIf

		If $NEWLINE Then
			$chars = StringLeft($line, 1) + StringRight($line, 1)
			If Not ($chars="==" Or $chars="--") Then
				$line &= "  " ; break - end line with 2 spaces
			EndIf
		EndIf
		FileWriteLine($out, $line)

	Next
	FileClose($out)
	MMD($tempTXT, $tempHTML)

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
	local $tempDir

	; wkhtmltopdf --print-media-type --margin-top 4mm --margin-bottom 4mm --margin-right 0mm --margin-left 0mm --encoding A4 --page-size A4 --orientation Portrait --redirect-delay 100 test1.html test.pdf
	If $PDF_OUTLINE > 0 Then
		$WKPARAMS &= " --outline"
		If $PDF_OUTLINE > 1 Then $WKPARAMS &= " --outline-depth " & $PDF_OUTLINE
	EndIf

	; TO USE CSS don't use full path for HTML Files!
	$WKPARAMS &= " " & $inHTMLs & " "
	$WKPARAMS &= '"' & $outPDF & '"'

	If $TEST Then ConsoleWrite("WK Params:" & @CRLF & $WKPARAMS & @CRLF & $DIR & @CRLF)
	;Set working directory to HTML File for included files!
	$tempDir = @WorkingDir
	FileChangeDir(@TempDir & "\MMD2PDF")

	ConsoleWrite("Creating PDF..." & @CRLF)
	; Debug: RunWait(@ComSpec & " /k " & '"' & $HTML2PDFEXE & '" ' & $WKPARAMS, $DIR)
	ShellExecuteWait($HTML2PDFEXE, $WKPARAMS, @TempDir & "\MMD2PDF", "Open", @SW_HIDE)

	;Set working directory back
	FileChangeDir($tempDir)

	If Not $TEST Then
		FileDelete(@TempDir & "\MMD2PDF")
	EndIf
EndFunc   ;==>HTML2PDF
