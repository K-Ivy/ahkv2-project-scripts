; ---------------------------------------------------
; Listview GUI with Wrapping - V2
; By: IriKay (@TorrentIvy on Github)
; https://github.com/TorrentIvy/ahkv2-project-scripts
; ---------------------------------------------------
#Requires AutoHotkey v2.0

$Pause::ListWrapGUI()
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
       ; -hdr hides the column headers
	     
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

    ; Max number of characters per line 
    MaxLength := 50  

    for index, keybind in Keybinds {
        WrappedLines := WrapText(Descriptions[index], MaxLength)
		
        ; Split the text into separate lines.
        lines := StrSplit(WrappedLines, "`n")
        LV.Add("", keybind, lines[1]) 
        
        for i, line in lines {
            if (i > 1) {
                LV.Add("", "", line) 
            }
        }
    }
	
    WrapText(text, maxWidth) {
        wrapped := ""
        words := StrSplit(text, " ")
        line := ""

        for word in words {
            if (StrLen(line) + StrLen(word) + 1 > maxWidth) {
                wrapped .= line "`n" ; Add the current line to wrapped text and start a new line
                line := word ; Start a new line with the current word
            } else {
                line .= (line ? " " : "") . word
            }
        }
        if (line != "") {
            wrapped .= line
        }
        return wrapped
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
            WrappedLines := WrapText(Descriptions[index], MaxLength)
            lines := StrSplit(WrappedLines, "`n")
            LV.Add("", keybind, lines[1])
            for i, line in lines {
                if (i > 1)
                    LV.Add("", "", line)
                }
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
