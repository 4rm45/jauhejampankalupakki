   If $nStickerAmount > 1 Then ; Tulosta tarrat omiin jokakolmansiin
	  _FileWriteLog(@ScriptDir & "\log.log", "Aloitetaan omien n‰ytetarrojen tulostaminen.")
	  Run("C:\masked.exe") ; Aja masked
	  _FileWriteLog(@ScriptDir & "\log.log", "masked k‰ynnistetty.")
	  WinWait("masked") ; Oota masked
	  Sleep(500) ; WinWait ei riit‰ (!)
	  Send("{F6}") ; ControlFocus ei pelit‰
	  Send("http://masked.lua" & "{ENTER}") ; Mene masked:n komentosivulle
	  Sleep(1800) ; Odota sivun lataus
	  _FileWriteLog(@ScriptDir & "\log.log", "Aloitetaan omien n‰ytetarrojen tulostaminen.")
	  Local $nLapOwn
	  For $nLapOwn = 2 To $nStickerAmount Step 3 ; Luuppaa kolmen stepeill‰ tarralkm:‰‰n saakka
		 Send("A250,20,0,5,1,1,N," & "{SHIFTDOWN}" & "2" & "{SHIFTUP}") ; Komento ja heittomerkki
		 Send("Sakki " & $nLapOwn) ; S‰kkiteksti ja numero
		 Send("{SHIFTDOWN}" & "2" & "{SHIFTUP}" & "{ENTER}") ; Heittomerkki ja komento ineksiin
		 Sleep(2500) ; Odota sivun lataus -Aika tiukka
		 Send("A250,120,0,5,1,1,N," & "{SHIFTDOWN}" & "2" & "{SHIFTUP}") ; Komento ja heittomerkki
		 Send("Klo") ; Kelloteksti
		 Send("{SHIFTDOWN}" & "2" & "{SHIFTUP}" & "{ENTER}") ; Heittomerkki ja komento ineksiin
		 Sleep(2500) ; Odota sivun lataus
		 Send("P" & "{ENTER}") ; Printtaa ja komento ineksiin
		 Sleep(2500) ; Odota sivun lataus
	  Next
	  Send("{ALTDOWN}" & "{F4}" & "{ALTUP}") ; WinClose ei pelit‰ ja prosesseja useita
	  _FileWriteLog(@ScriptDir & "\log.log", "masked suljettu.")
	  _FileWriteLog(@ScriptDir & "\log.log", "Tarra(t) tulostettu.")
   EndIf

   If $nLap = 2 Then
	  $aTulostetut[$nLap] = 1
   ElseIf $nLap = 5 Then
	  $aTulostetut[$nLap] = 1
   ElseIf $nLap = 8 Then
	  $aTulostetut[$nLap] = 1
   ElseIf $nLap = 11 Then
	  $aTulostetut[$nLap] = 1
   ElseIf $nLap = 14 Then
	  $aTulostetut[$nLap] = 1
   ElseIf $nLap = 17 Then
	  $aTulostetut[$nLap] = 1
   ElseIf $nLap = 20 Then
	  $aTulostetut[$nLap] = 1
   ElseIf $nLap = 23 Then
	  $aTulostetut[$nLap] = 1
   ElseIf $nLap = 26 Then
	  $aTulostetut[$nLap] = 1
   ElseIf $nLap = 29 Then
	  $aTulostetut[$nLap] = 1
   ElseIf $nLap = 32 Then
	  $aTulostetut[$nLap] = 1
   ElseIf $nLap = 35 Then
	  $aTulostetut[$nLap] = 1
   Else
   EndIf