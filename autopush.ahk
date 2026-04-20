#Requires AutoHotkey v2.0

; =========================
; 请求管理员权限（编译后EXE默认以管理员运行）
; =========================
if !A_IsAdmin {
    try {
        Run '*RunAs "' A_AhkPath '" "' A_ScriptFullPath '"'
    } catch {
        MsgBox "需要管理员权限才能运行此脚本", "权限不足", "Icon!"
    }
    ExitApp
}

; =========================
; 全局状态
; =========================
global running1 := false
global running2 := false
global running3 := false

global interval1 := 1000
global interval2 := 1000
global interval3 := 1000

global currentHotkey := "F5"  ; 默认快捷键（避免与 Hotkey 函数冲突）

; 目标窗口设置
global targetWindow := "流放之路"  ; 默认目标窗口

; =========================
; 模块1：一键喝药功能全局变量
; =========================
global potionEnabled := false      ; 功能是否启用
global potionKey1 := true          ; 数字键1是否启用
global potionKey2 := true          ; 数字键2是否启用
global potionKey3 := true          ; 数字键3是否启用
global potionKey4 := true          ; 数字键4是否启用
global potionKey5 := true          ; 数字键5是否启用

; =========================
; 模块2：鼠标连点功能全局变量
; =========================
global clickerEnabled := false     ; 功能是否启用
global clickerButton := "LButton"  ; 默认连点左键（LButton或RButton）
global clickerRunning := false     ; 连点是否正在运行
global clickerInterval := 100      ; 连点间隔100毫秒

; =========================
; 可选键列表（AHK v2 支持的所有按键）
; =========================
keyList := [
    "",  ; 空选项，允许用户取消选择
    ; 字母
    "A","B","C","D","E","F","G","H","I","J","K","L","M",
    "N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    ; 数字
    "0","1","2","3","4","5","6","7","8","9",
    ; 符号键
    "``","-","=","[","]","\\",";","'",",",".","/",
    ; "Numpad0","Numpad1","Numpad2","Numpad3","Numpad4",
    ; "Numpad5","Numpad6","Numpad7","Numpad8","Numpad9",
    ; "NumpadDot","NumpadDiv","NumpadMult","NumpadAdd","NumpadSub","NumpadEnter",
    ; "NumpadIns","NumpadEnd","NumpadDown","NumpadPgDn","NumpadLeft","NumpadClear",
    ; "NumpadRight","NumpadHome","NumpadUp","NumpadPgUp","NumpadDel",
    ; F键
    ; "F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
    ; "F13","F14","F15","F16","F17","F18","F19","F20","F21","F22","F23","F24",
    ; 功能键
    "Space","Enter","Return","Tab","Esc","Backspace",
    ; "Escape","BS","Delete","Del",
    ; "Insert","Ins","Home","End","PgUp","PgDn","Up","Down","Left","Right",
    ; 修饰键
    "LShift","RShift","Shift","LCtrl","RCtrl","Ctrl","LAlt","RAlt","Alt",
    ; "LWin","RWin","Win","AppsKey",
    ; 多媒体键
    ; "Browser_Back","Browser_Forward","Browser_Refresh","Browser_Stop",
    ; "Browser_Search","Browser_Favorites","Browser_Home",
    ; "Volume_Mute","Volume_Down","Volume_Up","Media_Next","Media_Prev",
    ; "Media_Stop","Media_Play_Pause","Launch_Mail","Launch_Media","Launch_App1","Launch_App2",
    ; 鼠标按钮
    ; "LButton","RButton","MButton","XButton1","XButton2",
    ; "WheelUp","WheelDown","WheelLeft","WheelRight"
]

; 快捷键列表
hotkeyList := [
    "F4","F5","F6","F7","F8","F9","F10",
    "Q","W","E","R","T","Y","D","F",
    "Tab","LShift","LCtrl","LAlt","CapsLock"
]

; =========================
; GUI 创建
; =========================
mainGui := Gui("", "多功能按键.by：tianxian")
mainGui.SetFont("s10", "Microsoft YaHei")

; -------- 快捷键设置 --------
mainGui.AddGroupBox("w420 h80", "快捷键设置（仅对循环按键生效）")
mainGui.AddText("x20 y30", "启动/停止快捷键：")
hotkeyDDL := mainGui.AddDropDownList("x160 y28 w100", hotkeyList)
hotkeyDDL.Value := 2 ; 默认 F5
setHotkeyBtn := mainGui.AddButton("x280 y28 w100", "应用快捷键")
setHotkeyBtn.OnEvent("Click", SetHotkey)

; -------- 状态显示 --------
statusText := mainGui.AddText("x20 y95 w400", "状态：未启动")

; -------- 窗口选择 --------
mainGui.AddGroupBox("x10 y120 w420 h200", "目标窗口（默认在流放之路窗口生效，留空=所有窗口）")
windowEdit := mainGui.AddEdit("x20 y145 w300", "流放之路")
windowEdit.OnEvent("Change", UpdateTargetWindow)
refreshWinBtn := mainGui.AddButton("x330 y145 w90", "刷新列表")
refreshWinBtn.OnEvent("Click", RefreshWindowList)
windowList := mainGui.AddListView("x20 y175 w400 h130", ["窗口标题", "进程名"])
windowList.ModifyCol(1, 250)
windowList.ModifyCol(2, 130)
windowList.OnEvent("DoubleClick", SelectWindow)

; =========================
; 按键区域 - 使用统一布局
; =========================
mainGui.AddGroupBox("x10 y330 w420 h140", "循环按键（选择技能或者酊剂按键，按上面快捷键启用停止）")

; -------- 按键1 --------
mainGui.AddText("x20 y355 w60", "按键1：")
ddl1 := mainGui.AddDropDownList("x80 y353 w100", keyList)
mainGui.AddText("x190 y355", "间隔")
int1 := mainGui.AddEdit("x230 y353 w60 Number", "1000")  ; Number选项限制只能输入数字
mainGui.AddText("x295 y355", "毫秒")

; -------- 按键2 --------
mainGui.AddText("x20 y395 w60", "按键2：")
ddl2a := mainGui.AddDropDownList("x80 y393 w100", keyList)
mainGui.AddText("x190 y395", "间隔")
int2 := mainGui.AddEdit("x230 y393 w60 Number", "1000")  ; Number选项限制只能输入数字
mainGui.AddText("x295 y395", "毫秒")

; -------- 按键3 --------
mainGui.AddText("x20 y435 w60", "按键3：")
ddl3a := mainGui.AddDropDownList("x80 y433 w100", keyList)
mainGui.AddText("x190 y435", "间隔")
int3 := mainGui.AddEdit("x230 y433 w60 Number", "1000")  ; Number选项限制只能输入数字
mainGui.AddText("x295 y435", "毫秒")

; 提示文字
mainGui.AddText("x20 y310 w400 cff4343", "提示：如需其他窗口生效，请在列表选择对应窗口双击")

; =========================
; 模块1：一键喝药功能
; =========================
; 功能说明：按下`键（反引号）时，同时发送选中的数字键（1-5）
; 适用于需要快速使用多个物品栏位的游戏场景
mainGui.AddGroupBox("x10 y480 w420 h100", "一键喝药（按 ~ 键触发）")

; 功能启用复选框
potionEnableCB := mainGui.AddCheckbox("x20 y505 vPotionEnabled", "启用一键喝药")
potionEnableCB.OnEvent("Click", TogglePotion)

; 五个数字键的复选框，横向排列
mainGui.AddText("x20 y530", "选择药剂：")
cbPotion1 := mainGui.AddCheckbox("x100 y530 Checked", "药1")
cbPotion2 := mainGui.AddCheckbox("x160 y530 Checked", "药2")
cbPotion3 := mainGui.AddCheckbox("x220 y530 Checked", "药3")
cbPotion4 := mainGui.AddCheckbox("x280 y530 Checked", "药4")
cbPotion5 := mainGui.AddCheckbox("x340 y530 Checked", "药5")

; 保存复选框引用到全局变量，方便后续读取状态
global cbPotion1, cbPotion2, cbPotion3, cbPotion4, cbPotion5

; =========================
; 模块2：鼠标连点功能
; =========================
; 功能说明：按住鼠标右键(RButton)不放，以100ms间隔自动连点左键或右键
; 注意：使用SendPlay发送点击，避免被AHK自身捕获形成递归
mainGui.AddGroupBox("x10 y590 w420 h100", "鼠标连点（按住右键触发）")

; 功能启用复选框（默认启用）
clickerEnableCB := mainGui.AddCheckbox("x20 y615 vClickerEnabled Checked", "启用鼠标连点")
clickerEnableCB.OnEvent("Click", ToggleClicker)

; 默认启用鼠标连点功能
clickerEnabled := true
Hotkey "~RButton", StartClicker, "On"
Hotkey "~RButton Up", StopClicker, "On"

; 连点按键选择下拉框
mainGui.AddText("x20 y640", "连点鼠标：")
; UI显示中文，但内部映射到英文按键名
clickerDDL := mainGui.AddDropDownList("x90 y638 w80", ["左键", "右键"])
clickerDDL.Value := 1  ; 默认选择左键
global clickerDDL
; 创建UI文本到按键名的映射
clickerButtonMap := Map("左键", "LButton", "右键", "RButton")

mainGui.AddText("x180 y640", "间隔：80-120毫秒（随机）")

; 提示：使用SendPlay避免递归捕获
mainGui.AddText("x20 y660 w380 cGray", "提示：默认鼠标左键，右键按住不放时生效，松开右键停止连点")

mainGui.Show("w440 h710")

; 初始化窗口列表
RefreshWindowList()

; =========================
; 快捷键绑定函数
; =========================
SetHotkey(*) {
    global currentHotkey, hotkeyDDL

    ; 移除旧快捷键
    Hotkey "~" currentHotkey, ToggleAll, "Off"

    currentHotkey := hotkeyDDL.Text

    ; 绑定新快捷键（加~前缀让按键本身也能生效）
    Hotkey "~" currentHotkey, ToggleAll, "On"

    MsgBox "快捷键已设置为：" currentHotkey
}

; 默认绑定一次（加~前缀让按键本身也能生效）
Hotkey "~" currentHotkey, ToggleAll, "On"

; =========================
; 总开关（快捷键控制全部）
; =========================
ToggleAll(*) {
    global ddl1, ddl2a, ddl3a
    
    ; 检查是否至少设置了一个按键
    key1 := ddl1.Text
    key2 := ddl2a.Text
    key3 := ddl3a.Text
    
    ; 如果三个按键都未设置（为空或默认提示），显示提示框
    if (key1 = "" && key2 = "" && key3 = "") {
        MsgBox "尚未设置按键", "提示", "Icon!"
        return
    }
    
    Toggle1()
    Toggle2()
    Toggle3()
}

; =========================
; 按键1逻辑
; =========================
; =========================
; 通用按键逻辑（合并优化）
; =========================
; 功能说明：
; - 三个按键共用同一套逻辑，通过参数区分
; - 支持随机间隔（用户输入值 ±50ms），避免被检测为固定频率脚本
; - 每次按键后重新计算下一次的随机间隔

; =========================
; 按键1逻辑
; =========================
Toggle1(*) {
    global running1, int1, interval1
    
    if (!running1) {
        interval1 := int1.Value
        running1 := true
        ; 先立即执行一次（10ms延迟确保状态已更新）
        SetTimer Press1, -10
    } else {
        SetTimer Press1, 0
        running1 := false
    }
    
    UpdateStatus()
}

Press1() {
    global ddl1, interval1, running1
    
    if !IsTargetWindowActive()
        return
    
    Send "{" ddl1.Text "}"
    
    ; 设置下一次随机间隔（基础值 ±20ms）
    if (running1) {
        nextInterval := Random(Max(20, interval1 - 20), interval1 + 20)
        SetTimer Press1, nextInterval
    }
}

; =========================
; 按键2逻辑
; =========================
Toggle2(*) {
    global running2, int2, interval2
    
    if (!running2) {
        interval2 := int2.Value
        running2 := true
        ; 先立即执行一次（15ms延迟，与按键1错开避免冲突）
        SetTimer Press2, -15
    } else {
        SetTimer Press2, 0
        running2 := false
    }
    
    UpdateStatus()
}

Press2() {
    global ddl2a, interval2, running2
    
    if !IsTargetWindowActive()
        return
    
    Send "{" ddl2a.Text "}"
    
    ; 设置下一次随机间隔
    if (running2) {
        nextInterval := Random(Max(20, interval2 - 20), interval2 + 20)
        SetTimer Press2, nextInterval
    }
}

; =========================
; 按键3逻辑
; =========================
Toggle3(*) {
    global running3, int3, interval3
    
    if (!running3) {
        interval3 := int3.Value
        running3 := true
        ; 先立即执行一次（20ms延迟，与前面错开）
        SetTimer Press3, -20
    } else {
        SetTimer Press3, 0
        running3 := false
    }
    
    UpdateStatus()
}

Press3() {
    global ddl3a, interval3, running3
    
    if !IsTargetWindowActive()
        return
    
    Send "{" ddl3a.Text "}"
    
    ; 设置下一次随机间隔
    if (running3) {
        nextInterval := Random(Max(20, interval3 - 20), interval3 + 20)
        SetTimer Press3, nextInterval
    }
}

; =========================
; 窗口选择功能
; =========================
RefreshWindowList(*) {
    global windowList
    
    windowList.Delete()
    
    winList := WinGetList()
    
    for hwnd in winList {
        try {
            title := WinGetTitle("ahk_id " hwnd)
            exe := WinGetProcessName("ahk_id " hwnd)
            
            if (title != "") {
                windowList.Add("", title, exe)
            }
        }
    }
}

SelectWindow(*) {
    global windowList, windowEdit, targetWindow
    
    row := windowList.GetNext()
    if row {
        title := windowList.GetText(row, 1)
        windowEdit.Value := title
        targetWindow := title
    }
}

UpdateTargetWindow(*) {
    global windowEdit, targetWindow
    targetWindow := windowEdit.Value
}

; =========================
; 检查当前窗口是否为目标窗口
; =========================
IsTargetWindowActive() {
    global targetWindow
    
    if (targetWindow = "")
        return true  ; 没有设置目标窗口，所有窗口都允许
    
    ; 检查当前活动窗口的标题
    try {
        activeTitle := WinGetTitle("A")
        if InStr(activeTitle, targetWindow)
            return true
    }
    
    return false
}

; =========================
; 状态更新
; =========================
UpdateStatus() {
    global statusText, running1, running2, running3, targetWindow, potionEnabled, clickerEnabled, clickerRunning

    txt := "状态："

    ; 循环按键整体状态
    loopRunning := running1 || running2 || running3
    txt .= loopRunning ? "[循环按键运行中] " : "[循环按键停止] "
    txt .= potionEnabled ? "[喝药开] " : "[喝药关] "
    txt .= clickerEnabled ? (clickerRunning ? "[连点中]" : "[连点开]") : "[连点关]"
    
    if (targetWindow != "")
        txt .= " | 目标: " targetWindow

    statusText.Value := txt
}

; =========================
; 模块1：一键喝药功能
; =========================
; 功能说明：
; - 当功能启用时，监听 ` 键（反引号）
; - 按下 ` 键时，同时发送选中的数字键（1-5）
; - 仅在目标窗口激活时生效
; - 使用 Send 发送按键

TogglePotion(*) {
    global potionEnabled
    
    potionEnabled := !potionEnabled
    
    if (potionEnabled) {
        ; 启用热键：监听 ` 键（反引号）
        Hotkey "``", SendPotionKeys, "On"
    } else {
        ; 禁用热键
        Hotkey "``", SendPotionKeys, "Off"
    }
    
    UpdateStatus()
}

SendPotionKeys(*) {
    global cbPotion1, cbPotion2, cbPotion3, cbPotion4, cbPotion5
    
    ; 检查是否在目标窗口内
    if !IsTargetWindowActive()
        return
    
    ; 根据复选框状态发送对应的数字键
    ; 使用 Send 同时发送多个按键
    keysToSend := ""
    
    if (cbPotion1.Value)
        keysToSend .= "1"
    if (cbPotion2.Value)
        keysToSend .= "2"
    if (cbPotion3.Value)
        keysToSend .= "3"
    if (cbPotion4.Value)
        keysToSend .= "4"
    if (cbPotion5.Value)
        keysToSend .= "5"
    
    ; 如果有选中的按键，同时发送
    if (keysToSend != "") {
        ; 使用 Send 发送按键序列
        Loop Parse keysToSend {
            Send "{" A_LoopField "}"
        }
    }
}

; =========================
; 模块2：鼠标连点功能
; =========================
; 功能说明：
; - 当功能启用时，监听鼠标右键按住事件
; - 按住右键不放时，以100ms间隔自动连点选中的按键（左键或右键）
; - 使用 SendPlay 发送点击，避免被AHK自身捕获形成递归
; - 松开右键时停止连点
; - 仅在目标窗口激活时生效

ToggleClicker(*) {
    global clickerEnabled, clickerDDL
    
    clickerEnabled := !clickerEnabled
    
    if (clickerEnabled) {
        ; 启用热键：监听右键按下和松开
        ; 使用 ~ 前缀让系统也能收到右键事件（不拦截）
        Hotkey "~RButton", StartClicker, "On"
        Hotkey "~RButton Up", StopClicker, "On"
    } else {
        ; 禁用热键
        Hotkey "~RButton", StartClicker, "Off"
        Hotkey "~RButton Up", StopClicker, "Off"
        ; 确保停止连点
        StopClicker()
    }
    
    UpdateStatus()
}

StartClicker(*) {
    global clickerRunning, clickerInterval, clickerDDL
    
    ; 检查是否在目标窗口内
    if !IsTargetWindowActive()
        return
    
    ; 获取选中的连点按键
    clickerButton := clickerDDL.Text
    
    ; 启动连点定时器
    clickerRunning := true
    SetTimer DoClick, clickerInterval
    
    UpdateStatus()
}

StopClicker(*) {
    global clickerRunning
    
    ; 停止连点定时器
    clickerRunning := false
    SetTimer DoClick, 0
    
    UpdateStatus()
}

DoClick() {
    global clickerDDL, clickerRunning, clickerButtonMap
    
    ; 检查是否在目标窗口内
    if !IsTargetWindowActive() {
        ; 如果不在目标窗口，停止连点
        StopClicker()
        return
    }
    
    ; 检查右键是否仍然按住
    if !GetKeyState("RButton", "P") {
        StopClicker()
        return
    }
    
    ; 使用 SendPlay 发送点击，避免被AHK捕获
    ; SendPlay 使用更底层的输入方式，不会被当前脚本的热键拦截
    ; 通过映射获取英文按键名
    uiText := clickerDDL.Text
    clickerButton := clickerButtonMap.Has(uiText) ? clickerButtonMap[uiText] : "LButton"
    SendPlay "{" clickerButton "}"
    
    ; 设置下一次点击的随机间隔（80-120ms，基础100ms ±20ms）
    ; 随机间隔可以避免被游戏检测为固定频率的脚本点击
    randomInterval := Random(80, 120)
    SetTimer DoClick, randomInterval
}