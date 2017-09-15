   If $bMaximizeLoopDone = False Then
	  WinMove("AjastinKäy", "", Default, Default, 460, 220)
   EndIf
   If $bColorLoopDone = False Then
	  GUICtrlSetColor($idLabel_KilosGone, $COLOR_RED)
	  GUICtrlSetColor($idLabel_KilosLeft, $COLOR_RED)
	  GUICtrlSetColor($idLabel_MinutesGone, $COLOR_RED)
	  GUICtrlSetColor($idLabel_MinutesLeft, $COLOR_RED)
	  GUICtrlSetColor($idLabel_ETALeft, $COLOR_RED)
	  $bColorLoopDone = True
   EndIf
   GUICtrlSetPos($idButton_Reset,
   GUICtrlSetPos($idButton_CloseTimer,
   GUICtrlSetPos($idLabel_SackGone,
   GUICtrlSetPos($idLabel_SackLeft,
   GUICtrlSetPos($idLabel_KiloIndicator,
   GUICtrlSetPos($idLabel_MinuteIndicator,
   GUICtrlSetPos($idLabel_ETA,
   GUICtrlSetPos($idLabel_KilosGone,
   GUICtrlSetPos($idLabel_KilosLeft,
   GUICtrlSetPos($idLabel_MinutesGone,
   GUICtrlSetPos($idLabel_MinutesLeft,
   GUICtrlSetPos($idLabel_ETALeft,