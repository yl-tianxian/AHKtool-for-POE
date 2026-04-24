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
global PrefixCheck1 := 0, PrefixCheck2 := 0, PrefixCheck3 := 0, PrefixCheck4 := 0
global NeedsPrefix1 := "", NeedsPrefix2 := "", NeedsPrefix3 := "", NeedsPrefix4 := ""

global SuffixCheck1 := 0, SuffixCheck2 := 0, SuffixCheck3 := 0, SuffixCheck4 := 0
global NeedsSuffix1 := "", NeedsSuffix2 := "", NeedsSuffix3 := "", NeedsSuffix4 := ""

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

; ========== 模块1: 改造-增幅-富豪-崇高 ==========
MyGui.Add("GroupBox", "x15 y5 w410 h370", "改造-增幅-富豪")

; Prefix 标签和输入框（带复选框）
MyGui.Add("Text", "x35 y30 w80 h20", "前缀:")
yPos := 60
loop 4 {
    MyGui.Add("CheckBox", "x35 y" yPos " w18 h22 vPrefixCheck" A_Index, "")
    MyGui.Add("Edit", "x60 y" yPos " w340 h26 vNeedsPrefix" A_Index, NeedsPrefix%A_Index%)
    yPos += 30
}

; Suffix 标签和输入框（带复选框）
MyGui.Add("Text", "x35 y190 w80 h20", "后缀:")
yPos := 220
loop 4 {
    MyGui.Add("CheckBox", "x35 y" yPos " w18 h22 vSuffixCheck" A_Index, "")
    MyGui.Add("Edit", "x60 y" yPos " w340 h26 vNeedsSuffix" A_Index, NeedsSuffix%A_Index%)
    yPos += 30
}

; ========== 模块2: 改造模式 ==========
MyGui.Add("GroupBox", "x15 y385 w205 h250", "改造模式")

; 6个带复选框的输入框
yPos := 415
loop 6 {
    MyGui.Add("CheckBox", "x25 y" yPos " w18 h22 vModCheck" A_Index, "")
    MyGui.Add("Edit", "x50 y" yPos " w160 h26 vNeedsModifiers" A_Index, NeedsModifiers%A_Index%)
    yPos += 30
}

; ========== 模块3: 精华or庄园 ==========
MyGui.Add("GroupBox", "x220 y385 w205 h250", "庄园")

MyGui.AddText("x225 y425", "必要`n词缀:")
MyGui.AddEdit("x260 y415 w140 h26 vMustNeed1", MustNeed1)
MyGui.AddEdit("x260 y445 w140 h26 vMustNeed2", MustNeed2)


; 4个带复选框的输入框 
MyGui.AddText("x225 y479 w80 h20", "次要词缀:")
yPos := 505
loop 4 {

    MyGui.Add("Edit", "x260 y" yPos " w140 h26 vNeedsModifiersjh" A_Index, NeedsModifiersjh%A_Index%)
    yPos += 30
}

; ========== 模块4: 通货余额 ==========
MyGui.Add("GroupBox", "x15 y640 w410 h85", "通货余额")

; 通货列表（2列布局）
currencyList := [
    ["蜕变石：", "CountTuibian"],
    ["富豪石：", "CountFuhao"],
    ["剥离石：", "CountBolizhi"],
    ["增幅石：", "CountZengfu"],
    ["改造石：", "CountGaizao"],
    ["崇高石：", "CountChonggao"],
    ["点金石：", "CountDianjin"],
    ["重铸石：", "CountChongzhu"],
    ["混沌石：", "CountHundun"],
    ["物品：", "CountWupin"]
]
MyGui.Add("Text", "x200 y640 w70 h20", "当前物品：")
MyGui.Add("Text", "x270 y640 w150 h20 vCountWupin", "")
yPos := 660
loop 3 {
    idx := A_Index
    ; 左列
    MyGui.Add("Text", "x30 y" yPos " w55 h20", currencyList[idx][1])
    MyGui.Add("Text", "x85 y" yPos " w50 h20 v" currencyList[idx][2], "0")
    ;中列
    MyGui.Add("Text", "x170 y" yPos " w55 h20", currencyList[idx + 3][1])
    MyGui.Add("Text", "x225 y" yPos " w50 h20 v" currencyList[idx + 3][2], "0")
    ; 右列
    MyGui.Add("Text", "x310 y" yPos " w55 h20", currencyList[idx + 6][1])
    MyGui.Add("Text", "x365 y" yPos " w50 h20 v" currencyList[idx + 6][2], "0")

    yPos += 20
}

; ========== 按钮 ==========
getCoordsBtn := MyGui.Add("Button", "x30 y725 w100 h30", "自动获取通货坐标")
getCoordsBtn.OnEvent("Click", OnGetCoordsBtn)
MyGui.Add("Button", "x150 y725 w100 h30", "停止")
saveBtn := MyGui.Add("Button", "x270 y725 w100 h30", "保存配置")
saveBtn.OnEvent("Click", SaveAllConfig)

; 调试按钮
debugBtn := MyGui.Add("Button", "x380 y725 w80 h30", "调试")
debugBtn.OnEvent("Click", DebugShowAll)

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
    ; 模块1: 前缀
    Loop 4 {
        val := IniRead(CfgFile, "Prefix", "Check" A_Index, "0")
        MyGui["PrefixCheck" A_Index].Value := val
        val := IniRead(CfgFile, "Prefix", "Need" A_Index, "")
        MyGui["NeedsPrefix" A_Index].Value := val
    }
    ; 模块1: 后缀
    Loop 4 {
        val := IniRead(CfgFile, "Suffix", "Check" A_Index, "0")
        MyGui["SuffixCheck" A_Index].Value := val
        val := IniRead(CfgFile, "Suffix", "Need" A_Index, "")
        MyGui["NeedsSuffix" A_Index].Value := val
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
    ; 模块1: 前缀
    Loop 4 {
        IniWrite(MyGui["PrefixCheck" A_Index].Value, CfgFile, "Prefix", "Check" A_Index)
        IniWrite(MyGui["NeedsPrefix" A_Index].Value, CfgFile, "Prefix", "Need" A_Index)
    }
    ; 模块1: 后缀
    Loop 4 {
        IniWrite(MyGui["SuffixCheck" A_Index].Value, CfgFile, "Suffix", "Check" A_Index)
        IniWrite(MyGui["NeedsSuffix" A_Index].Value, CfgFile, "Suffix", "Need" A_Index)
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
    
    ; 模块1: 前缀
    info .= "【前缀词缀】`n"
    Loop 3 {
        chk := MyGui["PrefixCheck" A_Index].Value ? "√" : "□"
        txt := MyGui["NeedsPrefix" A_Index].Value
        info .= A_Index ": " chk " " txt "`n"
    }
    
    ; 模块1: 后缀
    info .= "`n【后缀词缀】`n"
    Loop 3 {
        chk := MyGui["SuffixCheck" A_Index].Value ? "√" : "□"
        txt := MyGui["NeedsSuffix" A_Index].Value
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
                MsgBox("改造复制失败,被迫终止" )
                break
            }
            
        Loop 4 {
            ; 检查是否有符合的前缀
            if (MyGui["PrefixCheck" A_Index].Value && MyGui["NeedsPrefix" A_Index].Value != "") {
                if InStr(A_Clipboard, MyGui["NeedsPrefix" A_Index].Value)
                    matchCount++
            }
            ; 检查是否有符合的后缀
            if (MyGui["SuffixCheck" A_Index].Value && MyGui["NeedsSuffix" A_Index].Value != "") {
                if InStr(A_Clipboard, MyGui["NeedsSuffix" A_Index].Value)
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
                MsgBox("增幅复制失败,被迫终止" )
                break
            }

            Loop 4 {

            ; 检查是否有符合的前缀
            if (MyGui["PrefixCheck" A_Index].Value && MyGui["NeedsPrefix" A_Index].Value != "") {
                    if InStr(A_Clipboard, MyGui["NeedsPrefix" A_Index].Value)
                        matchCount_zengfu++
                }
            ; 检查是否有符合的后缀
                if (MyGui["SuffixCheck" A_Index].Value && MyGui["NeedsSuffix" A_Index].Value != "") {
                    if InStr(A_Clipboard, MyGui["NeedsSuffix" A_Index].Value)
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
                MsgBox("富豪复制失败,被迫终止" )
                break
            }

            Loop 4 {

            ; 检查是否有符合的前缀
            if (MyGui["PrefixCheck" A_Index].Value && MyGui["NeedsPrefix" A_Index].Value != "") {
                if InStr(A_Clipboard, MyGui["NeedsPrefix" A_Index].Value)
                    matchCount_fuhao++
                }
            ; 检查是否有符合的后缀
            if (MyGui["SuffixCheck" A_Index].Value && MyGui["NeedsSuffix" A_Index].Value != "") {
                if InStr(A_Clipboard, MyGui["NeedsSuffix" A_Index].Value)
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