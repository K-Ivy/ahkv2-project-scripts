; ---------------------------------------------------
; Better list wrapping method by @kczk3 on the forum + "@just me"
; Listview GUI with Wrapping - V2
; By: IriKay (@TorrentIvy on Github)
; https://github.com/TorrentIvy/ahkv2-project-scripts
; ---------------------------------------------------
#Requires AutoHotkey v2.0
#SingleInstance Force

ListWrapGUI()
  ListWrapGUI() {
    static ListDir
    ; Destroy previous GUI if present
    if (IsSet(ListDir) && IsObject(ListDir)) {
        ListDir.Destroy()
        ListDir := ""
    }

    GuiWidth := 530
    GuiHeight := 428

    ListDir := Gui("+AlwaysOnTop -Caption +Border")
      ; -Caption - Hides the title bar of the window.
      ; +Border - Adds a standard border to the GUI window.
    ListDir.BackColor := "0x303030"
    ListDir.SetFont("s13", "Segoe UI")
    ListDir.Add("Text", "x12 y14 Background0x303030 c0xbfa3a3", "SysUtil KeyBinds...")

    ListDir.Add("Text", "x366 y12 w152 h26 Background0xbfa3a3")
    SearchBox := ListDir.Add("Edit", "x367 y13 w150 h24 -E0x200 -Border Background0x383838 c0xbfa3a3", "")

    ListDir.SetFont("s12", "Segoe UI")
    ; Add ListView with two columns.
    LV := ListDir.AddListView("-hdr x-2 y50 w1" GuiWidth " r15 Background1C1C1C c0x847d7e", ["", ""])

    ; Set column widths
    KeybindsWidth := 150
    DescriptionsWidth := 382
    LV.ModifyCol(1, KeybindsWidth)
    LV.ModifyCol(2, DescriptionsWidth)

    ; Define keybinds and descriptions.
    Keybinds := [
        " Numpad 0",
		" Home",
		" End",
		" Insert",
		" Page Up",
		" Win + LButton",
        " Scrolllock",
		" Page Down",
		" Page Down + End",
		" Alt + MButton",
		" Volume Up",
        " .",
		" .",
		" .",
        " .",
		" .",
		" .",
        " .",
		" .",
		" .",
        " .",
		" .",
		" .",
		" ."
    ]

    Descriptions := [
        "Brings up the GameHUD",
        "Hides the titlebar of defined windows & moves them to a specified X & Y",
        "Runs exist check & kills defined processes",
        "Pins a window to be on top",
        "Minimizes focused window",
        "Drag while holding LButton to move any window   from any point within it",
        "Opens Windows Magnifer (Lens). Shift + Wheel Up/Down adjusts aoom level",
        "Block Keyboard Input (Does not affect Mouse)",
        "Re-enables Keyboard Input",
        "Kills all other scripts",
        "Kills Wallpaper Engine",
        " .",
		" .",
		" .",
        " .",
		" .",
		" .",
        " .",
		" .",
		" .",
        " .",
		" .",
		" .",
		"."
    ]

    lvFnt := SendMessage(0x0031, 0, 0, LV.Hwnd) ; WM_GETFONT = 0x0031
    lvHdc := DllCall("GetDC", "Ptr", LV.Hwnd)
    prevFnt := DllCall("SelectObject", "Ptr", lvHdc, "Ptr", lvFnt, "UInt")
    strRect := Buffer(16)
    NumPut("UInt", 0, strRect, 0) ; left
    NumPut("UInt", 0, strRect, 4) ; top
    NumPut("UInt", DescriptionsWidth, strRect, 8) ; right
    NumPut("UInt", 0, strRect, 12) ; bottom
    maxHeight := 0
    for descr in Descriptions {
        NumPut("UInt", DescriptionsWidth, strRect, 8) ; right
        maxHeight := Max(
            maxHeight,
            DllCall("DrawText", "Ptr", lvHdc, "Ptr", StrPtr(descr), "Int", -1, "Ptr", strRect, "UInt", 0x410) ; DT_WORDBREAK | DT_EDITCONTROL | DT_END_ELLIPSIS | DT_CALCRECT
        )
    }

    DllCall("SelectObject", "Ptr", lvHdc, "Ptr", prevFnt)
    DllCall("ReleaseDC", "Ptr", LV.Hwnd, "Ptr", lvHdc)

    hIL := IL_Create(10, 2, true)
    DllCall("Comctl32.dll\ImageList_SetIconSize", "Ptr", hIL, "Int", 0, "Int", maxHeight + 2)
    LV.SetImageList(hIL, 1)

    for index, keybind in Keybinds {
        LV.Add("", keybind, Descriptions[index])
    }

    FilterUList() {
        searchTerm := SearchBox.Text
        searchTerm := StrLower(searchTerm)  ; Convert search term to lowercase
        LV.Delete()  ; Clear all rows.
        for index, keybind in Keybinds {
            ; Convert both the keybind and description to lowercase
            keybindLower := StrLower(keybind)
            descriptionLower := StrLower(Descriptions[index])

            if (searchTerm = "" || InStr(keybindLower, searchTerm, true) || InStr(descriptionLower, searchTerm, true)) {
                LV.Add("", keybind, Descriptions[index])
            }
        }
    }

    SearchBox.OnEvent("Change", (*) => FilterUList())
    FilterUList()

    ListDir.Show("w" GuiWidth " h" GuiHeight)
    ListDir.OnEvent("Escape", (*) => ListDir.Destroy())

    ; Add draggability to the header
    EnableGuiDrag(ListDir.Hwnd)
}

EnableGuiDrag(hwnd) {
    ; Capture left mouse button down (WM_LBUTTONDOWN = 0x0201)
    OnMessage(0x0201, (wParam, lParam, msg, hwnd) => StartDrag(hwnd))
}

StartDrag(hwnd) {
    ; Send a message to make the window draggable
    DllCall("PostMessage", "Ptr", hwnd, "UInt", 0xA1, "Ptr", 2, "Ptr", 0)  ; 0xA1 is WM_NCLBUTTONDOWN, 2 is HTCAPTION
}