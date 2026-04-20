#Requires AutoHotkey v2.0

; ==============================
; 全局变量
; ==============================
global isHidden := false
global windowStates := Map()
global selectedExeList := []
global iniFile := A_ScriptDir "\config.ini"
global currentHotkey := ""
global windowExStyles := Map()

; ==============================
; 初始化
; ==============================
Init()
CreateGUI()
LoadConfig()
RefreshWindowList()
ApplyHotkey()

; ==============================
; 初始化函数
; ==============================
Init() {
    global iniFile

    if !FileExist(iniFile) {
        IniWrite("^!e", iniFile, "Settings", "Hotkey")
        IniWrite("", iniFile, "Settings", "Selected")
    }
}

; ==============================
; GUI
; ==============================
CreateGUI() {
    global mainGui, listView, hotkeyEdit

    mainGui := Gui("+Resize", "窗口工具by:af")

    ; 列表
    listView := mainGui.Add("ListView", "w500 h300 Multi", ["   进程名   ", " 窗口标题 "])

    ; 按钮
    mainGui.Add("Button", "x10 y+10 w100", "刷新窗口").OnEvent("Click", RefreshWindowList)
    mainGui.Add("Button", "x+10 w120", "hide").OnEvent("Click", HideSelected)
    mainGui.Add("Button", "x+10 w120", "unhide").OnEvent("Click", RestoreWindows)

    ; 快捷键设置
    mainGui.Add("Text", "x10 y+15", "快捷键(默认Ctrl+Alt+E):")
    hotkeyEdit := mainGui.Add("Edit", "x160 yp-3 w60")
    mainGui.Add("Button", "x+10 w100", "应用快捷键").OnEvent("Click", ApplyHotkeyFromUI)
    mainGui.Add("Text", "x10 y+15", "快捷键组合提示Ctrl = ^ Alt = ! Shift = + win = #  example: Shift+Alt+F = +!f ")

    mainGui.Show()
    
    ; 创建托盘菜单
    CreateTrayMenu()
}

; ==============================
; 创建托盘菜单
; ==============================
CreateTrayMenu() {
    global mainGui
    
    ; 清除现有菜单
    A_TrayMenu.Delete()
    
    ; 添加菜单项
    A_TrayMenu.Add("显示本工具", ShowWindowFromTray)
    A_TrayMenu.Add("退出", ExitHideGui)

}

; ==============================
; 从托盘显示窗口
; ==============================
ShowWindowFromTray(*) {
    global mainGui
    
    if mainGui {
        mainGui.Show()
        mainGui.Restore()
        WinActivate(mainGui.Hwnd)
    }
}

; ==============================
; 退出程序
; ==============================
ExitHideGui(*) {
    ExitApp()
}

; ==============================
; 隐藏任务栏图标
; ==============================
HideTaskbarIcon(hwnd) {
    global windowExStyles

    exStyle := WinGetExStyle("ahk_id " hwnd)
    windowExStyles[hwnd] := exStyle

    ; 移除 APPWINDOW，加上 TOOLWINDOW
    newStyle := (exStyle & ~0x00040000) | 0x00000080

    WinSetExStyle(newStyle, "ahk_id " hwnd)

    ; 强制刷新
    ;WinHide("ahk_id " hwnd)
    ;WinShow("ahk_id " hwnd)
}

; ==============================
; 恢复任务栏图标
; ==============================
RestoreTaskbarIcon(hwnd) {
    global windowExStyles

    if !windowExStyles.Has(hwnd)
        return

    WinSetExStyle(windowExStyles[hwnd], "ahk_id " hwnd)

    ; 强制刷新
    ;WinHide("ahk_id " hwnd)
    ;WinShow("ahk_id " hwnd)
}
; ==============================
; 刷新窗口列表
; ==============================
RefreshWindowList(*) {
    global listView

    listView.Delete()

    winList := WinGetList()

    for hwnd in winList {
        try {
            title := WinGetTitle("ahk_id " hwnd)
            exe := WinGetProcessName("ahk_id " hwnd)

            if (title != "") {
                listView.Add("", exe, title)
            }
        }
    }
}

; ==============================
; 获取选中窗口
; ==============================
GetSelectedWindows() {
    global listView

    selected := []
    row := 0

    while (row := listView.GetNext(row)) {
        exe := listView.GetText(row, 1)  ; 只获取进程名
        
        ; 简单直接：获取该进程的所有窗口
        for hwnd in WinGetList("ahk_exe " exe) {
            selected.Push(hwnd)  ; 添加所有窗口，不需要标题匹配
        }
    }

    return selected
}

; ==============================
; 隐藏窗口
; ==============================
HideSelected(*) {
    global isHidden, windowStates

    winList := GetSelectedWindows()

    if (winList.Length = 0) {
        MsgBox "请先选择窗口"
        return
    }

    windowStates.Clear()

    vLeft   := DllCall("GetSystemMetrics", "Int", 76)
    vTop    := DllCall("GetSystemMetrics", "Int", 77)
    vWidth  := DllCall("GetSystemMetrics", "Int", 78)
    vHeight := DllCall("GetSystemMetrics", "Int", 79)

    for hwnd in winList {
        if !WinExist("ahk_id " hwnd)
            continue

        WinGetPos &x, &y, &w, &h, "ahk_id " hwnd
        windowStates[hwnd] := { x: x, y: y, w: w, h: h }

        HideTaskbarIcon(hwnd)

        WinMove(vLeft + vWidth + 100, vTop + 100, , , "ahk_id " hwnd)
    }

    isHidden := true
}

; ==============================
; 恢复窗口
; ==============================
RestoreWindows(*) {
    global isHidden, windowStates

    for hwnd, pos in windowStates {
        if !WinExist("ahk_id " hwnd)
            continue

        RestoreTaskbarIcon(hwnd)   ; ⭐ 新增这一行

        WinMove(pos.x, pos.y, pos.w, pos.h, "ahk_id " hwnd)
    }

    windowStates.Clear()
    isHidden := false
}

; ==============================
; 应用快捷键（UI）
; ==============================
ApplyHotkeyFromUI(*) {
    global hotkeyEdit, iniFile

    key := hotkeyEdit.Value

    if (key = "") {
        MsgBox "请输入快捷键"
        return
    }

    IniWrite(key, iniFile, "Settings", "Hotkey")
    ApplyHotkey()

    MsgBox "快捷键已更新: " key
}

; ==============================
; 应用快捷键（核心）
; ==============================
ApplyHotkey() {
    global currentHotkey, iniFile

    newKey := IniRead(iniFile, "Settings", "Hotkey", "^!e")

    try {
        if (currentHotkey != "")
            Hotkey(currentHotkey, ToggleAll, "Off")
    }

    Hotkey(newKey, ToggleAll)

    currentHotkey := newKey
}

; ==============================
; 快捷键触发
; ==============================
ToggleAll(*) {
    global isHidden

    if (!isHidden)
        HideSelected()
    else
        RestoreWindows()
}

; ==============================
; 加载配置
; ==============================
LoadConfig() {
    global iniFile, hotkeyEdit

    key := IniRead(iniFile, "Settings", "Hotkey", "^!e")
    hotkeyEdit.Value := key
}