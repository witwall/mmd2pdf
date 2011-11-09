#include-once

Func Manual()
	If Not FileExists(@ScriptDir & "\mmd2pdf.pdf") Then
		$Text = "#MMD2PDF" & @CRLF
		$Text &= "##Pagebreak" & @CRLF
		$Text &= "To start Text at the beginning of a page a pagebreak kan be used." & @CRLF
		$Text &= "The pagebreak is : " & $PAGEBREAK & " on a seperate line." & @CRLF
		$Text &= "Dit is *Italic*, dit is **Bold**, _cursief_, __vet__, ***Italic & Bold (3 stars)***."
		$Text &= "[PAGEBREAK]" & @CRLF
		$Text &= "#New Page ******" & @CRLF
		$Text &= "[WEBPAGE=http://fletcher.github.com/peg-multimarkdown]" & @CRLF

		HTML2PDF(Text2HTML($Text), "mmd2pdf.pdf")

		If FileExists(@ScriptDir & "\mmd2pdf.pdf") Then
			; Open a .pdf file with it's default editor
			ShellExecute("mmd2pdf.pdf", "", @ScriptDir)
		EndIf
	EndIf
EndFunc
