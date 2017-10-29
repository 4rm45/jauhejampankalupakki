; JauheJampan KaluPakki

#include <AutoItConstants.au3> ; MouseClick
#include <GUIConstantsEx.au3> ; GUI
#include <EditConstants.au3> ; Inputin merkkifiltteri
#include <WindowsConstants.au3> ; Ikkunatyyli
#include <ColorConstants.au3> ; Varotuksen väri
#include <StaticConstants.au3> ; Labelien keskitys
#include <ButtonConstants.au3> ; Nappispecsit
#include <Date.au3> ; ETA-laskuri
#include <File.au3> ; Loki
#include <Sound.au3> ; BeepBoop

HotKeySet("{ESC}", "Terminate") ; Luo hätäseis-nappi

Opt("TrayMenuMode",1) ; Hävitä trayn valikko

Local $sVerNumber, $hGUI_Main

$sVerNumber = "v1.2.1-beta"

$hGUI_Main = GUICreate("JauheJampan KaluPakki", 410, 115, Default, Default, $WS_POPUPWINDOW) ; Luo pääkäyttöliittymä
Local $idButton_Stickers, $idButton_Timer, $idButton_Exit, $nStickerDefaultAmount, $eSackTime, $nAlarmLimit, _
$nThirdAlarmLimit, $nSackDefaultAmount, $nPalletDefaultAmount, $idGraphic_SeparatorMain
GUICtrlCreateLabel("JauheJampan Kalupakki", 12, 9, Default, 15, $SS_LEFT) ; Ja tekstit
GUICtrlCreateLabel($sVerNumber, 336, 9, Default, 15, $SS_RIGHT)
$idButton_Stickers = GUICtrlCreateButton("Tarrat", 10, 35, 70, 70, $BS_ICON)
; GUICtrlSetImage ($idButton_Stickers,"ico/barcode.ico")
$idButton_Timer = GUICtrlCreateButton("Ajastin", 90, 35, 70, 70, $BS_ICON)
; GUICtrlSetImage ($idButton_Timer,"ico/timer.ico")
$idButton_Tags = GUICtrlCreateButton("Laput", 170, 35, 70, 70, $BS_ICON)
; GUICtrlSetImage ($idButton_Tags,"ico/tags.ico") -Ei icoa läsnä
$idButton_Settings = GUICtrlCreateButton("Asetukset", 250, 35, 70, 70, $BS_ICON)
; GUICtrlSetImage ($idButton_Tags,"ico/settings.ico") -Ei icoa läsnä
$idButton_Exit = GUICtrlCreateButton("Poistu", 330, 35, 70, 70, $BS_ICON)
; GUICtrlSetImage ($idButton_Exit,"ico/exit.ico")

MainGUI()

Func MainGUI() ; Pääkäyttöliittymä

GUISetState(@SW_SHOW, "JauheJampan KaluPakki") ; GUI näkyviin
_FileWriteLog(@ScriptDir & "\log.log", "KaluPakki avattu.")

While 1 ; Pollataan käyttäjän interactionia
	  Switch GUIGetMsg()
		 Case $GUI_EVENT_CLOSE, $idButton_Exit ; Sulje ikkuna ALT+F4:llä tai napista
		 _FileWriteLog(@ScriptDir & "\log.log", "KaluPakki suljettu.")
		 Exit
		 Case $idButton_Stickers ; Käynnistä TarraAparaatti
			GUISetState(@SW_HIDE)
			StickerMatic()
		 Case $idButton_Timer ; Käynnistä SäkkiAjastin
			GUISetState(@SW_HIDE)
			SackTimer()
		 Case $idButton_Tags ; Käynnistä LavaLappuLatoja
			GUISetState(@SW_HIDE)
			PalletTag()
		 Case $idButton_Settings ; Näytä asetukset
			GUISetState(@SW_HIDE)
			Settings()
	  EndSwitch
WEnd
EndFunc

Func StickerMatic() ; TarraAparaatti

Local $hGUI_Tarra
$hGUI_Tarra = GUICreate("TarraAparaatti", 180, 110, Default, Default, $WS_POPUPWINDOW) ; Luo GUI
GUICtrlCreateLabel("Montako tarraa tarvihet?", 10, 10, 160, Default, $SS_CENTER) ; Teksti piälle
Local $idInput_StickerAmount, $idButton_Print, $idButton_ExitSticker, $idLabel_WarningSticker
$nStickerDefaultAmount = IniRead("settings.ini", "TarraAparaatti", "TarratTarjolla", "10")
$idInput_StickerAmount = GUICtrlCreateInput($nStickerDefaultAmount, 80, 30, 20, 20, $ES_NUMBER) ; Kysy tarrojen lkm raa'aks muuttujaks
GUICtrlSetLimit(-1, 2) ; Myöhän ei kolminumeroisia lukuja katella
$idButton_Print = GUICtrlCreateButton("Tulosta", 10, 75, 75, 25) ; Ja napit
$idButton_ExitSticker = GUICtrlCreateButton("Sulje", 95, 75, 75, 25)
$idLabel_WarningSticker = GUICtrlCreateLabel("", 10, 55, 160, 21, $SS_CENTER)
GUISetState() ; GUI näkyviin
_FileWriteLog(@ScriptDir & "\log.log", "TarraAparaatti avattu.")

While 1 ; Pollataan käyttäjän interactionia
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $idButton_ExitSticker ; Sulje ikkuna ALT+F4:llä tai napista
                GUIDelete()
				_FileWriteLog(@ScriptDir & "\log.log", "TarraAparaatti suljettu.")
			    MainGUI()
			Case $idButton_Print ; Yritä käynnistää tulostus
				Local $nStickerAmount
				$nStickerAmount = GUICtrlRead($idInput_StickerAmount) ; "Raa'asta muuttujasta kypsä"
				Switch $nStickerAmount
				  Case 0 ; Matala luku -> ei mihinkään
					 GUICtrlSetColor ($idLabel_WarningSticker, $COLOR_RED)
					 GUICtrlSetData ($idLabel_WarningSticker, "Luvun tulee olla vähintään 1.")
					 GUICtrlSetState ($idInput_StickerAmount, $GUI_FOCUS)
				  Case 1 To 36 ; Korrekti luku -> päästä etiäppäin
					 GUIDelete()
					 ExitLoop
				  Case 37 To 99 ; Korkia luku -> ei mihinkään
					 GUICtrlSetColor ($idLabel_WarningSticker, $COLOR_RED)
					 GUICtrlSetData ($idLabel_WarningSticker, "Luku liian suuri.")
					 GUICtrlSetState ($idInput_StickerAmount, $GUI_FOCUS)
			    EndSwitch
        EndSwitch
WEnd
_FileWriteLog(@ScriptDir & "\log.log", "Käynnistetään tarrojen tulostus.")

If ProcessExists("masked.exe") Then ; Tarkista pyöriikö masked jo
   _FileWriteLog(@ScriptDir & "\log.log", "Havaittu masked:n olevan käynnissä.")
   Local $hGUI_TarraQuestion
   $hGUI_TarraQuestion = GUICreate("Kyssäri", 245, 80, Default, Default, $WS_POPUPWINDOW) ; Luo kyssäri-GUI
   GUICtrlCreateLabel("masked käynnissä. Pakotetaanko sulkeutuminen?", 10, 10, 225, Default, $SS_CENTER) ; Teksti piälle
   Local $idButton_maskedOK
   $idButton_maskedOK = GUICtrlCreateButton("OK", 40, 45, 75, 25) ; Ja napit
   Local $idButton_Cancel
   $idButton_Cancel = GUICtrlCreateButton("Peruuta", 120, 45, 75, 25)
   GUISetState() ; GUI näkyviin
   GUICtrlSetState ($idButton_maskedOK, $GUI_FOCUS)
   While 1 ; Oota confirmationia
	  Switch GUIGetMsg()
		 Case $GUI_EVENT_CLOSE, $idButton_Cancel ; Sulje ikkuna ALT+F4:llä tai napista
			GUIDelete()
			_FileWriteLog(@ScriptDir & "\log.log", "TarraAparaatti suljettu.")
			MainGUI()
		 Case $idButton_maskedOK
			WinClose("masked") ; Sulje masked
			GUIDelete()
			_FileWriteLog(@ScriptDir & "\log.log", "masked suljettu.")
			ExitLoop
	  EndSwitch
   WEnd
Else
   _FileWriteLog(@ScriptDir & "\log.log", "masked ei käynnissä.")
EndIf

ShellExecute("C:\masked.lnk")	; Käynnistä masked
Sleep(2700)	; Odota Splash
WinSetState ( "", "", @SW_MAXIMIZE )	; Maksimoi ikkuna -> Vakioi nappien sijainnit
Sleep(350)
_FileWriteLog(@ScriptDir & "\log.log", "masked käynnistetty.")

Local $nColor
$nColor= PixelGetColor(1620, 560)
If $nColor<> "65280" Then ; Tarkista erän olemassaolo masked:n laatikon väristä
   WinClose("masked") ; Sulje masked
   Local $hGUI_TarraWarning
   $hGUI_TarraWarning = GUICreate("Varotus", 90, 80, Default, Default, $WS_POPUPWINDOW) ; Luo varotus-GUI
   GUICtrlCreateLabel("Erää ei löytynyt.", 8, 10, 74, Default, $SS_CENTER) ; Teksti piälle
   Local $idButton_BatchOK
   $idButton_BatchOK = GUICtrlCreateButton("OK", 7, 45, 75, 25) ; Ja nappi
   GUISetState() ; GUI näkyviin
   _FileWriteLog(@ScriptDir & "\log.log", "Erää ei löytynyt. masked suljettu.")
   GUICtrlSetState ($idButton_BatchOK, $GUI_FOCUS)
   While 1 ; Oota confirmationia
	  Switch GUIGetMsg()
		 Case $GUI_EVENT_CLOSE, $idButton_BatchOK ; Sulje ikkuna ALT+F4:llä tai napista
			GUIDelete()
			_FileWriteLog(@ScriptDir & "\log.log", "TarraAparaatti suljettu.")
			MainGUI()
	  EndSwitch
   WEnd
Else
   _FileWriteLog(@ScriptDir & "\log.log", "Erä löytyi.")
EndIf

MouseClick($MOUSE_CLICK_PRIMARY, 1655, 560, 1, 3)	; "masked"
MouseClick($MOUSE_CLICK_PRIMARY, 1870, 160, 1, 3)	; "Erä"
Sleep(300) ; Debuggaus vaati
MouseClick($MOUSE_CLICK_PRIMARY, 150, 975, 1, 3)	; "Muokkaa" -Turha?
Sleep(1500)	; Anna miettiä
MouseClick($MOUSE_CLICK_PRIMARY, 150, 975, 1, 3)	; "Näyte"
Sleep(500)	; Anna ladata SQL
Send("{TAB 6}{F2}{CTRLDOWN}" & "c" & "{CTRLUP}") ; Kopioi nykynen näytemäärä
Local $nLap, $nLapThird, $aTulostetut[37], $nLapFor
$nLap = Number(ClipGet())
$nLapThird = $nLap
If $nLap <> 0 Then ; Alota kierrosluku nykyisestä näytemäärästä
   $nStickerAmount = $nStickerAmount + $nLap
   $nLap = $nLap + 1
Else
   $nLap = 1
   $nLapThird = 1
EndIf
_FileWriteLog(@ScriptDir & "\log.log", "Aloitetaan näytetarrojen kirjaaminen ja tulostaminen.")

Do	; Looppi alkaa
   MouseClick($MOUSE_CLICK_PRIMARY, 65, 975, 1, 3)	; "Lisää näyte"
   Send($nLap)	; Syötä juokseva luku
   MouseClick($MOUSE_CLICK_PRIMARY, 85, 810, 1, 5)	; "Säkkinäyte"
   Sleep(500)	; Just in case
   MouseClick($MOUSE_CLICK_PRIMARY, 510, 975, 1, 3)	; "Tulosta näyttarra"
   MouseClick($MOUSE_CLICK_PRIMARY, 715, 620, 1, 3)	; "Säkkinäyte"
   Sleep(50) ; SingleFours -workaround
   Send("{ENTER}")	; "Ok"
   Sleep(300)	; Just in case
   MouseClick($MOUSE_CLICK_PRIMARY, 510, 975, 1, 3)	; "Tulosta näyttarra"
   MouseClick($MOUSE_CLICK_PRIMARY, 715, 620, 1, 3)	; "Säkkinäyte"
   Sleep(400) ; DoubleDigits -tulosteworkaround -Aika pitkä?
   Send("{ENTER}")	; "Ok"


For $nLapFor = 2 To 35 Step 3  ; Ota arrayhyn ylös jokakolmannet  omat näytteet
   If $nLap = $nLapFor Then
	  $aTulostetut[$nLap] = 1
   EndIf
Next

   _FileWriteLog(@ScriptDir & "\log.log", "Näytetarra " & $nLap & " tulostettu.")
   $nLap = $nLap + 1 ; Korota juoksevaa lukua
   Sleep(500) ; Ei ilmeisesti pahitteeks
Until $nLap = $nStickerAmount + 1	; Looppi loppuu kunnes saavutetaan tarrojen lkm

_FileWriteLog(@ScriptDir & "\log.log", "masked:n tarra(t) tulostettu.")
WinClose("masked") ; Sulje masked
_FileWriteLog(@ScriptDir & "\log.log", "masked suljettu.")

Local $nLapOwn, $bDoWePrint
$bDoWePrint = False

For $Element In $aTulostetut
   If $Element = 1 Then $bDoWePrint = True ; Kato tulostetaanko jokakolmansia
Next

If $bDoWePrint = True Then ; Tulosta tarrat omiin jokakolmansiin
   _FileWriteLog(@ScriptDir & "\log.log", "Aloitetaan omien näytetarrojen tulostaminen.")
   Run("C:\masked.exe") ; Aja masked
   _FileWriteLog(@ScriptDir & "\log.log", "masked käynnistetty.")
   WinWait("masked") ; Oota masked
   Sleep(500) ; WinWait ei riitä (!)
   Send("{F6}") ; ControlFocus ei pelitä
   Send("http://masked.lua" & "{ENTER}") ; Mene masked:n komentosivulle
   Sleep(4600) ; Odota sivun lataus

   For $nLapOwn = $nLapThird + 1 To $nStickerAmount
	  If $aTulostetut[$nLapOwn] = 1 Then
		 Send("A250,20,0,5,1,1,N," & "{SHIFTDOWN}" & "2" & "{SHIFTUP}") ; Komento ja heittomerkki
		 Send("Sakki " & $nLapOwn) ; Säkkiteksti ja numero
		 Send("{SHIFTDOWN}" & "2" & "{SHIFTUP}" & "{ENTER}") ; Heittomerkki ja komento ineksiin
		 Sleep(2600) ; Odota sivun lataus -Aika tiukka
		 Send("A250,120,0,5,1,1,N," & "{SHIFTDOWN}" & "2" & "{SHIFTUP}") ; Komento ja heittomerkki
		 Send("Klo") ; Kelloteksti
		 Send("{SHIFTDOWN}" & "2" & "{SHIFTUP}" & "{ENTER}") ; Heittomerkki ja komento ineksiin
		 Sleep(2600) ; Odota sivun lataus
		 Send("P" & "{ENTER}") ; Printtaa ja komento ineksiin
		 Sleep(2600) ; Odota sivun lataus
		 _FileWriteLog(@ScriptDir & "\log.log", "Oma näytetarra " & $nLapOwn & " tulostettu.")
	  EndIf
   Next
   _FileWriteLog(@ScriptDir & "\log.log", "Omat tarrat tulostettu.")
   Send("{ALTDOWN}" & "{F4}" & "{ALTUP}") ; WinClose ei pelitä ja prosesseja useita
   _FileWriteLog(@ScriptDir & "\log.log", "masked suljettu.")
   _FileWriteLog(@ScriptDir & "\log.log", "Tarra(t) tulostettu.")
EndIf

MouseMove (1029, 518, 3) ; Liikuta hiiri valmiiksi Ok:n viereen
Local $hGUI_TarraDone
$hGUI_TarraDone = GUICreate("Valmis", 100, 80, Default, Default, $WS_POPUPWINDOW) ; Luo valmis-GUI
GUICtrlCreateLabel("Eräajo suoritettu.", 10, 10, 80, Default, $SS_CENTER) ; Teksti piälle
Local $idButton_EndOK
$idButton_EndOK = GUICtrlCreateButton("OK", 13, 45, 75, 25) ; Ja nappi
GUISetState() ; GUI näkyviin
GUICtrlSetState ($idButton_EndOK, $GUI_FOCUS)
While 1 ; Oota confirmationia
   Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE, $idButton_EndOK ; Sulje ikkuna ALT+F4:llä tai napista
		 GUIDelete()
		 _FileWriteLog(@ScriptDir & "\log.log", "TarraAparaatti suljettu.")
		 MainGUI()
   EndSwitch
WEnd

EndFunc

Func SackTimer() ; SäkkiAjastin

Local $hGUI_Timer
$hGUI_Timer = GUICreate("Ajastin", 230, 110, Default, Default, $WS_POPUPWINDOW) ; Luo ajastin-GUI
Local $idLabel_Question, $idInput_SackAmount, $idButton_Start, $idButton_ExitSack, $idLabel_WarningSack, $idLabel_Kg, _
$idCheckbox_Third

$idLabel_Question = GUICtrlCreateLabel("Paljonko säkissä on tällä hetkellä tavaraa?", 10, 10, 210, Default, $SS_CENTER) ; Teksti piälle
$nSackDefaultAmount = IniRead("settings.ini", "SäkkiAjastin", "SäkitTarjolla", "160")
$idInput_SackAmount = GUICtrlCreateInput($nSackDefaultAmount, 47, 30, 25, 20, $ES_NUMBER) ; Kysy säkissä olevan jauheen määrä raa'aks muuttujaks
GUICtrlSetLimit(-1, 3) ; Myöhän ei nelinumeroisia lukuja katella
$idLabel_Kg = GUICtrlCreateLabel("Kg", 72, 33, 15, Default, $SS_CENTER)
$idCheckbox_Third = GUICtrlCreateCheckbox("Kolmas säkki", 102, 29, Default, Default)
$idButton_Start = GUICtrlCreateButton("Käynnistä", 35, 75, 75, 25) ; Ja napit
$idButton_ExitSack = GUICtrlCreateButton("Sulje", 115, 75, 75, 25)
$idLabel_WarningSack = GUICtrlCreateLabel("", 10, 55, 210, 21, $SS_CENTER)
GUISetState() ; GUI näkyviin

_FileWriteLog(@ScriptDir & "\log.log", "SäkkiAjastin avattu.")

While 1 ; Pollataan käyttäjän interactionia
   Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE, $idButton_ExitSack ; Sulje ikkuna ALT+F4:llä tai napista
		 GUIDelete()
		 _FileWriteLog(@ScriptDir & "\log.log", "SäkkiAjastin suljettu.")
		 MainGUI()
	  Case $idButton_Start ; Käynnistä ajastin
			Local $nSackAmount
			$nSackAmount = GUICtrlRead($idInput_SackAmount); "Raa'asta muuttujasta kypsä"
			Switch $nSackAmount
			   Case 0 ; Matala luku -> ei mihinkään
				  GUICtrlSetColor ($idLabel_WarningSack, $COLOR_RED)
				  GUICtrlSetData ($idLabel_WarningSack, "Luvun tulee olla vähintään 1.")
				  GUICtrlSetState ($idInput_SackAmount, $GUI_FOCUS)
			   Case 1 To 807 ; Korrekti luku -> homma jatkuu
				  GUICtrlSetState ($idButton_Start, $GUI_DISABLE)
				  GUICtrlSetState ($idButton_ExitSack, $GUI_DISABLE)
				  GUICtrlSetColor ($idLabel_WarningSack, $COLOR_BLACK)
				  GUICtrlSetData ($idLabel_WarningSack, "Käynnistetään...")
				  Switch GUICtrlRead($idCheckbox_Third) ; Tarkista onko kolomas säkki
					 Case $GUI_CHECKED
						$nAlarmLimit = IniRead("settings.ini", "SäkkiAjastin", "Kolmosraja", "850")
					 Case $GUI_UNCHECKED
						$nAlarmLimit = IniRead("settings.ini", "SäkkiAjastin", "Normiraja", "900")
				  EndSwitch
					 For $i = 1 To 100 Step +2 ; Tsekkaa winukan voluumi
					 Send("{VOLUME_DOWN}")
					 Next
					 For $i = 1 To 70 Step +2
					 Send("{VOLUME_UP}")
					 Next
				  GUIDelete()
				  ExitLoop
			   Case 808 To 999 ; Korkia luku -> ei mihinkään
				  GUICtrlSetColor ($idLabel_WarningSack, $COLOR_RED)
				  GUICtrlSetData ($idLabel_WarningSack, "Luku liian suuri.")
				  GUICtrlSetState ($idInput_SackAmount, $GUI_FOCUS)
			   EndSwitch
	  EndSwitch
WEnd

$nSackAmount = $nSackAmount + 2 ; Reservi2kg

$vTimerGo = TimerInit() ; Kello käyntiin
Local $fSackAmountIncludingSeconds, $fSackAmountIncludingSecondsUnfloat, $nSackLeftUnfloat, $nMinutesGone, _
$nMinutesGoneUnfloat, $nMinutesLeftUnfloat, $vTimerGo, $fSeconds, $fTimerDiff

$eSackTime = IniRead("settings.ini", "SäkkiAjastin", "SäkkiAika", "37")

Local $hGUI_TimerGo
$hGUI_TimerGo = GUICreate("AjastinKäy", 230, 110, Default, Default, $WS_POPUPWINDOW) ; Luo ajastinkäy-GUI
Local $idButton_Reset, $idButton_CloseTimer, $idLabel_SackGone, $idLabel_SackLeft, $idLabel_KiloIndicator, _
$idLabel_MinuteIndicator, $idLabel_ETA, $idLabel_KilosGone, $idLabel_KilosLeft, $idLabel_MinutesGone, _
$idLabel_MinutesLeft, $idLabel_ETALeft, $aClockUnfloat, $aDateUnfloat, $bColorLoopDone, $bETADone, $bPopUpLoopDone, _
$bAlarmDone, $bLogLoopDone, $bBackgroundColorLoopDone, $fSackLeft, $fMinutesGone
$idButton_Reset = GUICtrlCreateButton("Nollaa", 35, 75, 75, 25) ; Ja **tullinen määrä tekstejä ja nappeja
$idButton_CloseTimer = GUICtrlCreateButton("Sulje", 115, 75, 75, 25)
$idLabel_SackGone = GUICtrlCreateLabel("Mennyt:", 20, 27, 38, Default, $SS_RIGHT) ; 38?
$idLabel_SackLeft = GUICtrlCreateLabel("Jälellä:", 20, 47, 38, Default, $SS_RIGHT)
$idLabel_KiloIndicator = GUICtrlCreateLabel("Kg", 81, 10)
$idLabel_MinuteIndicator = GUICtrlCreateLabel("Min", 125, 10)
$idLabel_ETA = GUICtrlCreateLabel("ETA", 170, 20)
$idLabel_KilosGone = GUICtrlCreateInput("", 73, 27, 30, 17, BitOR($SS_CENTER, $ES_READONLY))
$idLabel_KilosLeft = GUICtrlCreateInput("", 73, 47, 30, 17, BitOR($SS_CENTER, $ES_READONLY))
$idLabel_MinutesGone = GUICtrlCreateInput("", 123, 27, 20, 17, BitOR($SS_CENTER, $ES_READONLY))
$idLabel_MinutesLeft = GUICtrlCreateInput("", 123, 47, 20, 17, BitOR($SS_CENTER, $ES_READONLY))
$idLabel_ETALeft = GUICtrlCreateInput("", 163, 37, 37, 17, BitOR($SS_CENTER, $ES_READONLY))
GUISetState() ; GUI näkyviin
_FileWriteLog(@ScriptDir & "\log.log", "Säkkiajastin käynnissä.")

While 1 ; Pollataan käyttäjän interactionia
   If $fSackAmountIncludingSeconds < 1000 Then ; Pysäytä jos menee tonniin
   $fTimerDiff = TimerDiff($vTimerGo) ; Tee muutama calculaatio
   $fSeconds = $fTimerDiff/1000 ; Ei tonniykkönen koska ms->s
   $fSackAmountIncludingSeconds = $nSackAmount + $fSeconds*1000/60/$eSackTime ; Tarkka arvo jatkolaskuihin
   $fSackAmountIncludingSecondsUnfloat = Floor($fSackAmountIncludingSeconds) ; "Tarkka" arvo indikaattoriin
   $fSackLeft = 1000 - $fSackAmountIncludingSeconds ; Tarkka arvo jatkolaskuihin
   $nSackLeftUnfloat = Round($fSackLeft) ; "Tarkka" arvo indikaattoriin -Kuuluisko olla Floor myös?
   $fMinutesGone = $fSackAmountIncludingSeconds/1000*$eSackTime ; Tarkka arvo jatkolaskuihin
   $nMinutesGoneUnfloat =  Round($fMinutesGone) ; "Tarkka" arvo indikaattoriin
   $nMinutesLeftUnfloat = Round($eSackTime - $fMinutesGone) ; "Tarkka" arvo indikaattoriin
   $sETArawUnfloat = _DateAdd('n', $nMinutesLeftUnfloat, _NowCalc())
   _DateTimeSplit($sETArawUnfloat, $aDateUnfloat, $aClockUnfloat)
	  If $fSackAmountIncludingSecondsUnfloat == GUICtrlRead($idLabel_KilosGone) Then ; Päivitä indikaattorit on-demand (=AntiFlicker)
	  Else
		 GUICtrlSetData($idLabel_KilosGone,$fSackAmountIncludingSecondsUnfloat)
		 GUICtrlSetData($idLabel_KilosLeft,$nSackLeftUnfloat)
	  EndIf
	  If $nMinutesGoneUnfloat == GUICtrlRead($idLabel_MinutesGone) Then
	  Else
		 GUICtrlSetData($idLabel_MinutesGone,$nMinutesGoneUnfloat)
		 GUICtrlSetData($idLabel_MinutesLeft,$nMinutesLeftUnfloat)
		 If $bETADone = False Then
			GUICtrlSetData($idLabel_ETALeft,StringFormat("%02i", $aClockUnfloat[1]) & ":" & _
			StringFormat("%02i", $aClockUnfloat[2])	) ; StringFormatilla fixi nolla-alkusiin arvoihin
			$bETADone = True
		 EndIf
	  EndIf
	  If $fSackAmountIncludingSeconds > $nAlarmLimit Then ; Hälytoimenpiteet kun yli hälyrajan
		 If $bBackgroundColorLoopDone = False Then
			GUISetBkColor($COLOR_RED)
			$bBackgroundColorLoopDone = True
		 EndIf
		 If $bPopUpLoopDone = False Then ; PopUppaa jos tarve (huhhuh miten dirty hack)
			WinSetOnTop("AjastinKäy", "", $WINDOWS_ONTOP)
			Sleep(200) ; Auttasko click-missiin?
			WinSetOnTop("AjastinKäy", "", $WINDOWS_NOONTOP)
			WinActivate("AjastinKäy")
			$bPopUpLoopDone = True
		 EndIf
		 If $bAlarmDone = False Then
			_SoundPlay(@ScriptDir & "\beepboop.wav")
			$bAlarmDone = True
		 EndIf

		 ; Tähän väliin WinMove jos tarvis

		 If $bLogLoopDone = False Then
			_FileWriteLog(@ScriptDir & "\log.log", "Hälytys tehty.")
			$bLogLoopDone = True
		 EndIf
	  EndIf
   EndIf

   Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE, $idButton_CloseTimer ; Sulje ikkuna ALT+F4:llä tai napista
		 $bPopUpLoopDone = False
		 $bAlarmDone = False
		 $bColorLoopDone = False
		 $bETADone = False
		 $bLogLoopDone = False
		 $bBackgroundColorLoopDone = False
		 GUIDelete()
		 _FileWriteLog(@ScriptDir & "\log.log", "SäkkiAjastin suljettu.")
		 MainGUI()
	  Case $idButton_Reset
		 $bPopUpLoopDone = False
		 $bAlarmDone = False
		 $bColorLoopDone = False
		 $bETADone = False
		 $bLogLoopDone = False
		 $bBackgroundColorLoopDone = False
		 GUIDelete()
		 _FileWriteLog(@ScriptDir & "\log.log", "SäkkiAjastin resetoitu.")
		 SackTimer()
   EndSwitch
   Sleep(50) ; Mikä ois optimi laskentatehon kannalta? -Joutaa luultavasti nostaa
WEnd
EndFunc

Func PalletTag() ; LavaLappuLatoja

Local $hGUI_Pallet
$hGUI_Pallet = GUICreate("LavaLappuLatoja", 180, 110, Default, Default, $WS_POPUPWINDOW) ; Luo GUI
GUICtrlCreateLabel("Montako lavalappua tarvihet?", 10, 10, 160, Default, $SS_CENTER) ; Teksti piälle
Local $idInput_TagAmount, $idButton_PrintTag, $idButton_ExitTag, $idLabel_WarningTag
$nPalletDefaultAmount = IniRead("settings.ini", "LavaLappuLatoja", "LaputTarjolla", "3")
$idInput_TagAmount = GUICtrlCreateInput($nPalletDefaultAmount, 80, 30, 14, 20, $ES_NUMBER) ; Kysy lappujen lkm raa'aks muuttujaks
GUICtrlSetLimit(-1, 1) ; Myöhän ei kaksnumeroisia lukuja katella
$idButton_PrintTag = GUICtrlCreateButton("Tulosta", 10, 75, 75, 25) ; Ja napit
$idButton_ExitTag = GUICtrlCreateButton("Sulje", 95, 75, 75, 25)
$idLabel_WarningTag = GUICtrlCreateLabel("", 10, 55, 160, 21, $SS_CENTER)
GUISetState() ; GUI näkyviin
_FileWriteLog(@ScriptDir & "\log.log", "LavaLappuLatoja avattu.")

While 1 ; Pollataan käyttäjän interactionia
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $idButton_ExitTag ; Sulje ikkuna ALT+F4:llä tai napista
                GUIDelete()

				_FileWriteLog(@ScriptDir & "\log.log", "LavaLappuLatoja suljettu.")

			    MainGUI()
			Case $idButton_PrintTag ; Yritä käynnistää tulostus
				Local $nTagAmount
				$nTagAmount = GUICtrlRead($idInput_TagAmount) ; "Raa'asta muuttujasta kypsä"
				Switch $nTagAmount
				  Case 0 ; Matala luku -> ei mihinkään
					 GUICtrlSetColor ($idLabel_WarningTag, $COLOR_RED)
					 GUICtrlSetData ($idLabel_WarningTag, "Luvun tulee olla vähintään 1.")
					 GUICtrlSetState ($idInput_TagAmount, $GUI_FOCUS)
				  Case 1 To 6 ; Korrekti luku -> päästä etiäppäin
					 GUIDelete()
					 ExitLoop
				  Case 7 To 9 ; Korkia luku -> ei mihinkään
					 GUICtrlSetColor ($idLabel_WarningTag, $COLOR_RED)
					 GUICtrlSetData ($idLabel_WarningTag, "Luku liian suuri.")
					 GUICtrlSetState ($idInput_TagAmount, $GUI_FOCUS)
			    EndSwitch
        EndSwitch
WEnd
_FileWriteLog(@ScriptDir & "\log.log", "Käynnistetään lappujen tulostus.")

If ProcessExists("masked.exe") Then ; Tarkista pyöriikö masked jo
   _FileWriteLog(@ScriptDir & "\log.log", "Havaittu masked:n olevan käynnissä.")
   Local $hGUI_PalletQuestion
   $hGUI_PalletQuestion = GUICreate("Kyssäri", 245, 80, Default, Default, $WS_POPUPWINDOW) ; Luo kyssäri-GUI
   GUICtrlCreateLabel("masked käynnissä. Pakotetaanko sulkeutuminen?", 10, 10, 225, Default, $SS_CENTER) ; Teksti piälle
   Local $idButton_maskedOK
   $idButton_maskedOK = GUICtrlCreateButton("OK", 40, 45, 75, 25) ; Ja napit
   Local $idButton_maskedCancel
   $idButton_maskedCancel = GUICtrlCreateButton("Peruuta", 120, 45, 75, 25)
   GUISetState() ; GUI näkyviin
   GUICtrlSetState ($idButton_maskedOK, $GUI_FOCUS)
   While 1 ; Oota confirmationia
	  Switch GUIGetMsg()
		 Case $GUI_EVENT_CLOSE, $idButton_maskedCancel ; Sulje ikkuna ALT+F4:llä tai napista
			GUIDelete()
			MainGUI()
		 Case $idButton_maskedOK
			ProcessClose("masked.exe") ; Sulje masked
			GUIDelete()
			ExitLoop
	  EndSwitch
   WEnd
Else
   _FileWriteLog(@ScriptDir & "\log.log", "masked ei käynnissä.")
EndIf

Run("masked.exe") ; Käynnistä masked
Sleep(3500)
_FileWriteLog(@ScriptDir & "\log.log", "masked käynnistetty.")
Send("{ENTER}") ; Kirjaudu
Sleep(2600)
_FileWriteLog(@ScriptDir & "\log.log", "Kirjauduttu masked:iin.")
Send("masked")
Send("{ENTER}") ; Lavalappujen tulostus
Sleep(400)
WinSetState ( "", "", @SW_MAXIMIZE ) ; Maksimoi ikkuna -> Vakioi nappien sijainnit
_FileWriteLog(@ScriptDir & "\log.log", "Aloitetaan lavalappujen tulostaminen.")
Local $nLapTag
For $nLapTag = 1 To $nTagAmount ; Looppi alkaa
   Send("masked")
   Send("{ENTER}")
   Sleep(300)
   Send("{UP}{SHIFTDOWN}{RIGHT}{SHIFTUP}{CTRLDOWN}" & "c" & "{CTRLUP}")
   Local $nOneTwo = ClipGet()
	  Switch $nOneTwo ; Määritä klikataanko ylempää vai alempaa (=missä masked)
		 Case 1
			MouseClick($MOUSE_CLICK_PRIMARY, 67, 248, 1, 3)
		 Case 2
			MouseClick($MOUSE_CLICK_PRIMARY, 67, 269, 1, 3)
	  EndSwitch
   Send("{ENTER}")
   Sleep(400)
   Send("{TAB 6}" & "015" & "{TAB}" & "401" & "{TAB}" & "1000,000" & "{ENTER}") ; Täytä formit
   Sleep(500)
   Send("{SHIFTDOWN}{F1}{SHIFTUP}") ; Tulosta
   Sleep(4300)
   _FileWriteLog(@ScriptDir & "\log.log", "Lavalappu " & $nLapTag & " tulostettu.")
Next

WinClose("masked")
WinClose("masked")
_FileWriteLog(@ScriptDir & "\log.log", "masked suljettu.")
_FileWriteLog(@ScriptDir & "\log.log", "Laput tulostettu.")
MouseMove (1029, 518, 3) ; Liikuta hiiri valmiiksi Ok:n viereen
Local $hGUI_PalletDone
$hGUI_PalletDone = GUICreate("Valmis", 100, 80, Default, Default, $WS_POPUPWINDOW) ; Luo valmis-GUI
GUICtrlCreateLabel("Eräajo suoritettu.", 10, 10, 80, Default, $SS_CENTER) ; Teksti piälle
Local $idButton_TagEndOK
$idButton_TagEndOK = GUICtrlCreateButton("OK", 13, 45, 75, 25) ; Ja nappi
GUISetState() ; GUI näkyviin
GUICtrlSetState ($idButton_TagEndOK, $GUI_FOCUS)
While 1 ; Oota confirmationia
   Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE, $idButton_TagEndOK ; Sulje ikkuna ALT+F4:llä tai napista
		 GUIDelete()
		 _FileWriteLog(@ScriptDir & "\log.log", "LavaLappuLatoja suljettu.")
		 MainGUI()
   EndSwitch
WEnd

EndFunc

Func Settings() ; Asetukset

Local $hGUI_Settings
$hGUI_Settings = GUICreate("Asetukset", 280, 320, Default, Default, $WS_POPUPWINDOW) ; Luo GUI
Local $idInput_StickerAmountSetting, $idInput_SackTimeSetting, $idInput_AlarmLimitSetting, $idInput_ThirdLimitSetting, _
$idInput_SackDefaultSetting, $idInput_PalletSetting, $bDoWeSave, $nStickerAmountSetting, $nSackTimeSetting, _
$nAlarmLimitSetting, $nThirdLimitSetting, $nSackDefaultSetting, $nPalletSetting

$nStickerDefaultAmount = IniRead("settings.ini", "TarraAparaatti", "TarratTarjolla", "10") ; Inin luvut muuttujiks
$eSackTime = IniRead("settings.ini", "SäkkiAjastin", "SäkkiAika", "37")
$nAlarmLimit = IniRead("settings.ini", "SäkkiAjastin", "Normiraja", "900")
$nThirdAlarmLimit = IniRead("settings.ini", "SäkkiAjastin", "Kolmosraja", "850")
$nSackDefaultAmount = IniRead("settings.ini", "SäkkiAjastin", "SäkitTarjolla", "160")
$nPalletDefaultAmount = IniRead("settings.ini", "LavaLappuLatoja", "LaputTarjolla", "3")

$idGraphic_Separator = GUICtrlCreateGraphic(0,34) ; Ja separi
GUICtrlSetState(-1, $GUI_DISABLE) ; Separin vaatima graffataso ei-klikattavaks
GUICtrlCreateLabel("TarraAparaatti:", 10, 10) ; Ja tekstit
GUICtrlCreateLabel("Tulostettavien tarrojen oletusarvo:", 30, 35)
GUICtrlCreateLabel("Kpl", 232, 36)
$idInput_StickerAmountSetting = GUICtrlCreateInput($nStickerDefaultAmount, 194, 33, 35, 20, BitOR($ES_NUMBER,$ES_READONLY))
GUICtrlCreateUpdown($idInput_StickerAmountSetting)
GUICtrlSetLimit(-1, 36, 1)
GUICtrlSetGraphic($idGraphic_Separator, $GUI_GR_MOVE, -280, 29)
GUICtrlSetGraphic($idGraphic_Separator, $GUI_GR_LINE, 280, 29)
GUICtrlCreateLabel("SäkkiAjastin:", 10, 75)
GUICtrlCreateLabel("Säkin täyttymiseen menevä aika:", 30, 100)
GUICtrlCreateLabel("Min", 226, 101)
$idInput_SackTimeSetting = GUICtrlCreateInput($eSackTime, 188, 98, 35, 20, BitOR($ES_NUMBER,$ES_READONLY))
GUICtrlCreateUpdown($idInput_SackTimeSetting)
GUICtrlSetLimit(-1, 40, 35)
GUICtrlCreateLabel("Hälytysraja:", 30, 125)
GUICtrlCreateLabel("Kg", 131, 126)
$idInput_AlarmLimitSetting = GUICtrlCreateInput($nAlarmLimit, 88, 123, 40, 20, BitOR($ES_NUMBER,$ES_READONLY))
GUICtrlCreateUpdown($idInput_AlarmLimitSetting)
GUICtrlSetLimit(-1, 980, 860)
GUICtrlCreateLabel("Kolmannen säkin hälytysraja:", 30, 150)
GUICtrlCreateLabel("Kg", 213, 151)
$idInput_ThirdLimitSetting = GUICtrlCreateInput($nThirdAlarmLimit, 170, 148, 40, 20, BitOR($ES_NUMBER,$ES_READONLY))
GUICtrlCreateUpdown($idInput_ThirdLimitSetting)
GUICtrlSetLimit(-1, 980, 810)
GUICtrlCreateLabel("Ajastimen kilojen oletusarvo:", 30, 175)
GUICtrlCreateLabel("Kg", 210, 176)
$idInput_SackDefaultSetting = GUICtrlCreateInput($nSackDefaultAmount, 167, 173, 40, 20, BitOR($ES_NUMBER,$ES_READONLY))
GUICtrlCreateUpdown($idInput_SackDefaultSetting)
GUICtrlSetLimit(-1, 250, 90)
GUICtrlSetGraphic($idGraphic_Separator, $GUI_GR_MOVE, -280, 179)
GUICtrlSetGraphic($idGraphic_Separator, $GUI_GR_LINE, 280, 179)
GUICtrlCreateLabel("LavaLappuLatoja:", 10, 226)
GUICtrlCreateLabel("Tulostettavien lappujen oletusarvo:", 30, 251)
GUICtrlCreateLabel("Kpl", 228, 252)
$idInput_PalletSetting = GUICtrlCreateInput($nPalletDefaultAmount, 196, 249, 29, 20, BitOR($ES_NUMBER,$ES_READONLY))
GUICtrlCreateUpdown($idInput_PalletSetting)
GUICtrlSetLimit(-1, 6, 1)
$idButton_SettingsExit = GUICtrlCreateButton("Sulje", 100, 285, 75, 25) ; Ja napit

GUISetState() ; GUI näkyviin
_FileWriteLog(@ScriptDir & "\log.log", "Asetukset avattu.")

While 1 ; Pollataan käyttäjän interactionia
   Switch GUIGetMsg()
		 Case $GUI_EVENT_CLOSE, $idButton_SettingsExit ; Sulje ikkuna ALT+F4:llä
		 $nStickerAmountSetting = GUICtrlRead($idInput_StickerAmountSetting)
		 $nSackTimeSetting = GUICtrlRead($idInput_SackTimeSetting)
		 $nAlarmLimitSetting = GUICtrlRead($idInput_AlarmLimitSetting)
		 $nThirdLimitSetting = GUICtrlRead($idInput_ThirdLimitSetting)
		 $nSackDefaultSetting = GUICtrlRead($idInput_SackDefaultSetting)
		 $nPalletSetting = GUICtrlRead($idInput_PalletSetting)
		 If $nStickerAmountSetting <> $nStickerDefaultAmount Then $bDoWeSave = True ; Tarkista onko tallennettavaa
		 If $nSackTimeSetting <> $eSackTime Then $bDoWeSave = True
		 If $nAlarmLimitSetting <> $nAlarmLimit Then $bDoWeSave = True
		 If $nThirdLimitSetting <> $nThirdAlarmLimit Then $bDoWeSave = True
		 If $nSackDefaultSetting <> $nSackDefaultAmount Then $bDoWeSave = True
		 If $nPalletSetting <> $nPalletDefaultAmount Then $bDoWeSave = True
		 If $bDoWeSave = True Then ExitLoop
		 GUIDelete()
		 _FileWriteLog(@ScriptDir & "\log.log", "Asetukset suljettu.")
		 MainGUI()
   EndSwitch
WEnd

GUIDelete()
$bDoWeSave = False
Local $hGUI_DoWeSave
$hGUI_DoWeSave = GUICreate("Tallennetaanko", 170, 80, Default, Default, $WS_POPUPWINDOW) ; Luo tallennus-GUI
GUICtrlCreateLabel("Tallennetaanko muutokset?", 10, 10, 150, Default, $SS_CENTER) ; Teksti piälle
Local $idButton_SaveOK, $idButton_SaveNO
$idButton_SaveOK = GUICtrlCreateButton("Kyllä", 7, 45, 75, 25) ; Ja napit
$idButton_SaveNO = GUICtrlCreateButton("Ei", 87, 45, 75, 25)
GUISetState() ; GUI näkyviin
GUICtrlSetState ($idButton_SaveOK, $GUI_FOCUS)
While 1 ; Oota confirmationia
   Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE, $idButton_SaveNO ; Sulje ikkuna ALT+F4:llä tai napista
		 GUIDelete()
		 _FileWriteLog(@ScriptDir & "\log.log", "Asetukset suljettu.")
		 MainGUI()
	  Case $idButton_SaveOK
	  	 GUICtrlSetState ($idButton_SaveOK, $GUI_DISABLE)
		 GUICtrlSetState ($idButton_SaveNO, $GUI_DISABLE)
		 IniWrite("settings.ini", "TarraAparaatti", "TarratTarjolla", $nStickerAmountSetting) ; Tallenna asetukset
		 IniWrite("settings.ini", "SäkkiAjastin", "SäkkiAika", $nSackTimeSetting)
		 IniWrite("settings.ini", "SäkkiAjastin", "Normiraja", $nAlarmLimitSetting)
		 IniWrite("settings.ini", "SäkkiAjastin", "Kolmosraja", $nThirdLimitSetting)
		 IniWrite("settings.ini", "SäkkiAjastin", "SäkitTarjolla", $nSackDefaultSetting)
		 IniWrite("settings.ini", "LavaLappuLatoja", "LaputTarjolla", $nPalletSetting)
		 _FileWriteLog(@ScriptDir & "\log.log", "Asetukset tallennettu ja suljettu.")
		 GUIDelete()
		 MainGUI()
   EndSwitch
WEnd

EndFunc

Func Terminate() ; Hätäseis
    _SoundPlay(@ScriptDir & "\boopbeep.wav", $SOUND_WAIT)
    _FileWriteLog(@ScriptDir & "\log.log", "Hätä-seis painettu!")
    Exit
EndFunc
