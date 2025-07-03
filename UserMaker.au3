#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=424788_w5A_icon.ico
#AutoIt3Wrapper_Outfile_x64=C:\Users\Administrator\Desktop\1(New)\Vysor12จอ_autoslide.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;~ #AutoIt3Wrapper_UseX64=y
#include "bin\udf\opencv_udf_utils.au3"
#include <Array.au3>
#include <ScreenCapture.au3>
#include <PostMessage.au3>
#include <adb_serialnumber.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <misc.au3>
#include <Date.au3>
#include <AutoItConstants.au3>
#include <StringConstants.au3>
#include <GDIPlus.au3>
#include <ComboConstants.au3>
#include <WinAPIGdiDC.au3>

$IP_Address = @IPAddress1
$MAC_Address = GET_MAC($IP_Address)

GUICreate("Login เข้าใช้งาน", 300, 200)
GUICtrlCreateLabel("ชื่อผู้ใช้ :", 50, 30)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x006600)
Local $inputUser = GUICtrlCreateInput("", 120, 25, 120, 25, $SS_CENTER)
GUICtrlSetFont(-1, 11, 800, 0, "MS Sans Serif")
GUICtrlSetBkColor(-1, 0xFFE4E1)

GUICtrlCreateLabel("รหัสผ่าน :", 50, 60)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x006600)
Local $inputPass = GUICtrlCreateInput("", 120, 55, 120, 25, $SS_CENTER)
GUICtrlSetFont(-1, 11, 800, 0, "MS Sans Serif")
GUICtrlSetBkColor(-1, 0xFFE4E1)

Local $btnLogin = GUICtrlCreateButton("Login", 50, 95, 200, 40)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x006600)

GUICtrlCreateLabel("Mac Adress: ", 50, 150)
GUICtrlCreateLabel($MAC_Address, 120, 150, 150, -1)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)

GUISetState()
loadUserini()

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
		Case $btnLogin

			GUICtrlSetData($btnLogin, "กำลังดำเนินการ...")
            Local $username = GUICtrlRead($inputUser)
            Local $password = GUICtrlRead($inputPass)
			Local $ip = $MAC_Address
			saveUserini()
            ; ส่ง username/password ไปตรวจสอบกับ Google Sheet
            If _Login($username, $password) Then
;~ 				_FinishSlip($username, $password)
				GUISetState(@SW_HIDE)
				ExitLoop
            EndIf
    EndSwitch
WEnd

Func _Login($username, $password) ;ProCom1 ใน google sheet
    Local $ip = $MAC_Address
    Local $url = "https://script.google.com/macros/s/AKfycbzQxLFywMfaUtTXrD8iSc_VuvGjVwKJxGLdBfyF3QoV1mBrce7ia4b_uVmjIM66v9TRmg/exec" & _
                 "?username=" & $username & "&password=" & $password & "&ipaddress=" & $ip

    Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
    $oHTTP.Open("GET", $url, False)
    $oHTTP.Send()

    Local $resp = StringStripWS($oHTTP.ResponseText, 3)
    If $resp = "OK" Then
		Return True
    Else
        MsgBox(16, "Login Failed", "Username หรือ Password ไม่ถูกต้อง")
    EndIf
EndFunc

Func _FinishSlip($username, $password)
    Local $ip = $MAC_Address ; หรือใช้ $MAC_Address ถ้าต้องการ
    Local $postData = "username=" & $username & _
                      "&password=" & $password & _
                      "&ipaddress=" & $ip

    ; URL ไปยัง Apps Script ที่ใช้ doPost()
    Local $url = "https://script.google.com/macros/s/AKfycbxlJ82WCgFBOgXMeESG-TFQiBmoTDaxfHU2XoDb51yuYzNIrJjbsDricWKjk6yq7xEk/exec"

    Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
    $oHTTP.Open("POST", $url, False)
    $oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    $oHTTP.Send($postData)

    Local $resp = StringStripWS($oHTTP.ResponseText, 3)
    If $resp = "OK" Then
;~         MsgBox(64, "สำเร็จ", "Login สำเร็จ และบันทึกข้อมูลแล้ว")
        Return True
    Else
;~         MsgBox(16, "ล้มเหลว", "Login ล้มเหลว หรือข้อมูลไม่ถูกต้อง" & @CRLF & "Response: " & $resp)
        Return False
    EndIf
EndFunc

Func saveUserini()

	IniWrite("SID.ini", "User", "username1", GUICtrlRead($inputUser))
	IniWrite("SID.ini", "Pass", "password1", GUICtrlRead($inputPass))

EndFunc   ;==>saveini

Func loadUserini()

	$Next_username = IniRead("SID.ini", "User", "username1", "")
	GUICtrlSetData($inputUser, $Next_username)

	$Next_password = IniRead("SID.ini", "Pass", "password1", "")
	GUICtrlSetData($inputPass, $Next_password)

EndFunc   ;==>loadini

_OpenCV_Open("cvdll\opencv_world470.dll", "cvdll\autoit_opencv_com470.dll")
Global $cv = _OpenCV_get()

Global $Combo_SetHD
Global $HD_limit

Func Terminate()
	Exit
EndFunc   ;==>Terminate

HotKeySet("{ESC}", "Terminate")

Opt("MouseCoordMode", 2)
Opt("PixelCoordMode", 2)
Opt("GUIOnEventMode", 1)

;~ ; วันหมดอายุ  08/03/2568
;~ $expdate = Floor(_DateToDayValue("2025", "06", "23")) ;Julian date since (days since noon 4713 BC January 1)
;~ If (Floor(_DateToDayValue(@YEAR, @MON, @MDAY)) > $expdate) Then
;~ 	MsgBox(0, "Error", "โปรแกรมหมดอายุ กรุณาติดต่อไลน์ joe0832")
;~ 	;run activation program
;~ 	Exit
;~ EndIf

#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("PIN2Random", 250, 225, 329, 137)
GUISetBkColor(0xFFF0F5)
GUISetOnEvent($GUI_EVENT_CLOSE, "Form1Close")

$Group1 = GUICtrlCreateGroup("", 6, 0, 65, 52)

$Combo_SetHD = GUICtrlCreateCombo("", 155, 9, 40, 40, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetFont(-1, 22, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetBkColor(-1, 0xFFD700)

;เลือกหน้าจอ
$Label_Combo2 = GUICtrlCreateLabel("USER", 10, 12, 60, 17, $SS_CENTER)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
$Label_Combo = GUICtrlCreateLabel("", 15, 28, 50, 17, $SS_CENTER)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)
$Combo1 = GUICtrlCreateCombo("", 75, 25, 100, 20, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
;~ GUICtrlSetColor(-1, 0x0000FF)
;~ GUICtrlSetBkColor(-1, 0xFF99FF)
GUICtrlSetState(-1, $GUI_HIDE)

$Label_WinHD = GUICtrlCreateLabel("", 73, 10, 80, 20, $SS_CENTER)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x000080)
$Label_Serial = GUICtrlCreateLabel("", 73, 30, 80, 17, $SS_CENTER)
GUICtrlSetBkColor(-1, 0xFF99FF)
;~ GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")

;เลือกหน้าจอ
$ButtonHD = GUICtrlCreateButton("M", 130, 10, 27, 38, $SS_CENTER)
GUICtrlSetBkColor(-1, 0xFF99FF)
GUICtrlSetOnEvent(-1, "ButtonHDClick")
GUICtrlSetState(-1, $GUI_HIDE)

;Bypass
$ButtonAuto = GUICtrlCreateButton("Bypass", 200, 9, 40, 38, $SS_CENTER)
GUICtrlSetBkColor(-1, 0x3399FF)
GUICtrlSetOnEvent(-1, "ButtonAutoClick")

GUICtrlCreateGroup("", -99, -99, 1, 1)

;เรียงหน้าจอ
$ButtonAR = GUICtrlCreateButton("จอ", 170, 7, 32, 43, $SS_CENTER)
GUICtrlSetFont(-1, 11, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x336600)
GUICtrlSetOnEvent(-1, "ButtonARClick")
GUICtrlSetState(-1, $GUI_HIDE)

;show เวลา
$Label1 = GUICtrlCreateLabel("HH", 40, 52, 40, 33, $SS_CENTER)
GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)
$Label2 = GUICtrlCreateLabel(":", 88, 52, 11, 33)
GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)
$Label3 = GUICtrlCreateLabel(":", 152, 52, 11, 33)
GUICtrlSetFont(-1, 18, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)
$Label4 = GUICtrlCreateLabel("MM", 100, 52, 46, 33, $SS_CENTER)
GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)
$Label5 = GUICtrlCreateLabel("SS", 168, 52, 38, 33, $SS_CENTER)
GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)

;เวลาถอยหลังเป๋าตัง
;~ $LabelB = GUICtrlCreateLabel("เวลาเป๋าตัง", 10, 90, 60, 15)
;~ $LabelB1 = GUICtrlCreateLabel("BH", 65, 90, 20, 25, $SS_CENTER)
;~ GUICtrlSetFont(-1, 11, 800, 0, "MS Sans Serif")
;~ GUICtrlSetColor(-1, 0x3300CC)
;~ $LabelB2 = GUICtrlCreateLabel(":", 85, 90, 11, 25)
;~ GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
;~ GUICtrlSetColor(-1, 0x3300CC)
;~ $LabelB3 = GUICtrlCreateLabel(":", 108, 90, 11, 25)
;~ GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
;~ GUICtrlSetColor(-1, 0x3300CC)
;~ $LabelB4 = GUICtrlCreateLabel("BM", 88, 90, 20, 25, $SS_CENTER)
;~ GUICtrlSetFont(-1, 11, 800, 0, "MS Sans Serif")
;~ GUICtrlSetColor(-1, 0x3300CC)
;~ $LabelB5 = GUICtrlCreateLabel("BS", 112, 90, 20, 25, $SS_CENTER)
;~ GUICtrlSetFont(-1, 11, 800, 0, "MS Sans Serif")
;~ GUICtrlSetColor(-1, 0x3300CC)

;เวลาเริ่มทำงาน
$Label6 = GUICtrlCreateLabel("รอบ", 138, 90, 20, 20, $SS_CENTER)
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetOnEvent(-1, "Label6Click")
$StartH = GUICtrlCreateInput("07", 158, 89, 25, 17, BitOR($ES_CENTER, $ES_NUMBER))
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlSetBkColor(-1, 0xFFFF00)
$StartM = GUICtrlCreateInput("30", 186, 89, 25, 17, BitOR($ES_CENTER, $ES_NUMBER))
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlSetBkColor(-1, 0xFFFF00)
$StartS = GUICtrlCreateInput("00", 214, 89, 25, 17, BitOR($ES_CENTER, $ES_NUMBER))
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlSetBkColor(-1, 0xFFFF00)

;~ $LabelMS = GUICtrlCreateLabel("MS", 180, 114, 30, 20, $SS_CENTER)
;~ $StartMS = GUICtrlCreateInput("990", 204, 112, 35, 17, BitOR($ES_CENTER, $ES_NUMBER))
;~ GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
;~ GUICtrlSetColor(-1, 0xFF0000)
;~ GUICtrlSetBkColor(-1, 0xFFFF00)
;~ GUICtrlSetLimit(-1, 3)

;ข้อความ TEST
$LabelTest = GUICtrlCreateLabel("TEST", 209, 65, 35, 20)
GUICtrlSetFont(-1, 11, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0xB03060)
GUICtrlSetState(-1, $GUI_HIDE)

;รหัสผ่านเป๋าตัง
$Label7 = GUICtrlCreateLabel("PIN", 8, 98, 45, 24)
GUICtrlSetColor(-1, 0x000080)
GUICtrlSetFont(-1, 11, 800, 0, "MS Sans Serif")
$PIN6 = GUICtrlCreateInput("", 33, 90, 100, 30, BitOR($ES_CENTER, $ES_NUMBER))
GUICtrlSetLimit(-1, 6)
GUICtrlSetFont(-1, 20, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetBkColor(-1, 0xA6CAF0)

;Dalay
$Label8 = GUICtrlCreateLabel("Delay", 45, 123, 40, 20)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
$Dalay1 = GUICtrlCreateInput("100", 80, 123, 35, 17, BitOR($ES_CENTER, $ES_NUMBER))
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetLimit(-1, 3)

;threshold ความเหมือน 0-10
$LabelThreshold = GUICtrlCreateLabel("แม่นยำ", 160, 114, 35, 17)
$threshold1 = GUICtrlCreateInput("0.85", 200, 112, 40, 17, $ES_CENTER)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetLimit(-1, 4)

;เลี้ยงpoatang
$Checkbox1 = GUICtrlCreateCheckbox("", 105, 163, 17, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetState(-1, $GUI_HIDE)

;start
$Button1 = GUICtrlCreateButton("START", 152, 135, 90, 50)
GUICtrlSetFont(-1, 10, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)
GUICtrlSetBkColor(-1, 0x00FF00)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetOnEvent(-1, "Button1Click")

;stop
$Button2 = GUICtrlCreateButton("STOP", 152, 135, 90, 50)
GUICtrlSetFont(-1, 10, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlSetBkColor(-1, 0xFF0000)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetOnEvent(-1, "Button2Click")

;สถานะการทำงาน
$Label_Status = GUICtrlCreateLabel("สถานะการทำงาน", 5, 145, 140, 45, BitOR($ES_CENTER, $SS_CENTERIMAGE))
GUICtrlSetFont(-1, 10, 800, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x006400)
;~ GUICtrlSetState(-1, $GUI_HIDE)
$Label_versoin = GUICtrlCreateLabel("Version 25.07-05", 5, 198, 140, 17, $SS_CENTER)
GUICtrlSetFont(-1, 8, 0, 0)

;~ ;Begin
$Button103 = GUICtrlCreateLabel("Begin", 140, 197, 33, 17, $SS_CENTER)
GUICtrlSetColor(-1, 0xFFFF00)
GUICtrlSetBkColor(-1, 0xFF9999)
GUICtrlSetOnEvent(-1, "Button103Click")

;เปลี่ยนโหมด
$Button102 = GUICtrlCreateLabel("<>", 177, 197, 20, 17, $SS_CENTER)
GUICtrlSetColor(-1, 0xFFFF00)
GUICtrlSetBkColor(-1, 0x0099FF)
GUICtrlSetOnEvent(-1, "Button102Click")

;Time.is
$Button101 = GUICtrlCreateLabel("Time.is", 200, 197, 40, 17, $SS_CENTER)
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlSetBkColor(-1, 0xFF0000)
GUICtrlSetOnEvent(-1, "Button101Click")

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Global $daytest

;จำกัดการใช้งานจอมือถือ
$IP_Address = @IPAddress1
$MAC_Address = GET_MAC($IP_Address)
;~ GUICtrlSetData($Button100, $MAC_Address)
;MsgBox(0, "MAC Address:", $MAC_Address)
MacCheck() ;ล็อก MAC ADDRESS ให้ใช้งานเฉพาะเครื่อง

Local $aList = WinList("PIN2Random")
For $icp2 = 1 To $aList[0][0]
	If $icp2 > $HD_limit Then
		MsgBox("", "", "เต็มจำนวนการใช้งานแล้ว", 10)
		Exit
	EndIf
	GUICtrlSetData($Combo_SetHD, $icp2) ;ลำดับหน้าจออัตโนมัติ
	;MsgBox("","",$aList[$icp2][0])
Next

Local $aProcessList = ProcessList("Vysor12จอ_autoslide.exe")
For $ipc = 1 To $aProcessList[0][0]
	If $ipc > $HD_limit Then
		MsgBox("", "", "เต็มจำนวนการใช้งานแล้ว", 10)
		Exit
	EndIf
	;MsgBox($MB_SYSTEMMODAL, "", $aProcessList[$ipc][0] & @CRLF & "PID: " & $aProcessList[$ipc][1])

Next

loadini() ;โหลดพาสเวร์ดเป๋าตัง

If @HOUR = 07 And @MIN > 30 Then
	String(GUICtrlSetData($StartH, "15"))
	String(GUICtrlSetData($StartM, "00"))
ElseIf @HOUR > 07 Then
	String(GUICtrlSetData($StartH, "15"))
	String(GUICtrlSetData($StartM, "00"))
EndIf

Func protest()

	$daytest = @MDAY
	GUICtrlSetState($LabelTest, $GUI_SHOW)

	GUICtrlSetState($Checkbox1, $GUI_CHECKED) ;เลี้ยงจอ
	Local $protestHH = @HOUR
	Local $protestMM = @MIN + 1
	If $protestMM < 10 Then
		$protestMM = String("0" & @MIN + 1)
	EndIf

	If $protestMM = 60 Then
		$protestHH = @HOUR + 1
		$protestMM = "00"

		If $protestHH < 10 Then
			$protestHH = String("0" & @HOUR + 1)
		EndIf

	EndIf
	String(GUICtrlSetData($StartH, $protestHH))
	String(GUICtrlSetData($StartM, $protestMM))

EndFunc   ;==>protest

;------------------------------ Select Handle ---------------------------------------
Global $WinHD
Global $i = 1, $sw = 0, $li = 1
Global $P1 = 0, $P2 = 0, $P3 = 0

If Not ProcessExists("Vysor.exe") Then
	MsgBox("", "", "กรุณาเปิด Vysor")
EndIf

;~ Local $aList = WinList("[CLASS:Chrome_WidgetWin_1]")
Local $aList = WinList("[CLASS:Chrome_WidgetWin_1]")
Local $pidList = ProcessList("Vysor.exe") ;Vysor.exe  chrome.exe

;**********************************************************************************
;						เลือก WinHD Auto แบบที่ 1
;**********************************************************************************

For $li = 1 To $aList[0][0]
	If WinGetProcess($aList[$li][0]) == $pidList[$li][1] Then
		GUICtrlSetData($Combo1, $aList[$li][0], $aList[1][0])
	EndIf
Next
GUICtrlSetState($Button1, $GUI_SHOW)

$checktitle = GUICtrlRead($Combo1)
For $pi = 1 To $pidList[0][0]
	If WinGetProcess($checktitle) == $pidList[$pi][1] Then
		$WinHD = WinGetHandle($checktitle)
		WinActivate($WinHD)
		_winpos()
	EndIf
Next
GUICtrlSetData($Label_WinHD,$checktitle)
;~ MsgBox("","",$checktitle);แสดงออกมาเป็นชื่อ
;**********************************************************************************
;						เลือก WinHD Auto แบบที่ 1
;**********************************************************************************

Func _winpos()
	Global $Serialpos1
	Global $pos1 = GUICtrlRead($Combo_SetHD)
	Local $widthHD = @DesktopWidth
	If $widthHD = 1366 Then
		Select
			Case $pos1 = 1
				WinMove($WinHD, "", 0, 0, 297, 730) ;จอ1 1280, 1117
				WinMove($Form1, "", 1117, 0) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 2
				WinMove($WinHD, "", 330, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 1117, 250) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 3
				WinMove($WinHD, "", 660, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 1117, 525) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
		EndSelect
	Else
		Select
			Case $pos1 = 1
				WinMove($WinHD, "", 0, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 0, 750) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 2
				WinMove($WinHD, "", 310, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 310, 750) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 3
				WinMove($WinHD, "", 620, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 620, 750) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 4
				WinMove($WinHD, "", 930, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 930, 750) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 5
				WinMove($WinHD, "", 1240, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 1240, 750) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 6
				WinMove($WinHD, "", 1550, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 1550, 750) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 7
				WinMove($WinHD, "", 1860, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 1860, 750) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 8
				WinMove($WinHD, "", 2170, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 2170, 750) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 9
				WinMove($WinHD, "", 2480, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 2480, 750) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 10
				WinMove($WinHD, "", 2790, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 2790, 750) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 11
				WinMove($WinHD, "", 3100, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 3100, 750) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
			Case $pos1 = 12
				WinMove($WinHD, "", 3410, 0, 297, 730) ;จอ1
				WinMove($Form1, "", 3410, 750) ;จอ1
				$Serialpos1 = $aSerialNumbersFound[$pos1 - 1]
		EndSelect
	EndIf

EndFunc   ;==>_winpos

GUICtrlSetData($Label_Serial, $serialpos1)
;------------------------------ หน้าต่างหลัก ---------------------------------------

While 1
	Sleep(100)
	timeshow()
	saveini()
WEnd

;------------------------------ ปุ่มต่างๆ ---------------------------------------

Func Button1Click() ;ปุ่ม start
	GUICtrlSetData($Label_Status, "กำลังทำงาน")
	GUICtrlSetBkColor($Button1, 0xBFCDDB) ;เปลี่ยนสีปุ่มstart
	GUICtrlSetBkColor($Button2, 0xFF0000) ;เปลี่ยนสีปุ่มstop
	GUICtrlSetState($Button1, $GUI_HIDE)
	GUICtrlSetState($Button2, $GUI_SHOW)
	Readpin_CK()
	GUICtrlSetBkColor($Label_Status, 0xFA8072)
	GUICtrlSetState($Checkbox1, $GUI_CHECKED) ;เลี้ยงจอ
EndFunc   ;==>Button1Click

Func Button2Click() ; ปุ่ม stop
	GUICtrlSetBkColor($Button2, 0xBFCDDB) ;เปลี่ยนสีปุ่มstop
	GUICtrlSetBkColor($Button1, 0x00FF00) ;เปลี่ยนสีปุ่มstart
	GUICtrlSetState($Button2, $GUI_HIDE)
	GUICtrlSetState($Button1, $GUI_SHOW)
	AdlibUnRegister(Paowork)
EndFunc   ;==>Button2Click

Func Label6Click() ;เทสโปรแกรม เปลี่ยนเวลา
	protest()
EndFunc   ;==>Label6Click

Func Button102Click() ;แคปภาพ
;~ 	Example()
;~ 	Pin6()
;~ _FinishSlip($username, $password)
	ToolTip("จับภาพ")
	screencap1()
	Sleep(500)
	ToolTip("")
;~ 	$DigiTest = @MDAY
EndFunc   ;==>Button102Click

Func Button101Click() ;เช็คเวลา Time.is
	ShellExecute("https://time.is/th/Thailand")
EndFunc   ;==>Button101Click

Func ButtonHDClick() ;เลือกหน้าจอ
	_winpos()
EndFunc   ;==>ButtonHDClick

Func ButtonARClick() ;เรียงหน้าจอ
;~ 	ShellExecute("Auto12.exe")
EndFunc   ;==>ButtonARClick

Func ButtonAutoClick() ;Bypass USB Debugging
	ADBPathc()
EndFunc   ;==>ButtonAutoClick

Func Form1Close()
	Exit
EndFunc   ;==>Form1Close

Func ClearApp()
	ControlClick($WinHD, "", "", "left", 1, 212, 705)
	Sleep(1000)
	ControlClick($WinHD, "", "", "left", 1, 145, 538)
	sleep(1000)
EndFunc

Func OpenPaotang()
	ClearApp()
	Local $sAdbPath = "C:\Program Files (x86)\adb\adb.exe"

	;บายพาสดีบัคusb
	Local $sAdbEnableCommand = 'shell settings put global adb_enabled 2'
	Local $sFullEnableCommand = '"' & $sAdbPath & '" -s ' & $serialpos1 & ' ' & $sAdbEnableCommand
	Run($sFullEnableCommand, "", @SW_HIDE)
	Sleep(500)

	Local $Scele1 = 'shell settings put global transition_animation_scale 0.002'
	Local $Scele2 = 'shell settings put global animator_duration_scale 0.002'
	Local $Scele3 = 'shell settings put global window_animation_scale 0.002'
	Local $runScele1 = '"' & $sAdbPath & '" -s ' & $serialpos1 & ' ' & $Scele1
	Local $runScele2 = '"' & $sAdbPath & '" -s ' & $serialpos1 & ' ' & $Scele2
	Local $runScele3 = '"' & $sAdbPath & '" -s ' & $serialpos1 & ' ' & $Scele3
	Run($runScele1, "", @SW_HIDE)
	Run($runScele2, "", @SW_HIDE)
	Run($runScele3, "", @SW_HIDE)
	Sleep(500)

	;เปิดเป๋าตัง
	Local $sAdbCommand = 'shell am start -n com.ktb.customer.qr/com.ktb.customer.qr.feature.ekyc.ui.splashscreen.EkycSplashScreenActivity'
	Local $sFullCommand = '"' & $sAdbPath & '" -s ' & $serialpos1 & ' ' & $sAdbCommand
	Run($sFullCommand, "", @SW_HIDE)

	Sleep(2000)
	Global $ckpin1 = 1
	While $ckpin1 = 1
		Pin1Check()
	WEnd
EndFunc

Func Pin1Check() ;เช็คหน้ารหัส
	_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)
			Local $match[3] = ["pin2_2", "pin22", "pin2"]
			For $gl = 0 To UBound($match) - 1
				Local $img = _OpenCV_imread_and_check(_OpenCV_FindFile("\Match\" & $pos1 & "cap1.png")) ;จับภาพ
				Local $tmpl = _OpenCV_imread_and_check(_OpenCV_FindFile("Match\" & $match[$gl] & ".png")) ;รูปที่ต้องการหา
				Local $threshold = 0.8
				Local $aMatches = _OpenCV_FindTemplate($img, $tmpl, $threshold)
					If UBound($aMatches) > 0 Then
						Local $x = $aMatches[0][0] + ($tmpl.width / 2) ; กึ่งกลางของภาพเทมเพลต (x)
						Local $y = $aMatches[0][1] + ($tmpl.height / 2) ; กึ่งกลางของภาพเทมเพลต (y)
						Pin6Begin()
						$ckpin1 = 0
						ExitLoop
					EndIf
				$cv.destroyAllWindows()
			Next
EndFunc

Func l6color()
	$l6color1 = PixelSearch ( 15, 345, 85, 432, 0x044590, 3, 1, $WinHD);สีน้ำเงิน
	$l6color2 = PixelSearch ( 15, 345, 85, 432, 0x0093D3, 3, 1, $WinHD);สีฟ้าอ่อน
	$l6color3 = PixelSearch ( 15, 345, 85, 432, 0xF4D421, 3, 1, $WinHD);สีเหลือง
	MsgBox("","",IsArray($l6color1))
	If IsArray($l6color1) And IsArray($l6color2) And IsArray($l6color3) Then
		ControlClick($WinHD, "", "", "left", 1, 32, 505) ;l6
	EndIf
EndFunc

Func Button103Click() ;Begin

	GUICtrlSetData($Label_Status, "กดรหัส Begin")
	OpenPaotang() ;เปิดเป๋าตัง

	GUICtrlSetData($Label_Status, "เข้า GLO")
	Sleep(2000)
		Local $match[3] = ["l6", "l6_2", "l6_3"]
		For $gl = 0 To UBound($match) - 1
			_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)
			sleep(500)
			Local $img = _OpenCV_imread_and_check(_OpenCV_FindFile("\Match\" & $pos1 & "cap1.png")) ;จับภาพ
			Local $tmpl = _OpenCV_imread_and_check(_OpenCV_FindFile("Match\" & $match[$gl] & ".png")) ;รูปที่ต้องการหา
			Local $threshold = 0.7
			Local $aMatches = _OpenCV_FindTemplate($img, $tmpl, $threshold)

			If UBound($aMatches) > 0 Then ; ตรวจสอบว่าพบภาพหรือไม่
				Local $x = $aMatches[0][0] + ($tmpl.width / 2) ; กึ่งกลางของภาพเทมเพลต (x)
				Local $y = $aMatches[0][1] + ($tmpl.height / 2) ; กึ่งกลางของภาพเทมเพลต (y)
				ControlClick($WinHD, "", "", "left", 1, $x, $y)
				ExitLoop
			Else
				ControlClick($WinHD, "", "", "left", 1, 203, 615) ;กดบริการ
				Sleep(1000)
				ControlClick($WinHD, "", "", "left", 1, 32, 505) ;l6
				PINerror()
			EndIf
	;~ 		;$cv.imshow("Find template example", $img)
			$cv.destroyAllWindows()
		Next
	GUICtrlSetData($Label_Status, "พร้อมทำงาน")
EndFunc   ;==>Button103Click

Func Pin6Begin() ;รหัสpin6begin
	_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)
	If Not IsObj($cv) Then Return
	$Ddelay = GUICtrlRead($Dalay1)
	$PINnumber = StringLen(GUICtrlRead($PIN6))
	For $Pn = 1 To $PINnumber
;~ 		Sleep($Ddelay)
		$sPIN6 = StringMid(GUICtrlRead($PIN6), $Pn, 1)
		Local $img = _OpenCV_imread_and_check(_OpenCV_FindFile("\Match\" & $pos1 & "cap1.png")) ;จับภาพ
		Local $tmpl = _OpenCV_imread_and_check(_OpenCV_FindFile("Match\" & $sPIN6& ".png")) ;รูปที่ต้องการหา
		Local $threshold = 0.8
		Local $aMatches = _OpenCV_FindTemplate($img, $tmpl, $threshold)
;~ 		Local $aRedColor = _OpenCV_RGB(255, 0, 0)
;~ 		Local $aMatchRect[4] = [0, 0, $tmpl.width, $tmpl.height]
;~ 		For $i = 0 To UBound($aMatches) - 1
;~ 			$aMatchRect[0] = $aMatches[$i][0]
;~ 			$aMatchRect[1] = $aMatches[$i][1]
;~ 			$cv.rectangle($img, $aMatchRect, $aRedColor)
;~ 		Next
		If UBound($aMatches) > 0 Then
			Local $x = $aMatches[0][0] + ($tmpl.width / 2) ; กึ่งกลางของภาพเทมเพลต (x)
			Local $y = $aMatches[0][1] + ($tmpl.height / 2) ; กึ่งกลางของภาพเทมเพลต (y)
			ControlClick($WinHD, "", "", "left", 1, $x, $y)
		EndIf
;~ 		$cv.imshow("Find template example", $img)
		$cv.destroyAllWindows()
		Sleep(50)
	Next
	Sleep(1000)
EndFunc   ;==>Pin6

Func PINerror() ;เช็คพินผิดให้หยุดลูป
	_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)
		Local $img = _OpenCV_imread_and_check(_OpenCV_FindFile("\Match\" & $pos1 & "cap1.png")) ;จับภาพ
		Local $tmpl = _OpenCV_imread_and_check(_OpenCV_FindFile("Match\pinerror.png")) ;รูปที่ต้องการหา
		Local $threshold = 0.7
		Local $aMatches = _OpenCV_FindTemplate($img, $tmpl, $threshold)
;~ 		Local $aRedColor = _OpenCV_RGB(255, 0, 0);สีกรอบ
;~ 		Local $aMatchRect[4] = [0, 0, $tmpl.width, $tmpl.height]
;~ 			For $i = 0 To UBound($aMatches) - 1
;~ 				$aMatchRect[0] = $aMatches[$i][0]
;~ 				$aMatchRect[1] = $aMatches[$i][1]
;~ 				$cv.rectangle($img, $aMatchRect, $aRedColor) ;วาดกรอบ
;~ 			Next
		If UBound($aMatches) > 0 Then ; ตรวจสอบว่าพบภาพหรือไม่
			Local $x = $aMatches[0][0] + ($tmpl.width / 2) ; กึ่งกลางของภาพเทมเพลต (x)
			Local $y = $aMatches[0][1] + ($tmpl.height / 2) ; กึ่งกลางของภาพเทมเพลต (y)
			GUICtrlSetData($Label_Status, "รหัสผ่านไม่ถูกต้อง")
;~ 			$logoGLO = 1
;~ 			GUICtrlSetData($Button103, "Begin")
			Button2Click()
;~ 		Else
;~ 			Button103Click()
		EndIf
;~ 		$cv.imshow("Find template example", $img)
		$cv.destroyAllWindows()
EndFunc

;------------------------------ ลำดับการทำงาน --------------------------------------

Func Readpin_CK() ;เช็ค pin
	$pin1a = GUICtrlRead($PIN6)
	$_Errpin1 = StringLen($pin1a)

	If $_Errpin1 < 6 Then
		MsgBox("", "", "ระบุรหัส PIN ไม่ถูกต้อง ห้ามเว้นว่าง " & @CRLF & "โปรดตรวจสอบรหัส PIN และแก้ไขให้ถูกต้อง")
		Button2Click()
	Else
		AdlibRegister(Paowork, 10)
	EndIf
EndFunc   ;==>Readpin_CK

Func Pin6() ;รหัสpin6

	_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)

	$torth1 = GUICtrlRead($threshold1)

	If Not IsObj($cv) Then Return

	$Ddelay = GUICtrlRead($Dalay1)
	$PINnumber = StringLen(GUICtrlRead($PIN6))
	For $Pn = 1 To $PINnumber

		$sPIN6 = StringMid(GUICtrlRead($PIN6), $Pn, 1)

		Local $img = _OpenCV_imread_and_check(_OpenCV_FindFile("\Match\" & $pos1 & "cap1.png")) ;จับภาพ
		Local $tmpl = _OpenCV_imread_and_check(_OpenCV_FindFile("Match\" & $sPIN6& ".png")) ;รูปที่ต้องการหา

		; ค่าความเหมือน
		Local $threshold = $torth1
		Local $aMatches = _OpenCV_FindTemplate($img, $tmpl, $threshold)

		; ตรวจสอบว่าพบภาพหรือไม่
		If UBound($aMatches) > 0 Then
			; ดึงตำแหน่งที่พบตำแหน่งแรก
			Local $x = $aMatches[0][0] + ($tmpl.width / 2) ; กึ่งกลางของภาพเทมเพลต (x)
			Local $y = $aMatches[0][1] + ($tmpl.height / 2) ; กึ่งกลางของภาพเทมเพลต (y)

			; คลิกที่ตำแหน่งที่เจอ
			ControlClick($WinHD, "", "", "left", 1, $x, $y)

		EndIf
		Sleep($Ddelay)
	Next
;~ 		$cv.imshow("Find template example", $img)
		$cv.destroyAllWindows()
	sleep(500)
	PINerror2()
EndFunc   ;==>Pin6

Func PINerror2() ;เช็คพินผิดให้หยุดลูป
	_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)

	Local $img = _OpenCV_imread_and_check(_OpenCV_FindFile("\Match\" & $pos1 & "cap1.png")) ;จับภาพ
		Local $tmpl = _OpenCV_imread_and_check(_OpenCV_FindFile("Match\ok2.png")) ;รูปที่ต้องการหา
		Local $threshold = 0.8
		Local $aMatches = _OpenCV_FindTemplate($img, $tmpl, $threshold)

		If UBound($aMatches) > 0 Then
			Local $x = $aMatches[0][0] + ($tmpl.width / 2) ; กึ่งกลางของภาพเทมเพลต (x)
			Local $y = $aMatches[0][1] + ($tmpl.height / 2) ; กึ่งกลางของภาพเทมเพลต (y)
			ControlClick($WinHD, "", "", "left", 1, $x, $y)
			Sleep(200)
		EndIf

		rePin6()

EndFunc

Func rePin6() ;รหัสpin6

	_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)

	$torth1 = GUICtrlRead($threshold1)

	If Not IsObj($cv) Then Return

	$Ddelay = GUICtrlRead($Dalay1)
	$PINnumber = StringLen(GUICtrlRead($PIN6))
	For $Pn = 1 To $PINnumber
;~ 		Sleep($Ddelay)
		$sPIN6 = StringMid(GUICtrlRead($PIN6), $Pn, 1)

		Local $img = _OpenCV_imread_and_check(_OpenCV_FindFile("\Match\" & $pos1 & "cap1.png")) ;จับภาพ
		Local $tmpl = _OpenCV_imread_and_check(_OpenCV_FindFile("Match\" & $sPIN6& ".png")) ;รูปที่ต้องการหา
		Local $threshold = $torth1
		Local $aMatches = _OpenCV_FindTemplate($img, $tmpl, $threshold)

		If UBound($aMatches) > 0 Then
			Local $x = $aMatches[0][0] + ($tmpl.width / 2) ; กึ่งกลางของภาพเทมเพลต (x)
			Local $y = $aMatches[0][1] + ($tmpl.height / 2) ; กึ่งกลางของภาพเทมเพลต (y)
			ControlClick($WinHD, "", "", "left", 1, $x, $y)
		EndIf
		Sleep($Ddelay)
	Next
;~ 		$cv.imshow("Find template example", $img)
		$cv.destroyAllWindows()

		PINerror3()

EndFunc   ;==>Pin6

Func PINerror3() ;เช็คพินผิดให้หยุดลูป
	_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)
	Local $match[3] = ["pin2error", "pin2error2", "pin2error3"]
	For $gl = 0 To UBound($match) - 1
		Local $img = _OpenCV_imread_and_check(_OpenCV_FindFile("\Match\" & $pos1 & "cap1.png")) ;จับภาพ
		Local $tmpl = _OpenCV_imread_and_check(_OpenCV_FindFile("Match\" & $match[$gl] & ".png")) ;รูปที่ต้องการหา
		Local $threshold = 0.7
		Local $aMatches = _OpenCV_FindTemplate($img, $tmpl, $threshold)

		If UBound($aMatches) > 0 Then ; ตรวจสอบว่าพบภาพหรือไม่
			Local $x = $aMatches[0][0] + ($tmpl.width / 2) ; กึ่งกลางของภาพเทมเพลต (x)
			Local $y = $aMatches[0][1] + ($tmpl.height / 2) ; กึ่งกลางของภาพเทมเพลต (y)
			GUICtrlSetData($Label_Status, "รหัสไม่ถูกต้อง")
			ExitLoop
			Button2Click()
		EndIf
;~ 		$cv.imshow("Find template example", $img)
		$cv.destroyAllWindows()
	Next
EndFunc

Func Paowork() ;เวลาการทำงาน
	timeshow()
	Global $Hlogin = String(GUICtrlRead($StartH))
	Global $Mlogin = String(GUICtrlRead($StartM))
	Global $Slogin = String(GUICtrlRead($StartS))

	$_ErrH = StringLen($Hlogin) ;เช็ครูปแบบเวลา
	$_ErrM = StringLen($Mlogin) ;เช็ครูปแบบเวลา
	$_ErrS = StringLen($Slogin) ;เช็ครูปแบบเวลา

	If $_ErrH < 2 Or $_ErrM < 2 Or $_ErrS < 2 Then
		MsgBox("", "", "ระบุเวลาไม่ถูกต้อง  " & $Hlogin & " : " & $Mlogin & " : " & $Slogin & @CRLF & "ไม่เข้าเงื่อนไขเวลา รูปแบบเวลา 00:00:00 MS : 000 เท่านั้น " & @CRLF & "โปรดแก้ไขให้ถูกต้อง")
		Button2Click()

	ElseIf @MDAY = 4 Or @MDAY = 19 Then ;กดซื้อ

		If @HOUR = $Hlogin And @MIN = $Mlogin And @SEC = $Slogin Then     ;กำหนดเวลาเริ่มทำงาน
			GUICtrlSetData($Label_Status, "กดซื้อจอง")
			ControlClick($WinHD, "", "", "left", 1, 235, 375)
			Sleep(200)
			Press22()
		ElseIf @HOUR = $Hlogin And @MIN = $Mlogin And @SEC = 01 Then     ;กำหนดเวลาเริ่มทำงาน
			GUICtrlSetData($Label_Status, "กดซื้อจอง2")
			ControlClick($WinHD, "", "", "left", 1, 235, 375)
			Sleep(200)
			Press22()
		ElseIf @HOUR = $Hlogin And @MIN = $Mlogin And @SEC > $Slogin Then     ;เวลา 7:30:00-7:30:59
			loginsd()
		ElseIf @HOUR = $Hlogin And @MIN > $Mlogin Then     ;เวลา 7:30:00 - 7:59:59
			loginsd()
		ElseIf @HOUR > $Hlogin Then     ;เวลา 8:00:00 เป็นต้นไป
			loginsd()
		Else
			If @HOUR = 07 And @MIN = 29 And @SEC = 46 Then
				GUICtrlSetState($Checkbox1, $GUI_UNCHECKED)     ;หยุดเลี้ยงจอ
				PressOK()
				_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)
			Else
				poatangRun()     ;เลี้ยงเป๋าตัง
			EndIf
		EndIf

	ElseIf @MDAY = 5 Or @MDAY = 20 Or @MDAY = $daytest Then ;กดจอง

		If @HOUR = $Hlogin And @MIN = $Mlogin And @SEC = $Slogin Then     ;กำหนดเวลาเริ่มทำงาน
			GUICtrlSetData($Label_Status, "กดซื้อจอง")
			ControlClick($WinHD, "", "", "left", 1, 235, 375)
			Sleep(200)
			Press22()
		ElseIf @HOUR = $Hlogin And @MIN = $Mlogin And @SEC = 01 Then     ;กำหนดเวลาเริ่มทำงาน
			GUICtrlSetData($Label_Status, "กดซื้อจอง2")
			ControlClick($WinHD, "", "", "left", 1, 235, 375)
			Sleep(200)
			Press22()
		ElseIf @HOUR = $Hlogin And @MIN = $Mlogin And @SEC > $Slogin Then     ;เวลา 7:30:00-7:30:59
			loginsd()
		ElseIf @HOUR = $Hlogin And @MIN > $Mlogin Then     ;เวลา 7:30:00 - 7:59:59
			loginsd()
		ElseIf @HOUR > $Hlogin Then     ;เวลา 8:00:00 เป็นต้นไป
			loginsd()
		Else
			If @HOUR = 07 And @MIN = 29 And @SEC = 46 Then
				GUICtrlSetState($Checkbox1, $GUI_UNCHECKED)     ;หยุดเลี้ยงจอ
				PressOK()
				_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)
			ElseIf @HOUR = 14 And @MIN = 59 And @SEC = 46 Then
				GUICtrlSetState($Checkbox1, $GUI_UNCHECKED)     ;หยุดเลี้ยงจอ
				PressOK()
				_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)

			Else
				poatangRun()     ;เลี้ยงเป๋าตัง
			EndIf
		EndIf

	ElseIf @MDAY = 6 Or @MDAY = 21 Then ;กดดิจิตอล

		If @HOUR = $Hlogin And @MIN = $Mlogin And @SEC = $Slogin Then
			ControlClick($WinHD, "", "", "left", 1, 110, 165)
			loginsdDigi()
		ElseIf @HOUR = $Hlogin And @MIN = $Mlogin And @SEC = 01 Then     ;กำหนดเวลาเริ่มทำงาน
			loginsdDigi()
		ElseIf @HOUR = $Hlogin And @MIN = $Mlogin And @SEC > 01 Then     ;เวลา 7:30:00-7:30:59
			loginsdDigi()
		ElseIf @HOUR = $Hlogin And @MIN > $Mlogin Then     ;เวลา 7:30:00 - 7:59:59
			loginsdDigi()
		ElseIf @HOUR > $Hlogin Then     ;เวลา 8:00:00 เป็นต้นไป
			loginsdDigi()
		Else
			If @HOUR = 07 And @MIN = 29 And @SEC = 46 Then
				GUICtrlSetState($Checkbox1, $GUI_UNCHECKED)     ;หยุดเลี้ยงจอ
				PressOK()
				_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)
			Else
				poatangRun()     ;เลี้ยงเป๋าตัง
			EndIf
		EndIf

	EndIf

EndFunc   ;==>Paowork

Func loginsd() ;ทำการซื้อจองเครื่อง root
	Press11() ;ซื้อจอง,ตกลง
	Press22() ;ยืนยัน
	Press33() ;รหัสผ่าน
;~ 	Prass55() ;สไลด์จิกซอ
	Finish() ;สำเร็จ
EndFunc   ;==>loginsd

Func loginsdDigi() ;ทำการซื้อจองเครื่อง root
;~ 	_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)
	Press11() ;ซื้อจอง,ตกลง
	Press22() ;ยืนยัน
	Press33() ;รหัสผ่าน
;~ 	Prass55() ;สไลด์จิกซอ
	lem2() ;เหลือก2เล่ม
;~ 	Finish() ;สำเร็จ
EndFunc   ;==>loginsd

Func Press11() ;GLO และ ตกลง
	GUICtrlSetData($Label_Status, "กดซื้อจอง")
	ControlClick($WinHD, "", "", "left", 1, 235, 375)
EndFunc

Func Press22() ;ยืนยัน
	_PostMessage_ClickDrag($WinHD, 27, 618, 280, 618, "left", 50)
EndFunc

Func lem2() ;เลือกเล่ม
	_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)
	Local $match[2] = ["2lem1", "2lem2"]
	For $gl = 0 To UBound($match) - 1
		Local $img = _OpenCV_imread_and_check(_OpenCV_FindFile("\Match\" & $pos1 & "cap1.png")) ;จับภาพ
		Local $tmpl = _OpenCV_imread_and_check(_OpenCV_FindFile("Match\" & $match[$gl] & ".png")) ;รูปที่ต้องการหา
		Local $threshold = 0.85
		Local $aMatches = _OpenCV_FindTemplate($img, $tmpl, $threshold)

			If UBound($aMatches) > 0 Then
				Local $x = $aMatches[0][0] + ($tmpl.width / 2) ; กึ่งกลางของภาพเทมเพลต (x)
				Local $y = $aMatches[0][1] + ($tmpl.height / 2) ; กึ่งกลางของภาพเทมเพลต (y)
				GUICtrlSetData($Label_Status, "กดเลือกเล่ม")
				ControlClick($WinHD, "", "", "left", 1, 15, 238)
				ControlClick($WinHD, "", "", "left", 1, $x, $y)
			EndIf
;~ 			$cv.imshow("Find template example", $img)
	 		$cv.destroyAllWindows()
	Next
EndFunc

Func Press33() ;รหัสผ่าน
	_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)
			Local $match[3] = ["pin2_2", "pin22", "pin2"]
			For $gl = 0 To UBound($match) - 1
				Local $img = _OpenCV_imread_and_check(_OpenCV_FindFile("\Match\" & $pos1 & "cap1.png")) ;จับภาพ
				Local $tmpl = _OpenCV_imread_and_check(_OpenCV_FindFile("Match\" & $match[$gl] & ".png")) ;รูปที่ต้องการหา
				Local $threshold = 0.8
				Local $aMatches = _OpenCV_FindTemplate($img, $tmpl, $threshold)
					If UBound($aMatches) > 0 Then
						Local $x = $aMatches[0][0] + ($tmpl.width / 2) ; กึ่งกลางของภาพเทมเพลต (x)
						Local $y = $aMatches[0][1] + ($tmpl.height / 2) ; กึ่งกลางของภาพเทมเพลต (y)
						GUICtrlSetData($Label_Status, "กดรหัสผ่าน")
						pin6()
						Sleep(1000)
						ExitLoop
					EndIf
				$cv.destroyAllWindows()
			Next
EndFunc

Func Finish() ;สำเร็จ
	Local $match[4] = ["finish1", "finish2", "finish3", "finish4"]
	For $gl = 0 To UBound($match) - 1
		Local $img = _OpenCV_imread_and_check(_OpenCV_FindFile("\Match\" & $pos1 & "cap1.png")) ;จับภาพ
		Local $tmpl = _OpenCV_imread_and_check(_OpenCV_FindFile("Match\" & $match[$gl] & ".png")) ;รูปที่ต้องการหา
		Local $threshold = 0.7
		Local $aMatches = _OpenCV_FindTemplate($img, $tmpl, $threshold)
;~ 		Local $aRedColor = _OpenCV_RGB(255, 0, 0)
;~ 		Local $aMatchRect[4] = [0, 0, $tmpl.width, $tmpl.height]
;~ 			For $i = 0 To UBound($aMatches) - 1
;~ 				$aMatchRect[0] = $aMatches[$i][0]
;~ 				$aMatchRect[1] = $aMatches[$i][1]
;~ 				$cv.rectangle($img, $aMatchRect, $aRedColor)
;~ 			Next
			If UBound($aMatches) > 0 Then
				Local $x = $aMatches[0][0] + ($tmpl.width / 2) ; กึ่งกลางของภาพเทมเพลต (x)
				Local $y = $aMatches[0][1] + ($tmpl.height / 2) ; กึ่งกลางของภาพเทมเพลต (y)

				DirCreate(@DesktopDir & "\MobileCap")    ;สร้างโฟลเดอร์เก็บรูป
				_ScreenCapture_CaptureWnd(@DesktopDir & "\MobileCap\" & $pos1 & "Finish.png", $WinHD)
				GUISetBkColor(0x6FB510, $Form1)
				Button2Click();หยุดทำงาน
				GUICtrlSetData($Label_Status, " สำเร็จ")
				GUICtrlSetFont($Label_Status, 28, 800, 0, "MS Sans Serif")
				GUICtrlSetColor($Label_Status, 0xFF0000)
				GUICtrlSetBkColor($Label_Status, 0xFFD700)
				sleep(500)
				GUICtrlSetData($Label_Status, "บันทึกการจองสำเร็จ")
				_FinishSlip($username, $password);บันทึกจองสำเร็จ
				Sleep(500)
				_ScreenCapture_Capture(@DesktopDir & "\MobileCap\" & "AllSreen.png")
				ExitLoop
			EndIf
;~ 			$cv.imshow("Find template example", $img)
			$cv.destroyAllWindows()
	Next
EndFunc

Func poatangRun() ;เลี้ยงโปรแกรมเป๋าตัง
	Local $paotang_CK = GUICtrlRead($Checkbox1)
	If $paotang_CK = 1 Then
		GUICtrlSetData($Label_Status, "เลี้ยงหน้าจอ")
		Local $arr_min[4] = [15, 25, 35, 45]
		For $ci = 0 To 3
			_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)
			If @SEC = $arr_min[$ci] Then
				Press11() ;กดปุ่มซื้อจอง
				Sleep(500)
			ElseIf @SEC = $arr_min[$ci] + 1 Then
				PressOK()
			EndIf
		Next
	EndIf
EndFunc   ;==>poatangRun

Func PressOK() ;GLO และ ตกลง
	_ScreenCapture_CaptureWnd(@ScriptDir & "\Match\" & $pos1 & "cap1.png", $WinHD)

		Local $img = _OpenCV_imread_and_check(_OpenCV_FindFile("\Match\" & $pos1 & "cap1.png")) ;จับภาพ
		Local $tmpl = _OpenCV_imread_and_check(_OpenCV_FindFile("Match\ok1.png")) ;รูปที่ต้องการหา
		Local $threshold = 0.7
		Local $aMatches = _OpenCV_FindTemplate($img, $tmpl, $threshold)
;~ 		Local $aRedColor = _OpenCV_RGB(255, 0, 0)
;~ 		Local $aMatchRect[4] = [0, 0, $tmpl.width, $tmpl.height]
;~ 			For $i = 0 To UBound($aMatches) - 1
;~ 				$aMatchRect[0] = $aMatches[$i][0]
;~ 				$aMatchRect[1] = $aMatches[$i][1]
;~ 				$cv.rectangle($img, $aMatchRect, $aRedColor)
;~ 			Next
			If UBound($aMatches) > 0 Then
				Local $x = $aMatches[0][0] + ($tmpl.width / 2) ; กึ่งกลางของภาพเทมเพลต (x)
				Local $y = $aMatches[0][1] + ($tmpl.height / 2) ; กึ่งกลางของภาพเทมเพลต (y)
				GUICtrlSetData($Label_Status, "กดสลากดิจิตอล")
				ControlClick($WinHD, "", "", "left", 1, $x + 90, $y)
			EndIf
;~ 			$cv.imshow("Find template example", $img)
			$cv.destroyAllWindows()

EndFunc

;*****************************************************************************************

Func screencap1()

	DirCreate(@DesktopDir & "\ScreenCap")    ;สร้างโฟลเดอร์เก็บรูป

	GUICtrlSetData($Label_Status, "กำลังจับภาพ")
	Local $sText = ""
	For $capj = 1 To 5
		$sText &= Chr(Random(65, 90, 1))
	Next
	Select
		Case $pos1 = 1
;~ 			_ScreenCapture_Capture(@DesktopDir & "\p18" & "\"&$i&$sText&".png",0,0, 297,730) ;จอ1
			_ScreenCapture_CaptureWnd(@DesktopDir & "\ScreenCap\" & $i & $sText & ".png", $WinHD)
		Case $pos1 = 2
			_ScreenCapture_CaptureWnd(@DesktopDir & "\ScreenCap\" & $i & $sText & ".png", $WinHD)
		Case $pos1 = 3
			_ScreenCapture_CaptureWnd(@DesktopDir & "\ScreenCap\" & $i & $sText & ".png", $WinHD)
		Case $pos1 = 4
			_ScreenCapture_CaptureWnd(@DesktopDir & "\ScreenCap\" & $i & $sText & ".png", $WinHD)
		Case $pos1 = 5
			_ScreenCapture_CaptureWnd(@DesktopDir & "\ScreenCap\" & $i & $sText & ".png", $WinHD)
		Case $pos1 = 6
			_ScreenCapture_CaptureWnd(@DesktopDir & "\ScreenCap\" & $i & $sText & ".png", $WinHD)
		Case $pos1 = 7
			_ScreenCapture_CaptureWnd(@DesktopDir & "\ScreenCap\" & $i & $sText & ".png", $WinHD)
		Case $pos1 = 8
			_ScreenCapture_CaptureWnd(@DesktopDir & "\ScreenCap\" & $i & $sText & ".png", $WinHD)
		Case $pos1 = 9
			_ScreenCapture_CaptureWnd(@DesktopDir & "\ScreenCap\" & $i & $sText & ".png", $WinHD)
		Case $pos1 = 10
			_ScreenCapture_CaptureWnd(@DesktopDir & "\ScreenCap\" & $i & $sText & ".png", $WinHD)
		Case $pos1 = 11
			_ScreenCapture_CaptureWnd(@DesktopDir & "\ScreenCap\" & $i & $sText & ".png", $WinHD)
		Case $pos1 = 12
			_ScreenCapture_CaptureWnd(@DesktopDir & "\ScreenCap\" & $i & $sText & ".png", $WinHD)
	EndSelect
	$i = $i + 1

EndFunc   ;==>screencap1

Func ADBcapture()

; สร้าง timestamp สำหรับชื่อโฟลเดอร์
Local $timestamp = _NowCalcDate()
$timestamp = StringReplace($timestamp, "/", "-")
$timestamp = StringReplace($timestamp, ":", "-")
$timestamp = StringReplace($timestamp, " ", "_")

; Path เก็บ adb.exe (ถ้าจำเป็น)
Local $adbPath = "C:\Program Files (x86)\adb\adb.exe" ; หรือใช้ path เต็ม เช่น "C:\Android\platform-tools\adb.exe"

; ดึงรายการอุปกรณ์
Local $pid = Run(@ComSpec & " /c " & $adbPath & " devices", "", @SW_HIDE, $STDOUT_CHILD)
ProcessWaitClose($pid)
Local $sOutput = StdoutRead($pid)

;~ ConsoleWrite("=== ADB OUTPUT ===" & @CRLF & $sOutput & @CRLF)

; แยกบรรทัด
Local $lines = StringSplit($sOutput, @CRLF, 1)

; สร้างโฟลเดอร์สำหรับเก็บภาพ
Local $savePath = @DesktopDir & "\screenshots_" & $timestamp
DirCreate($savePath)

Local $sText = ""
	For $jj = 1 To 5
		$sText &= Chr(Random(65, 90, 1))
	Next

; ลูปทีละบรรทัด
For $i = 1 To $lines[0]
    Local $line = $lines[$i]

    ; ข้าม header และบรรทัดว่าง
    If StringStripWS($line, 3) = "" Or StringInStr($line, "List of devices") Then
        ContinueLoop
    EndIf

    ; แยกเอา serial number (tokens=1)
    Local $parts = StringSplit($line, @TAB, 1)
    If $parts[0] >= 1 Then
        Local $serial = $parts[1]
;~         ConsoleWrite("แคปจากอุปกรณ์: " & $serial & @CRLF)
		GUICtrlSetData($Label_Status, $serial)

        ; ถ่ายภาพหน้าจอ
        RunWait($adbPath & " -s " & $serial & " shell screencap -p /sdcard/screenshot.png", "", @SW_HIDE)

        ; ดาวน์โหลดภาพ
        Local $outputFile = $savePath & "\screenshot_" & $serial & $sText & ".png"
        RunWait($adbPath & " -s " & $serial & " pull /sdcard/screenshot.png """ & $outputFile & """", "", @SW_HIDE)

	EndIf
Next
;~ GUICtrlSetData($Label_Status, "บันทึกเรียบร้อย")
EndFunc

Func timeshow() ;เวลา

	GUICtrlSetData($Label1, @HOUR)
	GUICtrlSetData($Label4, @MIN)
	GUICtrlSetData($Label5, @SEC)

EndFunc   ;==>timeshow

Func saveini()

	IniWrite("SID.ini", "PinID", "PinID6", GUICtrlRead($PIN6))
;~ 	IniWrite("SID.ini", "DelaySet", "Delay1", GUICtrlRead($Dalay1))
;~ 	IniWrite("SID.ini", "Torch", "threshold1", GUICtrlRead($threshold1))

EndFunc   ;==>saveini

Func loadini()

	$Next_PinID = IniRead("SID.ini", "PinID", "PinID6", "")
	GUICtrlSetData($PIN6, $Next_PinID)

;~ 	$Next_Delay = IniRead("SID.ini", "DelaySet", "Delay1", "")
;~ 	GUICtrlSetData($Dalay1, $Next_Delay)

;~ 	$Next_threshold = IniRead("SID.ini", "Torch", "threshold1", "")
;~ 	GUICtrlSetData($threshold1, $Next_threshold)

EndFunc   ;==>loadini

Func GET_MAC($_MACsIP) ;MAC ADDRESS
	Local $_MAC, $_MACSize
	Local $_MACi, $_MACs, $_MACr, $_MACiIP
	$_MAC = DllStructCreate("byte[6]")
	$_MACSize = DllStructCreate("int")
	DllStructSetData($_MACSize, 1, 6)
	$_MACr = DllCall("Ws2_32.dll", "int", "inet_addr", "str", $_MACsIP)
	$_MACiIP = $_MACr[0]
	$_MACr = DllCall("iphlpapi.dll", "int", "SendARP", "int", $_MACiIP, "int", 0, "ptr", DllStructGetPtr($_MAC), "ptr", DllStructGetPtr($_MACSize))
	$_MACs = ""
	For $_MACi = 0 To 5
		If $_MACi Then $_MACs = $_MACs & ":"
		$_MACs = $_MACs & Hex(DllStructGetData($_MAC, 1, $_MACi + 1), 2)
	Next
	DllClose($_MAC)
	DllClose($_MACSize)
	Return $_MACs
EndFunc   ;==>GET_MAC

Func MacCheck() ;เช็ค mac address

	Local $ipMAC[300] ;แบบ 12 จอ ****************************
	$ipMAC[0] = "C8:60:00:A2:51:78" ;เครื่องคิดเงิน
	$ipMAC[1] = "00:E0:1E:80:A1:D4" ;เครื่อง 1
	$ipMAC[2] = "00:E0:1D:67:00:60" ;เครื่อง 2
	$ipMAC[3] = "00:E0:1D:6F:40:94" ;เครื่อง 3
	$ipMAC[4] = "00:E0:1D:60:40:90" ;เครื่อง 4
	$ipMAC[5] = "00:E0:1D:6E:00:85" ;เครื่อง 5
	$ipMAC[6] = "00:E0:1E:60:07:5C" ;เครื่อง 6
	$ipMAC[7] = "00:E0:1E:7E:B2:37" ;เครื่อง 7
	$ipMAC[8] = "00:E0:1E:63:35:07" ;เครื่อง 8
	$ipMAC[9] = "00:E0:1E:7E:C1:F3" ;เครื่อง 9
	$ipMAC[10] = "00:E0:1E:98:11:AE" ;เครื่อง 10
	$ipMAC[11] = "00:E0:4F:15:D1:CF" ;เครื่อง 11
	$ipMAC[12] = "00:E0:1E:67:17:51" ;เครื่อง 12
	$ipMAC[13] = "90:DE:80:BA:1B:2F" ;เครื่อง 13
	$ipMAC[14] = "00:E0:1E:31:82:E5" ;เครื่อง 13 xeon*2
;~ 	; **************** Jack J *************** 14 เครื่อง
	$ipMAC[15] = "B4:2E:99:1B:7A:4B"
	$ipMAC[16] = "00:E0:4F:25:45:80"
	$ipMAC[17] = "00:E0:1E:85:50:2F"
	$ipMAC[18] = "F0:A6:54:4E:FF:FD"
	$ipMAC[19] = "00:E0:1E:79:04:D4"
	$ipMAC[20] = "5C:A6:E6:D1:77:18"
	$ipMAC[21] = "00:E0:1E:77:35:C7"
	$ipMAC[22] = "00:D8:61:FE:3D:0D"
	$ipMAC[23] = "A8:5E:45:5A:FA:BA"
	$ipMAC[24] = "C8:7F:54:50:B6:BC"
	$ipMAC[25] = "50:3E:AA:0B:9D:DE"
	$ipMAC[26] = "00:E0:4F:26:B6:4B"
	$ipMAC[27] = "00:E0:1E:77:35:C7" ;Jack J
	$ipMAC[28] = "50:3E:AA:0B:9D:DE" ;Jack J
	$ipMAC[29] = "02:50:25:F0:CC:7F" ;Jack J
	$ipMAC[30] = "00:E0:4F:29:24:CF" ;Jack J
	$ipMAC[31] = "00:E0:21:36:62:C8" ;no1
	$ipMAC[32] = "B0:83:FE:6D:0C:CE" ;no2
	$ipMAC[33] = "48:4D:7E:D8:7D:5E" ;no2
	$ipMAC[34] = "78:24:AF:A0:D0:3B" ;no2
;~ 	; **************** Jejha *************** 5 เครื่อง
	$ipMAC[35] = "00:E0:1E:91:57:21" ;no1
	$ipMAC[36] = "A8:A1:59:DD:7A:E3" ;no2
	$ipMAC[37] = "00:E0:1E:70:10:68" ;no3
	$ipMAC[38] = "70:85:C2:FE:6A:C0" ;no4
	$ipMAC[39] = "08:8F:C3:40:BA:C0" ;no5
	$ipMAC[40] = "98:E7:43:C8:9E:1A" ;no6
	$ipMAC[41] = "54:AB:3A:D2:7B:37" ;no7 พร้อมเครื่อง
	$ipMAC[42] = "00:E0:1E:91:56:C4" ;no8 พร้อมเครื่อง
	$ipMAC[43] = "00:E0:1E:91:57:25" ;no9 พร้อมเครื่อง
	$ipMAC[44] = "00:E0:1D:DB:27:F7" ;no10 พร้อมเครื่อง
	$ipMAC[45] = "50:EB:F6:25:68:13" ;no10
;~ 	; **************** โจ้ห้วยแถลง *************** 4 เครื่อง
	$ipMAC[46] = "00:E0:1E:2E:03:E3" ;no1
	$ipMAC[47] = "00:E0:1E:02:80:99" ;no2
	$ipMAC[48] = "00:E0:1D:6E:00:1E" ;no3
	$ipMAC[49] = "04:7C:16:D6:8E:AF" ;no4
	$ipMAC[50] = "B4:8C:9D:41:54:67" ;no4
	$ipMAC[51] = "00:E0:21:59:11:61" ;no4
;~ 	; **************** ร้านเจ้จู *************** 2 เครื่อง
	$ipMAC[52] = "00:E0:1E:06:30:96" ;no1
	$ipMAC[53] = "00:E0:1A:D2:0A:97" ;no2
;~ 	; **************** Bunma *************** 3 เครื่อง
	$ipMAC[54] = "A8:41:F4:58:EA:15" ;no1
	$ipMAC[55] = "10:68:38:15:8B:F1" ;no2
	$ipMAC[56] = "74:40:BB:52:FA:15"
	$ipMAC[57] = "70:32:17:57:1D:6D" ;no2 3 จอ
	$ipMAC[58] = "C0:BF:BE:44:85:A6"
;~ 	; **************** S.Panadda *************** 2 เครื่อง
	$ipMAC[59] = "D0:39:57:66:F8:FB" ;no1
	$ipMAC[60] = "F8:54:F6:E8:61:13" ;no2
;~ 	; **************** Max kub *************** 4 เครื่อง
	$ipMAC[70] = "B4:2E:99:22:5C:E5" ;no1 i3-8100
	$ipMAC[71] = "AA:1C:04:15:2F:9B" ;no2 E5-2680 v4
	$ipMAC[72] = "0A:E0:AF:AF:00:4E" ;no3 เครื่องใหม่
	$ipMAC[73] = "04:7C:16:08:F5:A3" ;no3 เครื่องใหม่
;~ 	; **************** Pailin *************** 1เครื่อง
	$ipMAC[74] = "28:39:26:8D:41:4F" ;no1
;~ 	; **************** Lin Lalinda *************** 3 เครื่อง
	$ipMAC[75] = "B8:1E:A4:F0:41:B9" ;no3 10จอ
	$ipMAC[76] = "D0:39:57:7A:6E:2F" ;no3 10จอ
;~ 	; **************** วิจิตร สุขจิตร *************** 4 เครื่อง
	$ipMAC[77] = "00:E0:4F:26:8E:B9" ;no1 pc
	$ipMAC[78] = "70:66:55:F6:98:33" ;no2
	$ipMAC[79] = "F4:C8:8A:31:FD:35" ;no3 asus tuf
	$ipMAC[80] = "00:E0:1F:DB:90:51" ;no4 xeon
	$ipMAC[81] = "D8:43:AE:6E:0F:A9" ;
	$ipMAC[82] = "30:16:9D:6B:26:57" ;
;~ 	; **************** Bundit Jo *************** 3 เครื่อง
	$ipMAC[83] = "24:4B:FE:DE:B6:8E" ;no1
	$ipMAC[84] = "60:45:2E:B9:47:86" ;no2
	$ipMAC[85] = "AC:74:B1:35:C9:01" ;no1
;~ 	; **************** Witt Yaa *************** 3 เครื่อง
	$ipMAC[86] = "B4:2E:99:83:BC:B2" ;no1
	$ipMAC[87] = "20:16:b9:24:37:13" ;no2
	$ipMAC[88] = "70:85:c2:a7:b3:2f" ;no3
	; **************** Beau *************** 1 เครื่อง
	$ipMAC[89] = "A0:36:BC:2D:E4:3A" ;no1
	; **************** Nitjawan Saenkla *************** 1 เครื่อง
	$ipMAC[90] = "04:7C:16:DA:40:C0" ;no1
	$ipMAC[91] = "c8:8a:9a:e5:61:ef" ;no1
	; **************** komsak *************** 1 เครื่อง
	$ipMAC[92] = "10:FF:E0:26:3B:B8" ;no1 lan i7-14700F
	$ipMAC[93] = "CA:42:26:14:2D:C1" ;no1
	; **************** ยิ่ง อนันต์สิทธิ์ *************** 3 เครื่อง
	$ipMAC[94] = "00:D8:61:78:82:F1" ;no1
	$ipMAC[95] = "D8:5E:D3:21:A9:CC" ;no1
	$ipMAC[96] = "F8:89:D2:8D:2C:57" ;no1
	$ipMAC[97] = "10:FF:E0:20:31:CA" ;no1
	$ipMAC[98] = "2C:F0:5D:0F:44:A0" ;no1
	$ipMAC[99] = "7C:10:C9:43:5C:1F" ;no1
	$ipMAC[100] = "84:1B:77:DD:CB:5B" ;no1
	; **************** รุ่งเรือง การค้า *************** 2 เครื่อง
	$ipMAC[101] = "9C:6B:00:16:4F:2B" ;no1
	$ipMAC[102] = "A8:A1:59:66:7F:7F" ;no1
	; **************** I'am Ae *************** 1 เครื่อง
	$ipMAC[103] = "18:C0:4D:E3:25:59" ;no1
	; **************** พี่กระถิน *************** 2.5 เครื่อง
	$ipMAC[104] = "58:11:22:C7:8E:05" ;no6 i7-12700
	$ipMAC[105] = "74:56:3C:94:CA:37" ;no7 i7-13700K
	$ipMAC[106] = "06:E8:B9:34:CD:71" ;no1 i7 1255u
;~ 	; **************** มะปราง/Maprang  *************** 1 เครื่อง
 	$ipMAC[107] = "A8:41:F4:5B:FF:21" ;no1
	; **************** ช่างพึ่ง  *************** 1 เครื่อง
 	$ipMAC[108] = "b8:86:87:55:b0:a9" ;no1
	; **************** jaib  *************** 1 เครื่อง
 	$ipMAC[109] = "20:0b:74:5b:03:77" ;no1
	; **************** พี่ศักดิ์  *************** 1 เครื่อง
 	$ipMAC[110] = "a8:a1:59:d5:cb:71" ;no1
	; **************** ประพจน์ *************** 1 เครื่อง
 	$ipMAC[111] = "4c:d7:17:9a:47:de" ;no1

	Local $iMac, $iMac2 = 0

	For $iMac = 0 To UBound($ipMAC) - 1 ;เสรี + ไอพีดิจิตอล
		If $ipMAC[$iMac] = $MAC_Address Then
			$iMac2 = 1
			$HD_limit = 12
			GUICtrlSetData($Combo_SetHD, "1|2|3|4|5|6|7|8|9|10|11|12", "1")
			GUICtrlSetData($Label_Combo, $username)
		EndIf
	Next

	If $iMac2 = 0 Then
		If $MAC_Address = "00:00:00:00:00:00" Then
			MsgBox("", "", "กรุณาเชื่อมต่ออินเตอร์เน็ต")
			Exit
		Else
			MsgBox("", "รหัสเครื่อง", "เลขเครื่อง " & $MAC_Address & " ไม่ได้ลงทะเบียนใช้งาน" & @CRLF & "ติดต่อไลน์ joe0832", 5)
			Run("Notepad.exe")
			WinWait("[CLASS:Notepad]", "", 2000)
			Local $NoteHD = WinGetHandle("[CLASS:Notepad]")
			WinMove($NoteHD, "", 769, 276, 549, 431)
			WinActivate($NoteHD)
			ControlSend($NoteHD, "", "", @CRLF & "เครื่องคอมพิวเตอร์" & @CRLF & $MAC_Address & @CRLF & "ไม่ได้ลงทะเบียนใช้งาน โปรดติดต่อไลน์ joe0832")
			ControlSend($NoteHD, "", "", @CRLF & "ให้ทำการบันทึกแล้วส่งไลน์เพื่อทำการลงทะเบียนใช้งาน" & @CRLF & "มีค่าดำเนินการตามเงื่อน")

			Exit
		EndIf
	EndIf

EndFunc   ;==>MacCheck

