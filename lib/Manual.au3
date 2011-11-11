#include-once

Func Manual()
	Local $Text

	If Not FileExists(@ScriptDir & "\mmd2pdf.pdf") Then
		ConsoleWrite("Creating Manual..." & @CRLF)
		$Text = "#MMD2PDF" & @CRLF
		$Text &= @CRLF
		$Text &= "![MMD 2 PDF](mmd2pdf.jpg 'MMD2PDF Icon')"
		$Text &= @CRLF
		$Text &= "MMD2PDF converts MMD to PDF, adding a few extra's like options to include webpages and support for page-breaks." & @CRLF
		$Text &= "It is a portable utility, it will leave no traces in registry." & @CRLF
		$Text &= "##Pagebreak" & @CRLF
		$Text &= "To start Text at the beginning of a page a pagebreak kan be used." & @CRLF
		$Text &= "The pagebreak is : " & $PAGEBREAK & " on a seperate line." & @CRLF
		$Text &= @CRLF
		$Text &= "[MultiMarkdown Readme]: http://fletcher.freeshell.org/wiki/MultiMarkdown 'MultiMarkdown Readme'" & @CRLF
		$Text &= "Some simple examples of Markdown:" & @CRLF
		$Text &= "*Italic*, **Bold**, _italic_, __bold__, ***Italic & Bold (3 stars)***."
		$Text &= @CRLF
		$Text &= "[PAGEBREAK]" & @CRLF
		$Text &= "Table 1 - Tools" & @CRLF
		$Text &= @CRLF
		$Text &= "Utility                 | Language      | Document | Extension" & @CRLF
		$Text &= "----------------------- | :-----------: | :------: | -:" & @CRLF
		$Text &= "MultiMarkDown           | C++           | html     | html" & @CRLF
		$Text &= "wkhtmltopdf             | C++           | pdf      | pdf" & @CRLF
		$Text &= @CRLF
		$Text &= @CRLF
		$Text &= "[MultiMarkDown](http://fletcher.github.com/peg-multimarkdown)" & @CRLF
		$Text &= "[wkhtmltopdf](http://madalgo.au.dk/~jakobt/wkhtmltoxdoc/wkhtmltopdf-0.9.9-doc.html)" & @CRLF
		$Text &= @CRLF
		$Text &= "[WEBPAGE=http://code.google.com/p/mmd2pdf]" & @CRLF

		HTML2PDF(Text2HTML($Text), @ScriptDir & "\mmd2pdf.pdf")

		If FileExists(@ScriptDir & "\mmd2pdf.pdf") Then
			; Open a .pdf file with it's default editor
			ShellExecute("mmd2pdf.pdf", "", @ScriptDir)
		EndIf
	EndIf
EndFunc
