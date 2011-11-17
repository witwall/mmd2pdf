#include-once

Func Manual()
	Local $Text, $file = @ScriptDir & "\mmd2pdf.txt"

	If Not FileExists(@ScriptDir & "\mmd2pdf.pdf") Then
		ConsoleWrite("Creating Manual..." & @CRLF)

		$in = FileOpen(StringReplace($file,"""","", 0))

		If $in = -1 Then
			ConsoleWriteError("Error opening " & $file)
			Exit
		EndIf

		; Read text
		$Text &= FileRead($in)

		FileClose($in)

		HTML2PDF(Text2HTML($Text), @ScriptDir & "\mmd2pdf.pdf")

		If FileExists(@ScriptDir & "\mmd2pdf.pdf") Then
			; Open a .pdf file with it's default editor
			ShellExecute("mmd2pdf.pdf", "", @ScriptDir)
		EndIf
	EndIf
EndFunc
