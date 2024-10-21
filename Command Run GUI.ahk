;--------------------------------------------------------------------------
; Command Run GUI                                                         ;
;--------------------------------------------------------------------------

; When 'Alt + Q' is pressed, a gui to type in text will appear
; When you type in a predefined word/phrase and press enter, 
; it will run the associated string/command. Add at the bottom.

global CommandGui  ; Declare CommandGui as a global variable
   
Alt & Q::
  { 
    ShowCommandGui() 
       } ; Show Input GUI
  
     ShowCommandGui() {
      global CommandGui  ; Access the global CommandGui variable
    
    ; Destroy any existing GUI first
    ; Check if CommandGui is set and is an object before destroying 

	   if (IsSet(CommandGui) && IsObject(CommandGui)) {
        CommandGui.Destroy() 
		}
	   
	; Set GUI dimensions
	
       GuiWidth := 340  
       GuiHeight := 160  

    ; Create GUI
	
       CommandGui := Gui("+AlwaysOnTop -Caption +Border")
	     ; +AlwaysOnTop - Keeps the window above all other windows	  
         ; -SysMenu - Removes system menu. Prevents minimizing, maximizing, and closing	 
	     ; +ToolWindow - Creates tool window that does not appear in the taskbar
		 ; -Caption - Hides the title bar of the window
		 ; +Border - Adds a standard border to the GUI window
       CommandGui.SetFont("s16 bold", "Source Code Pro") ; Size 16, bold
       CommandGui.BackColor := "0x1C1C1C"  ; Dark Gray Background Color
	   
           InputYPos := (GuiHeight / 2) - 80  ; Y position (adjust this for centering)	   

    ; 'Title Text'
	
       CommandGui.Add("Text", "x0" " w" GuiWidth " Center c0xd8ccce", "Type Command")
	   
    ; Add 'Input Field' for typing commands
	
       CommandEdit := CommandGui.Add("Edit", "x20 y" (InputYPos + 53) " w300 h38 Center c0xdfdada vCommandEdit Background0x5f4548")
		 
    ; 'Help Text'
	
       CommandGui.Add("Text", "x0 y" (InputYPos + 110) " w" GuiWidth " Center c0x847d7e", "< ? for list >")
		 
    ; Add a hidden button to capture the Enter key event
	
       CommandButton := CommandGui.Add("Button", "x-999 y-999 Default")  ; Hidden button
	  
        ; Set event for button click (Enter key)
           CommandButton.OnEvent("Click", (*) => RunCommand(CommandEdit, CommandGui))
    
       CommandGui.Show("w" GuiWidth " h" GuiHeight) ; Show the GUI.
    
    ; Focus on the input field automatically
    CommandEdit.Focus()
	
	; When ESC is pressed, destroy the GUI
       CommandGui.OnEvent("Escape", DestroyGui)
	
	      DestroyGui(*) {
           CommandGui.Destroy()
        }
    }

;---------------------------;
; Defined Phrases/Commands ;
;---------------------------;

RunCommand(CommandEdit, CommandGui) {
    enteredText := CommandEdit.Value

    ; Match the entered text and run the corresponding commands
    switch enteredText {
		
        case "guiex": ; GUI Example
            CreateTestGui()  ; Call a function to create a new GUI
			CommandGui.Destroy() ; Destroy input gui
			
		; Commenting as I am not providing the gui	
        ; case "guiex 2": ; GUI Test 2
        ;    CreateTestGui2()  ; Testing diff type
		;	CommandGui.Destroy() ; Destroy input gui			
			
        case "calcex": ; Run Example
            Run("calc.exe")
			CommandGui.Destroy() ; Destroy input gui				
			
        ; default: ; to define what happens if unknown phrase/command entered. Currently does nothing.
        ;    FutureSomething()  ; No interuptions at all seems better atm. 
		
    }

    ; If to Destroy Input GUI after every action (command), not specific- 
	; -(by adding the destroy on every case. remove those if this is to be used)
    ; CommandGui.Destroy()
	
}


/* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* */
/* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* */

;----------------------------;
; Calls ; for Command Run GUI ;
;----------------------------;

CreateTestGui() {   
  ; Create GUI
     TestGUI := Gui("+AlwaysOnTop -Caption +Border")
     TestGUI.BackColor := "0x1C1C1C" ; Dark Gray Background Color

  ; Define GUI dimensions
     GuiWidth := 500
     GuiHeight := 300

  ; Title Text
     TestGUI.SetFont("s28 bold", "Source Code Pro")
	 TestGUI.Add("Text", "Center cWhite", "Hey, Testing o7")
     TestGUI.Add("Text", "Center cWhite", "010101010...")

  ; Show the window with defined width and height
     TestGUI.Show("w" GuiWidth " h" GuiHeight)
	 
  ; Close the GUI on Escape
    TestGUI.OnEvent("Escape", (*) => TestGUI.Destroy())

  }
