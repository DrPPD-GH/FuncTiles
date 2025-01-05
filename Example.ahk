#Requires AutoHotkey v2.0
#Include FuncTiles.ahk

; Create a launcher instance  
mylauncher := FuncTiles()  

; Set button size (width x height)
mylauncher.buttonSize := "w200"  

; Optional - Adjust the font size of the text
mylauncher.setFont(20)  

; Optional - Set a custom default color for buttons (optional)
mylauncher.setDefaultColor("0x2196F3")  ; Blue

; Optional - Set a array of window titles for context sensitive launch hotkey
; It has to be set before you set the LauncKey
; mylauncher.set_context_windows(["Notepad", "Chrome"])


; Set a launch key.
; Only standard hotkeys with one key preceeded by one or more modifier are supported. [eg. ^!F2 or capslock or ^Rbutton] 
mylauncher.setLaunchKey("^RButton") 


; Optional - set coordinates where on the screen you want to show to tiles
; if left blank, it will be centred on the screen. 
; mylauncher.set_coordinates("x900 y100")


; now add some tiles to the instance.
; first parameter is descriptiion text to be displayed on the tile
; second parameter is function callback
; third parameter is tile color. eg - "0xffffff"
; The text color will be automatically decided depending on the tile color
; Tip - if needed - to centre the text vertically on the tile add "`n" before the text string like below

mylauncher.addFunction("`nNotepad", (*) => Run("notepad.exe"), "0xff2323") 
mylauncher.addFunction("`nCalculator", (*) => Run("calc.exe"), "0xff9b36")  
mylauncher.addFunction("`nBrowser", (*) => Run("chrome.exe"), "0xfcfc4b")   
mylauncher.addFunction("`nPaint", (*) => Run("mspaint.exe"), "0x3bff3b")    
mylauncher.addFunction("Task Manager", (*) => Run("taskmgr.exe"), "0xae23ff") 
mylauncher.addFunction("`nTest Tile", msgbox, "0x3834ff")  


; Set the number of Tiles per row
; Last row will be automatically centered if there are not enough tile in there.
; set parmeter 1 and it will look like a vertical toolbar
mylauncher.setButtonsPerRow(3)  


