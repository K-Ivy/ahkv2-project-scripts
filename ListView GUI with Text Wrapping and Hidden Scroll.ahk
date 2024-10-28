#Requires AutoHotkey v2.0

Alt & W::ListWrapGUI()

  ListWrapGUI() {
    static ListDir  ; `ListDir` will retain its value across function calls.

    ; Destroy the existing GUI if it exists
      if (IsSet(ListDir) && IsObject(ListDir)) {
       ListDir.Destroy()
       ListDir := ""  ; Reset `ListDir` to clear the reference after destruction.
     }

    ; Set GUI dimensions. 
      GuiWidth := 530
      GuiHeight := 428
	  InputYPos := (GuiHeight / 2) - 80  ; Y position (adjust this for centering)
      ListDir := Gui("+AlwaysOnTop -Caption +Border")
       ; +AlwaysOnTop - Keeps the window above all other windows. 	 
	   ; -Caption - Hides the title bar of the window.
	   ; +Border - Adds a standard border to the GUI window.
      ListDir.BackColor := "0x1C1C1C" ; Background color of the "FAKE" Headers. Currently matching Dark Gray 
      ListDir.SetFont("s12", "Segoe UI")
	  
    ; Create "fake" text headers. Text is separate for positioning as otherwise, they aren't able to be adjusted.   
	
	  ; Dark Gray Background. Remove if you dont want.
	  ListDir.Add("Text", "x10 y10 w150 h30 Center Background0x333333", "") 
          ListDir.Add("Text", "x50 y13 Background0x333333 c0xFFFFFF", "Keybinds")
	  
	  ; Light Gray Background. Remove if you dont want .
      ListDir.Add("Text", "x157 y10 w363 h30 Center Background0x444444", "") 
          ListDir.Add("Text", "x295.5 y13 Background0x444444 c0xFFFFFF", "Descriptions")

    ; Add ListView with two columns.
      LV := ListDir.AddListView("-hdr x-2 y50 w1" GuiWidth " r15 Background1C1C1C c0x847d7e", ["", ""])	
       ; -hdr hides the column headers
       ; LV0x8000 disables sorting by clicking column headers. ("-hdr LV0x8000 x-2 y50 w1 GuiWidth ")
	     
    ; Set column widths
      KeybindsWidth := 150 
      DescriptionsWidth := 382 
      LV.ModifyCol(1, KeybindsWidth)  ; Apply width to the first column
      LV.ModifyCol(2, DescriptionsWidth)  ; Apply width to the second column

    ; Define keybinds and descriptions.
	
      Keybinds := [
        "Ctrl + A", "Ctrl + B", "Ctrl + C", "Ctrl + D", "Ctrl + E", "Ctrl + F",
        "Ctrl + G", "Ctrl + Shift + Esc", "Ctrl + Alt + I", "Ctrl + J + K", "Ctrl + L + Shift"
		
    ; Manual Centering Example
	;	"          Ctrl + A",
	;	"   Ctrl + Shift + Esc", 
	;	"          Ctrl + C", 
	;	"          Ctrl + D", 
	;	"       Ctrl + Alt + I", 
	;	"          Ctrl + F",
    ;   "          Ctrl + G", 
	;	"   Ctrl + Shift + Esc", 
    ;   "           Ctrl + G", 
	;	"        Ctrl + J + K", 
	;	"     Ctrl + L + Shift"
      ]     

      Descriptions := [
        "This is a very long description to test out the text wrapping functionality. It should wrap to the next line and continue pushing down the other rows accordingly.",
        "Example DSC: Copy the selected text or items to the clipboard.",
        "Example DSC: Paste the clipboard content into the current location.",
        "Example DSC: Cut the selected text or items and move them to the clipboard.",
        "Example DSC: Undo the last action performed.",
        "Example DSC: Redo the last undone action.",
        "This is a very long description to test out the text wrapping functionality. It should wrap to the next line and continue pushing down the other rows accordingly.",
        "Example DSC: Open Task Manager.",
        "Example DSC: Show the desktop.",
        "Example DSC: Lock the PC.",
        "This is a very long description to test out the text wrapping functionality. It should wrap to the next line and continue pushing down the other rows accordingly."
	  ]

    ; Set the MAXIMUM number of characters per line for descriptions for TEXT WRAPPING.
      MaxLength := 50  

    ; Add keybinds and descriptions to the ListView
	
      for index, keybind in Keybinds {
	    ; Call WrapText function to split long descriptions into multiple lines.
        WrappedLines := WrapText(Descriptions[index], MaxLength)
		
		; Split the text into separate lines.
        lines := StrSplit(WrappedLines, "`n")
        LV.Add("", keybind, lines[1]) 
        
        ; Add any additional lines of the description (wrapped text) as extra rows
        for i, line in lines {
            if (i > 1) {  ; Skip the first line since it was already added
                LV.Add("", "", line) 
            }
        }
    }
	
    ; Function to wrap text to specified width
	
      WrapText(text, maxWidth) {
        wrapped := ""
        words := StrSplit(text, " ")
        line := ""

        for word in words {
		    ; Check if adding this word would make the line too long
            if (StrLen(line) + StrLen(word) + 1 > maxWidth) {
                wrapped .= line "`n" ; Add the current line to wrapped text and start a new line
                line := word ; ; Start a new line with the current word
            } else {
                line .= (line ? " " : "") . word
            }
        }
        if (line != "") {
            wrapped .= line
        }
        return wrapped
    }	
	
    ; Show the GUI
      ListDir.Show("w" GuiWidth " h" GuiHeight)
    
    ; Close the GUI on when ESC is pressed
      ListDir.OnEvent("Escape", (*) => ListDir.Destroy())
    
    ; Add draggability to the gui. Hold left click on the "fake" header area and drag whereever.
      EnableGuiDrag(ListDir.Hwnd)
}

;--------------------------------------------------------------------------
; Special Function                                                        ;
;--------------------------------------------------------------------------

; Function to enable dragging.
  EnableGuiDrag(hwnd) {
    ; Set up to capture left mouse button down (WM_LBUTTONDOWN = 0x0201) on the GUI
    OnMessage(0x0201, (wParam, lParam, msg, msgHwnd) => HandleDrag(hwnd, lParam, msgHwnd))
  }

; Function to handle dragging based on mouse position within headers
  HandleDrag(hwnd, lParam, msgHwnd) {
    ; Only start dragging if the click is within the fake header area
    if (msgHwnd = hwnd) {
        mouseY := lParam >> 16
        if (mouseY < 50) {  ; Limit dragging to y-position of 50, covering fake headers
            StartDrag(hwnd)
        }
    }
}

; Function to start dragging the GUI
  StartDrag(hwnd) {
    ; Send a message to make the window draggable
    DllCall("PostMessage", "Ptr", hwnd, "UInt", 0xA1, "Ptr", 2, "Ptr", 0)  ; 0xA1 is WM_NCLBUTTONDOWN, 2 is HTCAPTION
}

;--------------------------------------------------------------------------
