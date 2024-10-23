#Requires AutoHotkey v2.0
#SingleInstance Force
;--------------------------------------------------------------------------
; Command Run GUI                                                         ;
;--------------------------------------------------------------------------

; When 'Alt + Q' is pressed, a gui to type in text will appear
; When you type in a predefined word/phrase and press enter, 
; it will run the associated command(s). Add at the bottom.

global CommandGui  ; Declare CommandGui as a global variable
   
Alt & Q::
  { 
    ShowCommandGui() 
       }
  
     ShowCommandGui() {
      global CommandGui 
    
    ; Destroy any existing GUI first
    ; Check if CommandGui is set and is an object before destroying 

	   if (IsSet(CommandGui) && IsObject(CommandGui)) {
        CommandGui.Destroy() 
	   }
	   
	; GUI dimensions
	
       GuiWidth := 340  
       GuiHeight := 160  

    ; Create GUI
	
       CommandGui := Gui("+AlwaysOnTop -Caption +Border")
	     ; +AlwaysOnTop - Keeps the window above all other windows	  
		 ; -Caption - Hides the title bar of the window
		 ; +Border - Adds a standard border to the GUI window
       CommandGui.SetFont("s16 bold", "Source Code Pro") ; Size 16, bold
       CommandGui.BackColor := "0x1C1C1C"  ; Dark Gray Background Color
	   
           InputYPos := (GuiHeight / 2) - 80

    ; 'Title Text'
	
       CommandGui.Add("Text", "x0" " w" GuiWidth " Center c0xd8ccce", "Type Command")
	   
    ; Add 'Input Field' for typing in phrases
	
       CommandEdit := CommandGui.Add("Edit", "x20 y" (InputYPos + 53) " w300 h38 Center c0xdfdada vCommandEdit Background0x5f4548")
		 
    ; 'Help Text'
	
       CommandGui.Add("Text", "x0 y" (InputYPos + 110) " w" GuiWidth " Center c0x847d7e", "< ? for list >")
		 
    ; Add a hidden button to capture the Enter key event
	
       CommandButton := CommandGui.Add("Button", "x-999 y-999 Default") 
	  
        ; Set event for button click (Enter key)
           CommandButton.OnEvent("Click", (*) => RunCommand(CommandEdit, CommandGui))
    
       CommandGui.Show("w" GuiWidth " h" GuiHeight) ; Show the GUI.
    
    ; Focus on the input field automatically
       CommandEdit.Focus()
	
	; Enable dragging the GUI
       EnableGuiDrag(CommandGui.Hwnd)
	
	; When ESC is pressed, destroy the GUI
       CommandGui.OnEvent("Escape", DestroyGui)
  }
	
	; Gui Destroy 
	   DestroyGui(*) {
       CommandGui.Destroy()
    }
	   
    ; Function to enable dragging the GUI
       EnableGuiDrag(hwnd) {
       ; Set up to capture left mouse button down (WM_LBUTTONDOWN = 0x0201)
       OnMessage(0x0201, (wParam, lParam, msg, hwnd) => StartDrag(hwnd))
    }

    ; Function to start dragging the GUI
       StartDrag(hwnd) {
       ; Send a message to make the window draggable
       DllCall("PostMessage", "Ptr", hwnd, "UInt", 0xA1, "Ptr", 2, "Ptr", 0)  ; 0xA1 is WM_NCLBUTTONDOWN, 2 is HTCAPTION
    }
	
;---------------------------;
; Defined Phrases ;
;---------------------------;

RunCommand(CommandEdit, CommandGui) {
    enteredText := CommandEdit.Value

    ; Match the entered text and run the corresponding commands
    switch enteredText {
			
        ; case "?": ; Command Keybinds Help/List
        ; CommandRunBindHelp()		

        ; case "guiex": ; GUI Test 1
        ; CreateTestGui()  ; Calling a function
	; CommandGui.Destroy() ; Destroy input gui
			
        case "calc":
        Run("calc.exe")
	CommandGui.Destroy()		
			
        ; default: ; If to do something if an unknown phrase is entered. Currently does nothing.
        ;   FutureSomething[]  ; No interuptions/popups at all seems better atm. 
		
    }
	
    ; CommandGui.Destroy() ; If to Destroy Input GUI after every action. Use if dont want it specified in cases.
	
}

/* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* */
/* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* */
