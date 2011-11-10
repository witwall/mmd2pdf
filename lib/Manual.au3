#include-once

Func Manual()
	If Not FileExists(@ScriptDir & "\mmd2pdf.pdf") Then
		ConsoleWrite("Creating Manual..." & @CRLF)
		$Text = "#MMD2PDF" & @CRLF
		$Text &= "MMD2PDF converts MMD to PDF, adding a few extra's like options to include webpages and support for page-breaks." & @CRLF
    $Text &= "It is a portable utility, it will leave no traces in registry." & @CRLF
		$Text &= "##Pagebreak" & @CRLF
		$Text &= "To start Text at the beginning of a page a pagebreak kan be used." & @CRLF
		$Text &= "The pagebreak is : " & $PAGEBREAK & " on a seperate line." & @CRLF
		$Text &= "Examples of some simple Markdown:" & @CRLF
    $Text &= "*Italic*, **Bold**, _italic_, __bold__, ***Italic & Bold (3 stars)***."
		$Text &= "[PAGEBREAK]" & @CRLF
		$Text &= "#New Page ******" & @CRLF
		$Text &= "[WEBPAGE=http://fletcher.github.com/peg-multimarkdown]" & @CRLF
		$Text &= "[WEBPAGE=http://madalgo.au.dk/~jakobt/wkhtmltoxdoc/wkhtmltopdf-0.9.9-doc.html]" & @CRLF

		HTML2PDF(Text2HTML($Text), @ScriptDir & "\mmd2pdf.pdf")

		If FileExists(@ScriptDir & "\mmd2pdf.pdf") Then
			; Open a .pdf file with it's default editor
			ShellExecute("mmd2pdf.pdf", "", @ScriptDir)
		EndIf
	EndIf
EndFunc
