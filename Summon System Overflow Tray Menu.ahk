#Requires AutoHotkey v2.0

; Constants
winTitle := "ahk_class NotifyIconOverflowWindow"
TrayXPos := 883
TrayYPos := 820
				 
; Hotkey to show and move the system tray menu
F1:: {
    ; Show and activate the system tray overflow menu
    WinShow(winTitle)
    WinActivate(winTitle)
    hwnd := WinGetID(winTitle)
    if !IsSet(hwnd) {
        MsgBox("System tray overflow menu could not be accessed.")
      return
    }

    ; Focus on the tray menu and move it
    ControlFocus("ToolbarWindow321", hwnd)
    if !MoveWindow(hwnd, TrayXPos, TrayYPos) {
        MsgBox("Failed to move the system tray overflow menu.")
    }
}

; Hotkey to close the system tray menu
Esc:: {
    try hwnd := WinGetID(winTitle)
	; Try attempts to get the hwnd
    ; If the window is not found, Catch returns, stopping AutoHotkey's own error window from triggering.
    catch {
       return
    }
    if !DllCall("ShowWindow", "Ptr", hwnd, "Int", 0) { ; 0 = SW_HIDE
        MsgBox("Failed to hide the system tray overflow menu.")
    }
}

; Function to move the tray menu using the Windows API
MoveWindow(hwnd, x, y) {
    rect := Buffer(16, 0)
    if !DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rect.Ptr)
        return false

    windowWidth := NumGet(rect, 8, "Int") - NumGet(rect, 0, "Int")
    windowHeight := NumGet(rect, 12, "Int") - NumGet(rect, 4, "Int")
    return DllCall("MoveWindow", "Ptr", hwnd, "Int", x, "Int", y, "Int", windowWidth, "Int", windowHeight, "Int", true) != 0
}

