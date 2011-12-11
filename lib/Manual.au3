#include-once

Func Manual()
	Local $html, $txt = @ScriptDir & "\mmd2pdf.txt", $pdf = @ScriptDir & "\mmd2pdf.pdf"

	If Not FileExists($pdf) Then
		ConsoleWrite("Creating Manual..." & @CRLF)

		$html = ReadFiles($txt)

		HTML2PDF($html, $pdf)

		If FileExists($pdf) Then
			; Open a .pdf file with it's default editor
			ShellExecute("mmd2pdf.pdf", "", @ScriptDir)
		EndIf
	EndIf

	$MMDHEADER = ""
EndFunc
