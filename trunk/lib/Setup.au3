#include-once

Func Setup()
	If Not FileExists(@ScriptDir & "\mmd") Then
		ConsoleWrite("Setting up MMD..." & @CRLF)
		If Not DirCreate(@ScriptDir & "\mmd") Then
			ConsoleWrite("Could not create directory " & @ScriptDir & "\mmd")
		EndIf
	EndIf

	If Not FileExists(@ScriptDir & "\mmd\multimarkdown.exe") Then
		If Not FileInstall("..\mmd\multimarkdown.exe", @ScriptDir & "\mmd\multimarkdown.exe") Then
			ConsoleWrite("Could not install multimarkdown.exe into " & @ScriptDir & "\mmd")
		EndIf
	EndIf

	If Not FileExists(@ScriptDir & "\mmd\License.txt") Then
		If Not FileInstall("..\mmd\License.txt", @ScriptDir & "\mmd\License.txt") Then
			ConsoleWrite("Could not install License.txt into " & @ScriptDir & "\mmd")
		EndIf
	EndIf

	If Not FileExists(@ScriptDir & "\wkhtmltopdf") Then
		ConsoleWrite("Setting up WKHTMLTOPDF..." & @CRLF)
		If Not DirCreate(@ScriptDir & "\wkhtmltopdf") Then
			ConsoleWrite("Could not create directory " & @ScriptDir & "\wkhtmltopdf")
		EndIf
	EndIf

	If Not FileExists(@ScriptDir & "\wkhtmltopdf\wkhtmltopdf.exe") Then
		If Not FileInstall("..\wkhtmltopdf\wkhtmltopdf.exe", @ScriptDir & "\wkhtmltopdf\wkhtmltopdf.exe") Then
			ConsoleWrite("Could not install wkhtmltopdf.exe into " & @ScriptDir & "\wkhtmltopdf")
		EndIf
	EndIf

	If Not FileExists(@ScriptDir & "\wkhtmltopdf\libgcc_s_dw2-1.dll") Then
		If Not FileInstall("..\wkhtmltopdf\libgcc_s_dw2-1.dll", @ScriptDir & "\wkhtmltopdf\libgcc_s_dw2-1.dll") Then
			ConsoleWrite("Could not install libgcc_s_dw2-1.dll into " & @ScriptDir & "\wkhtmltopdf")
		EndIf
	EndIf

	If Not FileExists(@ScriptDir & "\wkhtmltopdf\License.txt") Then
		If Not FileInstall("..\wkhtmltopdf\License.txt", @ScriptDir & "\wkhtmltopdf\License.txt") Then
			ConsoleWrite("Could not install License.txt into " & @ScriptDir & "\wkhtmltopdf")
		EndIf
	EndIf

	If Not FileExists(@ScriptDir & "\templates") Then
		ConsoleWrite("Creating Templates..." & @CRLF)
		If Not DirCreate(@ScriptDir & "\templates") Then
			ConsoleWrite("Could not create directory " & @ScriptDir & "\templates")
		EndIf
	EndIf

	If Not FileExists(@ScriptDir & "\templates\default.css") Then
		If Not FileInstall("..\templates\default.css", @ScriptDir & "\templates\default.css") Then
			ConsoleWrite("Could not install default.css into " & @ScriptDir & "\templates")
		EndIf
	EndIf

	If Not FileExists(@ScriptDir & "\mmd2pdf.txt") Then
		If Not FileInstall("..\mmd2pdf.txt", @ScriptDir & "\mmd2pdf.txt") Then
			ConsoleWrite("Could not install mmd2pdf.txt into " & @ScriptDir)
		EndIf
	EndIf

	If Not FileExists(@ScriptDir & "\mmd2pdf.jpg") Then
		If Not FileInstall("..\mmd2pdf.jpg", @ScriptDir & "\mmd2pdf.jpg") Then
			ConsoleWrite("Could not install mmd2pdf.jpg into " & @ScriptDir)
		EndIf
	EndIf

EndFunc
