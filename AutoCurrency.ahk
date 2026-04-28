#Requires AutoHotkey v2.0

; 调试重启用，编译前注释掉！！！！！！！
F5:: {
    Sleep 50
    Reload()
}
; 配置文件路径
CfgFile := A_ScriptDir "\AutoCurrency_config.ini"

; --- GUI 界面 ---

; 模块1变量
global ModeoneCheck1 := 0, ModeoneCheck2 := 0, ModeoneCheck3 := 0, ModeoneCheck4 := 0
global ModeoneCheck5 := 0, ModeoneCheck6 := 0, ModeoneCheck7 := 0, ModeoneCheck8 := 0
global ModeoneCheck9 := 0, ModeoneCheck10 := 0, ModeoneCheck11 := 0, ModeoneCheck12 := 0
global NeedsModeone1 := "", NeedsModeone2 := "", NeedsModeone3 := "", NeedsModeone4 := ""
global NeedsModeone5 := "", NeedsModeone6 := "", NeedsModeone7 := "", NeedsModeone8 := ""
global NeedsModeone9 := "", NeedsModeone10 := "", NeedsModeone11 := "", NeedsModeone12 := ""

; 模块2变量
global ModCheck1 := 0, ModCheck2 := 0, ModCheck3 := 0, ModCheck4 := 0, ModCheck5 := 0, ModCheck6 := 0
global NeedsModifiers1 := "", NeedsModifiers2 := "", NeedsModifiers3 := "", NeedsModifiers4 := "", NeedsModifiers5 := "", NeedsModifiers6 := ""

; 模块3变量
global MustNeed1 := "", MustNeed2 := ""
global NeedsModifiersjh1 := "", NeedsModifiersjh2 := "", NeedsModifiersjh3 := "", NeedsModifiersjh4 := ""


; 通货余额变量
global CountTuibian := 0, CountGaizao := 0, CountFuhao := 0, CountChonggao := 0
global CountBolizhi := 0, CountDianjin := 0, CountHundun := 0, CountZengfu := 0
global CountChongzhu := 0, CountWupin := 0

; 创建主窗口

MyGui := Gui("", "POE 通货工具")
MyGui.SetFont("s10", "微软雅黑")
MyGui.MarginX := 15
MyGui.MarginY := 10

; ========== 模块1: 改造-增幅-富豪 ==========
MyGui.Add("GroupBox", "x15 y5 w410 h450", "改造-增幅-富豪")

; 模式选择CheckBox（互斥）
MyGui.Add("Text", "x20 y30", "模式选择：")
OneModifier := MyGui.Add("CheckBox", "x90 y30 w90 h20 vOneModifier", "满足任一词")
OneModifier.Value := true  ; 默认选中"满足任一词"
OneModifier.OnEvent("Click", OnModeCheckBoxClick)
TwoModifiers := MyGui.Add("CheckBox", "x190 y30 w80 h20 vTwoModifiers", "改造增幅")
TwoModifiers.OnEvent("Click", OnModeCheckBoxClick)
ThreeModifiers := MyGui.Add("CheckBox", "x270 y30 w120 h20 vThreeModifiers", "改造增幅富豪")
ThreeModifiers.OnEvent("Click", OnModeCheckBoxClick)

; 目标词缀标签和输入框（带复选框）- 单列
yPos := 60
loop 6 {
    MyGui.Add("CheckBox", "x35 y" yPos " w18 h22 vModeoneCheck" A_Index, "")
    MyGui.Add("Edit", "x60 y" yPos " w340 h26 vNeedsModeone" A_Index, NeedsModeone%A_Index%)
    yPos += 30
}

; 分隔文字
MyGui.Add("Text", "x35 y" yPos " w360 h20 Center", "======上方前缀，下方后缀======")
yPos += 25

loop 6 {
    idx := A_Index + 6
    MyGui.Add("CheckBox", "x35 y" yPos " w18 h22 vModeoneCheck" idx, "")
    MyGui.Add("Edit", "x60 y" yPos " w340 h26 vNeedsModeone" idx, NeedsModeone%idx%)
    yPos += 30
}

; ========== 模块2: 精华模式 ==========
MyGui.Add("GroupBox", "x15 y460 w205 h250", "精华模式")

; 6个带复选框的输入框
yPos := 490
loop 6 {
    MyGui.Add("CheckBox", "x25 y" yPos " w18 h22 vModCheck" A_Index, "")
    MyGui.Add("Edit", "x50 y" yPos " w160 h26 vNeedsModifiers" A_Index, NeedsModifiers%A_Index%)
    yPos += 30
}

; ========== 模块3: 庄园 ==========
MyGui.Add("GroupBox", "x220 y460 w205 h250", "庄园")

MyGui.AddText("x225 y500", "必要`n词缀:")
MyGui.AddEdit("x260 y490 w140 h26 vMustNeed1", MustNeed1)
MyGui.AddEdit("x260 y520 w140 h26 vMustNeed2", MustNeed2)


; 4个带复选框的输入框
MyGui.AddText("x225 y555 w80 h20", "次要词缀:")
yPos := 580
loop 4 {

    MyGui.Add("Edit", "x260 y" yPos " w140 h26 vNeedsModifiersjh" A_Index, NeedsModifiersjh%A_Index%)
    yPos += 30
}

; ; ========== 模块4: 通货余额 ==========
; MyGui.Add("GroupBox", "x15 y640 w410 h85", "通货余额")

; ; 通货列表（2列布局）
; currencyList := [
;     ["蜕变石：", "CountTuibian"],
;     ["富豪石：", "CountFuhao"],
;     ["剥离石：", "CountBolizhi"],
;     ["增幅石：", "CountZengfu"],
;     ["改造石：", "CountGaizao"],
;     ["崇高石：", "CountChonggao"],
;     ["点金石：", "CountDianjin"],
;     ["重铸石：", "CountChongzhu"],
;     ["混沌石：", "CountHundun"],
;     ["物品：", "CountWupin"]
; ]
; MyGui.Add("Text", "x200 y640 w70 h20", "当前物品：")
; MyGui.Add("Text", "x270 y640 w150 h20 vCountWupin", "")
; yPos := 660
; loop 3 {
;     idx := A_Index
;     ; 左列
;     MyGui.Add("Text", "x30 y" yPos " w55 h20", currencyList[idx][1])
;     MyGui.Add("Text", "x85 y" yPos " w50 h20 v" currencyList[idx][2], "0")
;     ;中列
;     MyGui.Add("Text", "x170 y" yPos " w55 h20", currencyList[idx + 3][1])
;     MyGui.Add("Text", "x225 y" yPos " w50 h20 v" currencyList[idx + 3][2], "0")
;     ; 右列
;     MyGui.Add("Text", "x310 y" yPos " w55 h20", currencyList[idx + 6][1])
;     MyGui.Add("Text", "x365 y" yPos " w50 h20 v" currencyList[idx + 6][2], "0")

;     yPos += 20
; }

; ========== 按钮 ==========
getCoordsBtn := MyGui.Add("Button", "x30 y725 w100 h30", "自动获取通货坐标")
getCoordsBtn.OnEvent("Click", OnGetCoordsBtn)
MyGui.Add("Button", "x150 y725 w100 h30", "停止")
saveBtn := MyGui.Add("Button", "x270 y725 w100 h30", "保存配置")
saveBtn.OnEvent("Click", SaveAllConfig)

; 调试按钮
debugBtn := MyGui.Add("Button", "x380 y725 w80 h30", "调试")
debugBtn.OnEvent("Click", DebugShowAll)

; ========== 互斥CheckBox事件处理 ==========
OnModeCheckBoxClick(CheckBoxCtrl, *) {
    global OneModifier, TwoModifiers, ThreeModifiers
    
    ; 检查是否至少有1个被选中
    if !OneModifier.Value && !TwoModifiers.Value && !ThreeModifiers.Value {
        ; 如果全部未选中，则恢复当前点击的CheckBox为选中状态
        CheckBoxCtrl.Value := true
        return
    }
    
    ; 获取当前点击的CheckBox
    if (CheckBoxCtrl == OneModifier && OneModifier.Value) {
        TwoModifiers.Value := false
        ThreeModifiers.Value := false
    }
    else if (CheckBoxCtrl == TwoModifiers && TwoModifiers.Value) {
        OneModifier.Value := false
        ThreeModifiers.Value := false
    }
    else if (CheckBoxCtrl == ThreeModifiers && ThreeModifiers.Value) {
        OneModifier.Value := false
        TwoModifiers.Value := false
    }
}

; 显示窗口
MyGui.Show("w440 h770")

; 启动时自动加载配置
LoadAllConfig()

; ========== 通货坐标定义 ==========
; 原始坐标（基准分辨率600高度下）
global tuibian_x0  := 32,  tuibian_y0  := 153
global gaizao_x0   := 63,  gaizao_y0   := 153
global fuhao_x0    := 243, fuhao_y0    := 153
global E_x0        := 169, E_y0        := 153
global boli_x0     := 95,  boli_y0     := 153
global dianjin_x0  := 275, dianjin_y0  := 153
global C_x0        := 306, C_y0        := 153
global zengfu_x0   := 127, zengfu_y0   := 186
global chongzhu_x0 := 243, chongzhu_y0 := 224
global wupin_x0    := 186, wupin_y0    := 255

; 计算后的坐标（根据当前分辨率）
global tuibian_x, tuibian_y
global gaizao_x,  gaizao_y
global fuhao_x,  fuhao_y
global E_x,       E_y
global boli_x,    boli_y
global dianjin_x, dianjin_y
global C_x,       C_y
global zengfu_x,  zengfu_y
global chongzhu_x, chongzhu_y
global wupin_x,   wupin_y

; 缩放比例
global scaleFactor := 1


; --- 使用示例 ---

; 设置鼠标坐标模式为客户区模式，这样坐标就是相对于游戏窗口左上角的
CoordMode "Mouse", "Client" 


; 按钮事件：自动获取通货坐标
OnGetCoordsBtn(*) {
    ; 检测游戏窗口
    if !WinExist("ahk_exe PathOfExile_x64.exe") {
        MsgBox "未找到游戏窗口，请先启动游戏！"
        return
    }
    
    ; 获取窗口客户区坐标和尺寸
    WinGetClientPos &X, &Y, &PoeW, &PoeH, "流放之路"
    
    ; 计算缩放比例
    global scaleFactor := PoeH / 600
    
    ; 计算所有通货坐标
    global tuibian_x  := Round(tuibian_x0  * scaleFactor), tuibian_y  := Round(tuibian_y0  * scaleFactor)
    global gaizao_x   := Round(gaizao_x0   * scaleFactor), gaizao_y   := Round(gaizao_y0   * scaleFactor)
    global fuhao_x    := Round(fuhao_x0    * scaleFactor), fuhao_y    := Round(fuhao_y0    * scaleFactor)
    global E_x        := Round(E_x0        * scaleFactor), E_y        := Round(E_y0        * scaleFactor)
    global boli_x     := Round(boli_x0     * scaleFactor), boli_y     := Round(boli_y0     * scaleFactor)
    global dianjin_x  := Round(dianjin_x0  * scaleFactor), dianjin_y  := Round(dianjin_y0  * scaleFactor)
    global C_x        := Round(C_x0        * scaleFactor), C_y        := Round(C_y0        * scaleFactor)
    global zengfu_x   := Round(zengfu_x0   * scaleFactor), zengfu_y   := Round(zengfu_y0   * scaleFactor)
    global chongzhu_x := Round(chongzhu_x0 * scaleFactor), chongzhu_y := Round(chongzhu_y0 * scaleFactor)
    global wupin_x    := Round(wupin_x0    * scaleFactor), wupin_y    := Round(wupin_y0    * scaleFactor)
    
    ToolTip "已获取窗口坐标！`n分辨率: " PoeW "x" PoeH "`n缩放因子: " scaleFactor
    Sleep 2000
    ToolTip
}



; 更新通货余额的函数（供后续调用）
UpdateCurrencyCount(name, value) {
    global MyGui
    try {
        MyGui[name].Text := value
    }
}

; ========== 配置加载/保存 ==========

; 从配置文件加载所有设置
LoadAllConfig() {
    global CfgFile, MyGui
    ; 模块1: 目标词缀
    Loop 12 {
        val := IniRead(CfgFile, "Modeone", "Check" A_Index, "0")
        MyGui["ModeoneCheck" A_Index].Value := val
        val := IniRead(CfgFile, "Modeone", "Need" A_Index, "")
        MyGui["NeedsModeone" A_Index].Value := val
    }
    ; 模块2: 改造模式
    Loop 6 {
        val := IniRead(CfgFile, "Modifiers", "Check" A_Index, "0")
        MyGui["ModCheck" A_Index].Value := val
        val := IniRead(CfgFile, "Modifiers", "Need" A_Index, "")
        MyGui["NeedsModifiers" A_Index].Value := val
    }
    ; 模块3: 庄园
    Loop 2 {
        val := IniRead(CfgFile, "MustNeed", "Need" A_Index, "")
        MyGui["MustNeed" A_Index].Value := val
    }
    Loop 4 {
        val := IniRead(CfgFile, "Modifiersjh", "Need" A_Index, "")
        MyGui["NeedsModifiersjh" A_Index].Value := val
    }
}

; 保存所有配置到ini文件
SaveAllConfig(*) {
    global CfgFile, MyGui
    ; 模块1: 目标词缀
    Loop 12 {
        IniWrite(MyGui["ModeoneCheck" A_Index].Value, CfgFile, "Modeone", "Check" A_Index)
        IniWrite(MyGui["NeedsModeone" A_Index].Value, CfgFile, "Modeone", "Need" A_Index)
    }
    ; 模块2: 改造模式
    Loop 6 {
        IniWrite(MyGui["ModCheck" A_Index].Value, CfgFile, "Modifiers", "Check" A_Index)
        IniWrite(MyGui["NeedsModifiers" A_Index].Value, CfgFile, "Modifiers", "Need" A_Index)
    }
    ; 模块3: 庄园
    Loop 2 {
        IniWrite(MyGui["MustNeed" A_Index].Value, CfgFile, "MustNeed", "Need" A_Index)
    }
    Loop 4 {
        IniWrite(MyGui["NeedsModifiersjh" A_Index].Value, CfgFile, "Modifiersjh", "Need" A_Index)
    }
    ToolTip "配置已保存！"
    Sleep 1500
    ToolTip
}

; ========== 调试函数 ==========

; 调试：显示所有输入框信息和剪贴板内容
DebugShowAll(*) {
    global MyGui
    
    ; 获取剪贴板内容
    clipboardContent := A_Clipboard
    
    ; 构建调试信息
    info := "========== 调试信息 ==========`n`n"
    
    ; 模块1: 目标词缀
    info .= "【目标词缀】`n"
    Loop 12 {
        chk := MyGui["ModeoneCheck" A_Index].Value ? "√" : "□"
        txt := MyGui["NeedsModeone" A_Index].Value
        info .= A_Index ": " chk " " txt "`n"
    }
    
    ; 模块2: 改造模式
    info .= "`n【改造模式词缀】`n"
    Loop 6 {
        chk := MyGui["ModCheck" A_Index].Value ? "√" : "□"
        txt := MyGui["NeedsModifiers" A_Index].Value
        info .= A_Index ": " chk " " txt "`n"
    }
    
    ; 剪贴板内容
    info .= "`n========== 剪贴板内容 ==========`n"
    info .= clipboardContent ? clipboardContent : "(空)"
    
    ; 显示弹窗
    DebugGui := Gui("", "调试信息")
    DebugGui.SetFont("s10", "Consolas")
    DebugGui.Add("Text", "w400 r20", info)
    DebugGui.Add("Button", "x150 y+20 w100", "关闭").OnEvent("Click", (*) => DebugGui.Destroy())
    DebugGui.Show()
}

; ========== 测试函数：依次移动鼠标到每个通货位置 ==========
CoordMode "Mouse", "Client"

; 测试所有通货坐标（鼠标移动但不点击）
F1::{
    ; 先点击按钮获取坐标
    if (scaleFactor = 1) {
        ToolTip "请先点击「自动获取通货坐标」按钮！"
        Sleep 1500
        ToolTip
        return
    }
    
    MouseMove tuibian_x, tuibian_y, 0
    ToolTip "tuibian: (" tuibian_x ", " tuibian_y ")"
    Sleep 1000
    
    MouseMove gaizao_x, gaizao_y, 0
    ToolTip "gaizao: (" gaizao_x ", " gaizao_y ")"
    Sleep 1000
    
    MouseMove boli_x, boli_y, 0
    ToolTip "boli: (" boli_x ", " boli_y ")"
    Sleep 1000
    
    MouseMove E_x, E_y, 0
    ToolTip "E: (" E_x ", " E_y ")"
    Sleep 1000
    
    MouseMove zengfu_x, zengfu_y, 0
    ToolTip "zengfu: (" zengfu_x ", " zengfu_y ")"
    Sleep 1000
    
    MouseMove fuhao_x, fuhao_y, 0
    ToolTip "fuhao: (" fuhao_x ", " fuhao_y ")"
    Sleep 1000
    
    MouseMove dianjin_x, dianjin_y, 0
    ToolTip "dianjin: (" dianjin_x ", " dianjin_y ")"
    Sleep 1000
    
    MouseMove chongzhu_x, chongzhu_y, 0
    ToolTip "chongzhu: (" chongzhu_x ", " chongzhu_y ")"
    Sleep 1000
    
    MouseMove C_x, C_y, 0
    ToolTip "C: (" C_x ", " C_y ")"
    Sleep 1000
    
    MouseMove wupin_x, wupin_y, 0
    ToolTip "wupin: (" wupin_x ", " wupin_y ")"
    Sleep 1000
    
    ToolTip "测试完成！"
    Sleep 1000
    ToolTip
}

#HotIf WinActive("流放之路") or WinActive("Path of Exile")
; 单改造核心逻辑
F2:: {

    Sleep 200
    
    MouseMove gaizao_x, gaizao_y
    Sleep Random(300, 350)
    Click("Right")
    Sleep Random(300, 350)
    
    MouseMove wupin_x, wupin_y
    Sleep Random(300, 350)
    Send "{Shift down}"
    Sleep Random(300, 350)

    Loop {
        Click() 
        Sleep Random(300, 350)
        
        A_Clipboard := ""
        Send "!^c" 
        if !ClipWait(0.8) {
                MsgBox("改造复制失败,被迫终止" )
                break
            }
            
        isMatched := false
        Loop 6 {
            if (MyGui["ModCheck" A_Index].Value = 1 && MyGui["NeedsModifiers" A_Index].Value != "") {
                if InStr(A_Clipboard, MyGui["NeedsModifiers" A_Index].Value) {
                    isMatched := true
                    break
                }
            }
        }

        if (isMatched) {
            Send "{Shift up}"
            MsgBox("已洗出目标词缀！`n`n" A_Clipboard)
            break
        }
        
        Sleep Random(150, 300)
    }
}

; 【停止/重置】逻辑
+F3:: 
F3:: {
    Send "{Shift up}" 
    ToolTip("♻ 正在保存配置并重置...")
    SetTimer () => ToolTip(), -1000 

    SaveAllConfig()
    Sleep Random(300, 350)
    Reload()
}
#HotIf

; 改造-增幅-富豪逻辑
F4:: {

    Sleep 200
    
    MouseMove gaizao_x, gaizao_y
    Sleep Random(300, 350)
    Click("Right")
    Sleep Random(300, 350)
    
    MouseMove wupin_x, wupin_y
    Sleep Random(300, 350)
    Send "{Shift down}"
    Sleep Random(300, 350)

    Loop {
        Click() 
        Sleep Random(300, 350)
        
        A_Clipboard := ""
        matchCount := 0
        matchCount_zengfu := 0
        matchCount_fuhao := 0
        isMatched := true
        Send "!^c" 
        if !ClipWait(0.8) {
                MsgBox("改造结果复制失败,被迫终止" )
                break
            }

        Loop 12 {
            ; 检查是否有符合的目标词缀
            if (MyGui["ModeoneCheck" A_Index].Value && MyGui["NeedsModeone" A_Index].Value != "") {
                if InStr(A_Clipboard, MyGui["NeedsModeone" A_Index].Value)
                    matchCount++
            }
        }
        if (matchCount = 0)
            continue

        ; if (matchCount = 1) {
            
        ;     if InStr(A_Clipboard,"前缀") && InStr(A_Clipboard,"后缀") {
        ;         isMatched := true
        ;     }else {
        ;         isMatched := false
        ;     }
        ; }

        ; if (matchCount = 1 && isMatched = true) 
        ;     continue
; 使用增幅石
        if (matchCount = 1) {
            A_Clipboard := ""
            Send "{Alt down}"
            Sleep Random(500, 600)
            Click
            Sleep Random(500, 600)
            Send "{Alt up}"
            Sleep Random(500, 600)
            
            Send "!^c"
            if !ClipWait(0.8) {
                MsgBox("增幅结果复制失败,被迫终止" )
                break
            }

            Loop 12 {
            ; 检查是否有符合的目标词缀
            if (MyGui["ModeoneCheck" A_Index].Value && MyGui["NeedsModeone" A_Index].Value != "") {
                    if InStr(A_Clipboard, MyGui["NeedsModeone" A_Index].Value)
                        matchCount_zengfu++
                }
            }
        }

        ; if (matchCount_zengfu < 2) 
        ;     continue

        if (matchCount_zengfu >= 2 || matchCount = 2) {
            A_Clipboard := ""
            Sleep Random(300, 350)
            Send "{Shift up}"
            Sleep Random(300, 350)
            MouseMove fuhao_x, fuhao_y
            Click("Right")
            Sleep Random(300, 350)
            MouseMove wupin_x, wupin_y
            Sleep Random(300, 350)
            Click()
            Sleep Random(300, 350)
            Send "!^c"
            if !ClipWait(0.8) {
                MsgBox("富豪结果复制失败,被迫终止" )
                break
            }

            Loop 12 {
            ; 检查是否有符合的目标词缀
            if (MyGui["ModeoneCheck" A_Index].Value && MyGui["NeedsModeone" A_Index].Value != "") {
                if InStr(A_Clipboard, MyGui["NeedsModeone" A_Index].Value)
                    matchCount_fuhao++
                }
            }

            if (matchCount_fuhao >= 3) {
                Send "{Shift up}"
                MsgBox("已洗出目标词缀！`n`n" A_Clipboard)
                break
            }else {
                ; 使用重铸石
                MouseMove chongzhu_x, chongzhu_y
                Click("Right")
                Sleep Random(300, 350)
                MouseMove wupin_x, wupin_y
                Sleep Random(300, 350)
                Click()
                ; 使用蜕变石
                MouseMove tuibian_x, tuibian_y
                Click("Right")
                Sleep Random(300, 350)
                MouseMove wupin_x, wupin_y
                Sleep Random(300, 350)
                Click()
                ; 使用改造石
                MouseMove gaizao_x, gaizao_y
                Sleep Random(300, 350)
                Click("Right")
                Sleep Random(300, 350)
    
                MouseMove wupin_x, wupin_y
                Sleep Random(300, 350)
                Send "{Shift down}"
                Sleep Random(300, 350)
            }

        }
        
        Sleep Random(150, 300)
    }
}