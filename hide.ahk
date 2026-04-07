#Requires AutoHotkey v2.0

; ==============================
; 配置区域
; ==============================
shortcut := "^!e"                 ; 快捷键：Ctrl + Alt + E
targetExe := "Code.exe"           ; VS Code 进程名

; ==============================
; 全局状态变量
; ==============================
global isHidden := false        
global windowStates := Map()    

; ==============================
; 绑定快捷键
; ==============================
Hotkey(shortcut, ToggleAllVSCode)

; ==============================
; 主函数：切换隐藏/恢复
; ==============================
ToggleAllVSCode(*) {
    global isHidden, windowStates, targetExe

    winList := WinGetList("ahk_exe " targetExe)

    if (winList.Length = 0) {
        MsgBox "未找到 VS Code 窗口"
        return
    }

    if (!isHidden) {
        windowStates.Clear()

        vLeft   := DllCall("GetSystemMetrics", "Int", 76)
        vTop    := DllCall("GetSystemMetrics", "Int", 77)
        vWidth  := DllCall("GetSystemMetrics", "Int", 78)
        vHeight := DllCall("GetSystemMetrics", "Int", 79)

        for hwnd in winList {
            if !WinExist("ahk_id " hwnd)
                continue

            ; 【修复】使用输出参数方式获取窗口位置
            WinGetPos &x, &y, &w, &h, "ahk_id " hwnd
            
            ; 保存位置数据
            windowStates[hwnd] := { x: x, y: y, w: w, h: h }

            ; 移动到屏幕右侧外
            WinMove(vLeft + vWidth + 100, vTop + 100, , , "ahk_id " hwnd)
        }

        isHidden := true
    }
    else {
        for hwnd, pos in windowStates {
            if !WinExist("ahk_id " hwnd)
                continue

            ; 恢复窗口位置和大小
            WinMove(pos.x, pos.y, pos.w, pos.h, "ahk_id " hwnd)
        }

        windowStates.Clear()
        isHidden := false
    }
}