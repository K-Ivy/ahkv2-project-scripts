; ---------------------------------------------------
; Command Run GUI - v1.2
; By: IriKay (@TorrentIvy on Github)
; https://github.com/TorrentIvy/ahkv2-project-scripts
; ---------------------------------------------------
#Requires AutoHotkey v2.0
#SingleInstance Force

; Remove all default tray icons and add defined ones.

   A_TrayMenu.Delete
   A_TrayMenu.Add('Command Run Gui', (*) => ShowCommandGui()) 
   A_TrayMenu.Add('Open Script Folder', (*) => Run(A_ScriptDir))
   A_TrayMenu.Add('Edit Script', (*) => Edit())
   A_TrayMenu.Add('Reload', (*) => Reload())
   
   A_TrayMenu.Add('Exit', (*) => ExitApp())
   
;--------------------------------------------------------------------------
; Special Functions                                                       ;
;--------------------------------------------------------------------------

; Function to enable GUI dragging.
	
      EnableGuiDrag(hwnd) {
       ; Set up to capture left mouse button down (WM_LBUTTONDOWN = 0x0201)
      OnMessage(0x0201, (wParam, lParam, msg, hwnd) => StartDrag(hwnd))
     }

    ; Function to start dragging GUI.
	
    StartDrag(hwnd) {
     ; Send a message to make the window draggable
    DllCall("PostMessage", "Ptr", hwnd, "UInt", 0xA1, "Ptr", 2, "Ptr", 0)  ; 0xA1 is WM_NCLBUTTONDOWN, 2 is HTCAPTION
   }

 ; Function to create a "message box" GUI when called, with adjustable values defined in the call.
 ; -Define XPos and YPos to place GUI exactly where you want it to appear, define the message,
 ; -Assign the text color, font size, font, text YPos for centering, text area background color, 
 ; -Titlebar color, titlebar button/text color, define titlebar header text, header text color, header font size & font
 ; -Add Wait: Close after X Seconds, play defined sound when launched, 
 
 ; Will share when done. here and as a seperate post.
 
;--------------------------------------------------------------------------
; Command Run GUI                                                         ;
;--------------------------------------------------------------------------

; When "Alt + Q" is pressed or when opened by tray context menu item, a gui to input text will appear.
; When predefined word/phrase is typed, and enter is pressed, associated command(s) will run.
   
   Alt & Q:: { 
    ShowCommandGui() 
  }
  
    ShowCommandGui() {
    global CommandGui
    
    ; Destroy any existing GUI first
    ; Check if CommandGui is set and is an object before destroying 

	  if (IsSet(CommandGui) && IsObject(CommandGui)) {
      CommandGui.Destroy() 
	  }
	
      GuiWidth := 340  
      GuiHeight := 160  
      InputYPos := (GuiHeight / 2) - 80  ; Y position (adjust this for centering)

    ; Create GUI

      CommandGui := Gui("+AlwaysOnTop -Caption +Border")
	   ; +AlwaysOnTop - Keeps the window above all other windows	  	 
	   ; -Caption - Hides the title bar of the window
	   ; +Border - Adds a standard border to the GUI window
      CommandGui.SetFont("s16 bold", "Source Code Pro")
      CommandGui.BackColor := "0x1C1C1C"  ; Dark Gray Background Color	   
	  
      CommandGui.Add("Text", "x0" " w" GuiWidth " Center c0xd8ccce", "Type Command")
      CommandEdit := CommandGui.Add("Edit", "x20 y" (InputYPos + 53) " w300 h38 Center c0xdfdada vCommandEdit Background0x5f4548")
      CommandGui.Add("Text", "x0 y" (InputYPos + 110) " w" GuiWidth " Center c0x847d7e", "< ? for list >")
	  
	 ; Add hidden button to trigger search on Enter
	
      CommandButton := CommandGui.Add("Button", "x-999 y-999 Default") ; Add a hidden button to capture the Enter key event
      CommandButton.OnEvent("Click", (*) => RunCommand(CommandEdit, CommandGui)) ; Set event for button click (Enter key)
	   
    ; Show the GUI.
	
      CommandGui.Show("w" GuiWidth " h" GuiHeight) 
    
    ; Focus on the input field automatically
	
      CommandEdit.Focus()
	
	; Enable dragging the GUI
	
      EnableGuiDrag(CommandGui.Hwnd)
	
	; When ESC is pressed, destroy the GUI
	
      CommandGui.OnEvent("Escape", (*) => CommandGui.Destroy())
 }
	
;--------------------------------------------------------------------------
; Defined Phrases & Commands/Strings                                      ;
;--------------------------------------------------------------------------

   RunCommand(CommandEdit, CommandGui) {
	   
    ; Converts input to lowercase for case-insensitive comparison. So type however. The word(s) just has to match.
      enteredText := StrLower(CommandEdit.Value)  

    ; Match the entered text and run the corresponding commands.
    ; Possible to have as many diffrent alternatives for one command/string.
      switch enteredText {
	  
      case "r ", "reload", "reload script", "rld": ; As shown by "r ", empty spaces count for matching, so you can make quick alternatives.
        Reload() ; Reload this script when phrase entered.
       return 
	   
    ; The following allows to send searchs to your browser from this GUI. 
    ; When phrase entered, hides CommandGui and in the SAME position, brings up Web Search Gui.
    ; Type in your search and press enter. It will search with your default broswer. So ensure it's right in the bit further below code section	
    ; If you do not want the gui to be destoryed upon search, comment WebGui.Destroy() at end in PerformSearch function.	
    ; I'm using excessive shortcuts just for reference.		
			
		 ; Regular Search. 	
         case "s ", "search", "google", "g ", "web s", "web search": ; Empty spaces count!
           WebSearchGui(CommandGui, False, False) 
          return
			
		 ; Search in Incognito Mode.
         case "s i", "s incog", "search incog", "search incognito", "g i", "g incog", "google incognito", "w incog":
           WebSearchGui(CommandGui, True, False) 
          return
			
		 ; Regular Multi Search. Open query in the defined search engines, which equals the tab number. 
		 ; Currently 5 (so 5 diffrent tabs with same search). Change as you like within the function. 
         case "s m", "s multi", "search multi", "g m", "g multi", "google multi":
           WebSearchGui(CommandGui, False, True)
          return
		  
		 ; Multi Search in Incognito Mode. Open query in the defined search engines, which equals the tab number. 
		 ; Currently 5 (so 5 diffrent tabs with same search). Change as you like within the function.  
         case "s m i", "s m incog", "search multi incog", "g m i", "g m incog", "google multi incog":
           WebSearchGui(CommandGui, True, True)
          return	
	
    ; CustomMessageBox Example for when I share.	
	; Check the computer's total uptime.
    ;  case "uptime", "system uptime", "comp uptime":
    ;    Uptime := Round((A_TickCount / 1000) / 3600, 2) . " Hours"
    ;    CustomMsgBox(629, 249, "System Uptime: " . Uptime, "", 12, "Source Code Pro", 58, "", "", "", "SysCheck", "", "", "Source Code Pro", 9000, "C:\0 Static Asset Library\Sounds\coin.wav")
    ;   return
	   
	; Prevent computer from sleeping by sending key every defined number of seconds (60s atm)
	; Haven't checked if the key VKFF actually works for this. Change if not.
      case "noise on", "prevent sleep", "keep awake", "keep pc awake":
        StartNoise(True)
		  ; Use message box gui for a notice/Pin a small notice in the cornor of the screen. 
        CommandGui.Destroy()
       return

    ; Turn of key send and allow computer to sleep
	; Tray Icon is also created to turn of key send when key send is active and removed when not.	
      case "noise off", "stop noise", "allow sleep", "turn on sleep":
        StartNoise(False)
        CommandGui.Destroy()
       return	   
	  
    ; Open Chris' Win Util. Run Example for something you dont want on a keybind	
      case "winutil", "winutils":
        Run("C:\1 Maintenance & Utils\1 Software\WinUtil.lnk")
        CommandGui.Destroy()
       return			  		  
	  	  
    ; Run system check commands with powershell (Chkdsk, SFC, DISM):	 
      case "syscheck", "system check", "check system", "sscan":
        RunPowerShellCheck() 
        CommandGui.Destroy()
       return 	  

    ; Reset Network with powershell	 
      case "network reset":
        RunPowerShellNetworkReset()
        CommandGui.Destroy()
       return

    ; Run Specific Web Directly.
      case "github":
        Run("https://github.com")
        CommandGui.Destroy()
       return	
     }	      
   ; CommandGui.Destroy() ; If to Destroy Input GUI after every action. Use if dont want it specified in cases.
 }

;--------------------------------------------------------------------------
; Web Search Gui                                                          ;
;--------------------------------------------------------------------------

   WebSearchGui(lastGui, incognito, multi) {
   
    ; Get the last GUI’s position to place Web Gui
      WinGetPos &x, &y, , , lastGui.Hwnd
	  
	; Set GUI dimensions & Pos  
	
      GuiWidth := 340
      GuiHeight := 160
      SearchYPos := (GuiHeight / 2) - 80

    ; Create GUI
	
      WebGui := Gui("+AlwaysOnTop -Caption +Border")
      WebGui.SetFont("s16 bold", "Source Code Pro") 
      WebGui.BackColor := "0x1C1C1C"
      WebGui.Add("Text", "x0" " w" GuiWidth " Center c0xd8ccce", "Type Search") ; Title Text
      SearchEdit := WebGui.Add("Edit", "x20 y" (SearchYPos + 53) " w300 h38 Center c0xdfdada vCommandEdit Background0x5f4548") ; Input Field

    ; Hidden button to trigger search on Enter
	
      SearchButton := WebGui.Add("Button", "x-999 y-999 Default")
      SearchButton.OnEvent("Click", (*) => PerformSearch(SearchEdit.Value, incognito, multi)) 

    ; Text that acts as a "Button" to go back to the Command GUI. To avoid the whole hassle of colored buttons and libs.
	
      BackText := WebGui.Add("Text", "x0 y" (SearchYPos + 110) " w" GuiWidth " Center c0x847d7e", "-> Click to go Back <-")
      BackText.OnEvent("Click", BackToInput)

    ; Show Web GUI at the same position as Command GUI
	
      WebGui.Show("x" x " y" y " w" GuiWidth " h" GuiHeight)
	  
	; After Web GUI initilizes, HIDE Command Gui to prevent multiple guis when dragging and to prevent flickers.
	
      CommandGui.Hide()

    ; Focus on the search input field automatically
	
      SearchEdit.Focus()

    ; Go back to the Command GUI
	
      BackToInput(*) {	
        CommandGui.Show()
        Sleep 100
        WebGui.Destroy()
      }    

    ; Perform web search
      PerformSearch(query, incognito, multi) {
        if (query != "") {
		
            ; The main (regular) search URL. Replace if you want diffrent search engine
            url := "https://www.google.com/search?q=" . UriEncode(query)
            
            ; What search engines to use for multi-search. Replace with your choice of engines.
            searchEngines := [
                "https://www.google.com/search?q=",
                "https://www.bing.com/search?q=",
                "https://search.yahoo.com/search?p=",
                "https://www.duckduckgo.com/?q=",
                "https://www.ecosia.org/search?q="
            ]
            
            ; Check if multi-search is enabled
            if (multi) {
                ; If incognito mode is also enabled, run in incognito with defined browser.
                if (incognito) {
                    for _, base in searchEngines {
					    ; ADJUST PATH to YOUR Browser!!!
                        Run("C:\4 Applications and Port\Vivaldi\Application\vivaldi.exe --incognito " base . UriEncode(query))
                        Sleep 200
                    }
                } else {
                    ; Regular multi-search without incognito
                    for _, base in searchEngines {
                        Run(base . UriEncode(query))
                        Sleep 200
                    }
                }
            } else {
                ; Single search, regular or incognito
                if (incognito) {
				    ; ADJUST PATH to YOUR Browser!!!
                    Run("C:\4 Applications and Port\Vivaldi\Application\vivaldi.exe --incognito " url)
                } else {
                    Run(url)
                }
            }
           WebGui.Destroy() ; Comment this out if you dont want the GUI to destroy itself upon search.
        }
    }

    ; URL encoding function
    UriEncode(str) {
        static EncodingMap := Map(
            " ", "%20", "!", "%21", "#", "%23", "$", "%24",
            "&", "%26", "'", "%27", "(", "%28", ")", "%29",
            "*", "%2A", "+", "%2B", ",", "%2C", "-", "%2D",
            ".", "%2E", "/", "%2F", ":", "%3A", ";", "%3B",
            "=", "%3D", "?", "%3F", "@", "%40", "[", "%5B",
            "]", "%5D"
        )
        for key, value in EncodingMap {
            str := StrReplace(str, key, value)
        }
        return str
     }	
 }

;--------------------------------------------------------------------------
; Function to run system check with PowerShell                                                ;
;--------------------------------------------------------------------------
 
 ; Commands from Chris' Win Util
   RunPowerShellCheck() { 
    ; Checks for system corruption using Chkdsk, SFC, and DISM
	; ----------------------------------------------------------------------------------------------------------
    ;   1. "Chkdsk /Scan" - Runs online scan on the system drive, attempts to fix any corruption, 
	;                     and queues other corruption for fixing on reboot.
    ;   2. "(1) SFC /ScanNow" - Performs a scan of the system files and fixes any corruption,
	;                           and fixes DISM if it was corrupted.
    ;   3. "DISM /Online /Cleanup-Image /Restorehealth" - Fixes system image corruption, and fixes SFC's system 
	;                                                     image if it was corrupted.
    ;   > /Online - Fixes the currently running system image
    ;   > /Cleanup-Image - Performs cleanup operations on the image, could remove some unneeded temporary files
    ;   > /Restorehealth - Performs a scan of the image and fixes any corruption
	;
    ;   4. "(2) SFC /ScanNow" - Fixes system file corruption, this time with an almost guaranteed 
	;                           uncorrupted system image
	; ----------------------------------------------------------------------------------------------------------	
	
    command := "Write-Host '(1/4) Running Chkdsk' -ForegroundColor Green; "
            . "chkdsk /scan; "
            . "Write-Host '`n(2/4) Running SFC - First scan' -ForegroundColor Green; "
            . "sfc /scannow; "
            . "Write-Host '`n(3/4) Running DISM' -ForegroundColor Green; "
            . "DISM /Online /Cleanup-Image /RestoreHealth; "
            . "Write-Host '`n(4/4) Running SFC - Second scan' -ForegroundColor Green; "
            . "sfc /scannow; "
            . "Read-Host '`nPress Enter to continue'"

    ; Start PowerShell with administrative privileges
    Run("powershell -Command " command, "", "RunAs") 
 }

;--------------------------------------------------------------------------
; Function to reset network configurations                                            ;
;--------------------------------------------------------------------------
 
 ; Commands from Chris' Win Util
   RunPowerShellNetworkReset() {
   command := "Write-Host 'Resetting Network with netsh'; "
            . "Start-Process -NoNewWindow -FilePath 'netsh' -ArgumentList 'winsock', 'reset'; "
            . "Start-Process -NoNewWindow -FilePath 'netsh' -ArgumentList 'winhttp', 'reset', 'proxy'; "
            . "Start-Process -NoNewWindow -FilePath 'netsh' -ArgumentList 'int', 'ip', 'reset'; "
            . "Write-Host 'Process complete. Please reboot your computer.'; "
            . "$ButtonType = [System.Windows.MessageBoxButton]::OK; "
            . "$MessageboxTitle = 'Network Reset '; "
            . "$Messageboxbody = 'Stock settings loaded.`nPlease reboot your computer'; "
            . "$MessageIcon = [System.Windows.MessageBoxImage]::Information; "
            . "[System.Windows.MessageBox]::Show($Messageboxbody, $MessageboxTitle, $ButtonType, $MessageIcon); "
            . "Write-Host '=========================================='; "
            . "Write-Host '-- Network Configuration has been Reset --'; "
            . "Write-Host '=========================================='"

   ; Start PowerShell with administrative privileges
   Run("powershell -Command " command, "", "RunAs")
 }

;--------------------------------------------------------------------------
; Send key to prevent sleep                                               ;
;--------------------------------------------------------------------------

   SendNoise() {
    Send("{VKFF}")
  }

  ; Start or stop the noise and send tray value
    StartNoise(activate := True) {
    if activate {
        SetTimer(SendNoise, 60000) ; Send keystroke every 60 seconds
        NoiseTray(True)
    } else {
        SetTimer(SendNoise, 0) ; Stop the timer by setting interval to 0
        NoiseTray(False)
      }
   }

   NoiseTray(active) {
    if active {
       A_TrayMenu.Add("Let PC Sleep", (*) => StartNoise(False))
    } else
	   A_TrayMenu.Delete("Let PC Sleep")
 }

/* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* */
/* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* *//* */
