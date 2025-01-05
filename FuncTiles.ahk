#Requires AutoHotkey v2.0

class FuncTiles{
    Static instances := Map()
    buttonsPerRow := 5  ; Default value
    font_size := 14
    show_location := "Center"
    context_windows := []

    __New() {
        this.launchKey := "!RButton"  ; Default launch key
        this.buttonSize := "w300 h200"  ; Default button size
        this.functions := Map()  ; Map to store button descriptions and functions
        this.colors := Map()     ; Map to store colors for each function
        this.defaultColor := "0xffbe45"  ; Default green color
        this.instanceId := this.__Class . A_TickCount
        FuncTiles.instances[this.instanceId] := this
        this._bindHotkey()
    }

    set_context_windows(arr)
    {
       this.context_windows := Arr
    }

    setButtonsPerRow(count) {
        this.buttonsPerRow := count
    }

    set_coordinates(coordinates) {
        this.show_location := coordinates
    }

    setFont(size)
    {
        this.font_size := size
    }

    setLaunchKey(key) {

        if this.launchKey
        {
            try Hotkey(this.launchKey, (*) => "", "Off")
        }

        this.launchKey := key
        this._bindHotkey()
    }

    _bindHotkey() {
        if this.context_windows.Length > 0 {
            ; Create separate hotkey for each window context
            for win in this.context_windows {
                HotIfWinActive(win)    ;("ahk_class " win)  ; or "ahk_exe" depending on your needs
                try Hotkey(this.launchKey, (*) => this.launch())
            }
        } else {
            ; If no context windows specified, create global hotkey
            HotIf  ; Clear any context
            try Hotkey(this.launchKey, (*) => this.launch())
        }
        HotIf  ; Reset context back to default
    }
    
    setButtonSize(size) {
        this.buttonSize := size
    }

    setDefaultColor(color) {
        this.defaultColor := color
    }

    addFunction(description, func, color := "") {
        this.functions[description] := func
        this.colors[description] := color ? color : this.defaultColor
    }

    addFunctions(funcMap, colorMap := Map()) {
        for description, func in funcMap {
            color := colorMap.Has(description) ? colorMap[description] : this.defaultColor
            this.functions[description] := func
            this.colors[description] := color
        }
    }

    launch(*) {
        CoordMode("Mouse", "Screen")
        MouseGetPos(&x, &y)
    
        qgui := Gui("AlwaysOnTop -DPIScale +Owner -Caption +Border")
        qgui.BackColor := "0x363636"
        qgui.MarginX := qgui.MarginY := 20
        qgui.SetFont("norm s" this.font_size, "Segoe UI")
    
        ; Track last hovered control
        this.lastHovered := 0
        this.normalFontSize := this.font_size  ; Store normal font size
    
        widthMatch := RegExMatch(this.buttonSize, "w(\d+)", &width)
        heightMatch := RegExMatch(this.buttonSize, "h(\d+)", &height)
        buttonW := widthMatch ? width[1] : 300
        buttonH := heightMatch ? height[1] : buttonW

        this.btnww := buttonW
        this.btnhh := buttonH

        buttons := []
        currentRow := 0
        currentCol := 0
        totalButtons := this.functions.Count
        buttonsInCurrentRow := Min(totalButtons, this.buttonsPerRow)
    
        for description, func in this.functions {
            color := this.colors[description]
            
            if (currentCol = 0) {
                xOffset := (buttonsInCurrentRow < this.buttonsPerRow) ? 
                    Floor((this.buttonsPerRow - buttonsInCurrentRow) * (buttonW + 20) / 2) : 0
                opt := "x" xOffset + 20 " y" (currentRow = 0 ? "20" : "+20")
            } else {
                opt := "x+20 yp"
            }   
    
            opt .= " w" buttonW " h" buttonH " +BackgroundTrans"  ; +0x200"
            btn := qgui.Add("Text", opt, description)
            btn.SetFont("c" this._getContrastColor(color))
            btn.Opt("+Border Background" SubStr(color, 3))
            buttons.Push({ ctrl: btn, func: func, description: description })
    
            currentCol++
            if (currentCol = this.buttonsPerRow) {
                currentCol := 0
                currentRow++
                buttonsInCurrentRow := Min(totalButtons - currentRow * this.buttonsPerRow, this.buttonsPerRow)
            }
        }
    
        ; Set up hover check timer
        checkHover := this.CheckHover.Bind(this, buttons, qgui)
        SetTimer(checkHover, 50)   
    
        qgui.Show("AutoSize " this.show_location)
        
        if InStr(this.launchKey, "^")
            KeyWait("Ctrl")
        if InStr(this.launchKey, "!")
            KeyWait("Alt")
        if InStr(this.launchKey, "+")
            KeyWait("Shift")
        if InStr(this.launchKey, "#")
            KeyWait("Lwin")
    
        mainKey := RegExReplace(this.launchKey, "[\^\!\+\#]")
        KeyWait(mainKey)
    
        ; Stop the hover check timer
        SetTimer(checkHover, 0)
    
        MouseGetPos(,, &outWin, &outCtrl)
        
        hoveredCtrl := outCtrlHwnd := selectedFunc := ""
        try outCtrlHwnd := ControlGetHwnd(outCtrl, outWin)
        if outCtrlHwnd != ""
            try hoveredCtrl := GuiCtrlFromHwnd(outCtrlHwnd)
    
        if hoveredCtrl != ""
            for btn in buttons
                if btn.ctrl == hoveredCtrl {
                    selectedFunc := btn.func
                    break
                }
    
        qgui.Destroy()
    
        if selectedFunc != ""
            selectedFunc.Call()
    }
    
    ; Updated CheckHover method
    CheckHover(buttons, qgui, *) {
        MouseGetPos(&x, &y, &windowHwnd, &controlHwnd, "2")
        
        ; If mouse moved to a different control
        if (controlHwnd != this.lastHovered) {
            ; Reset previous hovered control if exists
            if (this.lastHovered) {
                for btn in buttons {
                    if (this.lastHovered = btn.ctrl.Hwnd) {
                        btn.ctrl.opt("-Redraw")
                        ; Reset font size
                        btn.ctrl.SetFont("s" this.normalFontSize)
                        btn.ctrl.Text := btn.description  ; Refresh text to prevent visual glitches
                        btn.ctrl.move(,,this.btnww, this.btnhh)
                        btn.ctrl.opt("+Redraw")
                        break
                    }
                }
            }
    
            ; Handle new hovered control
            for btn in buttons {
                if (controlHwnd = btn.ctrl.Hwnd) 
                {
                    btn.ctrl.opt("-Redraw")
                    btn.ctrl.Text := btn.description  ; Refresh text to prevent visual glitches
                    btn.ctrl.move(,,this.btnww + 5, this.btnhh + 5)                    ; pop tile
                    btn.ctrl.SetFont("s" this.normalFontSize + 5)                        ; Increase font size
                    btn.ctrl.opt("+Redraw")
                   SoundBeep(2000, 6)
                    break
                }
            }
    
            this.lastHovered := controlHwnd
        }
    }

    _getWidth() {
        ; Extract width from buttonSize or use default
        widthMatch := RegExMatch(this.buttonSize, "w(\d+)", &width)
        return widthMatch ? width[1] + 20 : 320  ; Add padding
    }

    _getContrastColor(bgColor) {
        ; Convert hex color to RGB
        r := Integer("0x" SubStr(bgColor, 3, 2))
        g := Integer("0x" SubStr(bgColor, 5, 2))
        b := Integer("0x" SubStr(bgColor, 7, 2))

        ; Calculate relative luminance
        luminance := (0.299 * r + 0.587 * g + 0.114 * b) / 255

        ; Return white for dark backgrounds, black for light backgrounds
        return luminance > 0.5 ? "000000" : "FFFFFF"
    }
}
