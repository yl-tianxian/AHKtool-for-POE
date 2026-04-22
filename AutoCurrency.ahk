#Requires AutoHotkey v2.0

; 配置文件路径
CfgFile := A_ScriptDir "\AutoCurrency_config.ini"

; --- GUI 界面 ---

; 模块2变量
global ModCheck1 := 0, ModCheck2 := 0, ModCheck3 := 0, ModCheck4 := 0, ModCheck5 := 0, ModCheck6 := 0
global NeedsModifiers1 := "", NeedsModifiers2 := "", NeedsModifiers3 := "", NeedsModifiers4 := "", NeedsModifiers5 := "", NeedsModifiers6 := ""

; 模块2变量
global ModCheck1 := 0, ModCheck2 := 0, ModCheck3 := 0, ModCheck4 := 0, ModCheck5 := 0, ModCheck6 := 0
global NeedsModifiers1 := "", NeedsModifiers2 := "", NeedsModifiers3 := "", NeedsModifiers4 := "", NeedsModifiers5 := "", NeedsModifiers6 := ""

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
MyGui.Add("GroupBox", "x15 y5 w410 h290", "改造-增幅-富豪-崇高")

; Prefix 标签和输入框（带复选框）
MyGui.Add("Text", "x35 y30 w80 h20", "前缀:")
yPos := 55
loop 3 {
    MyGui.Add("CheckBox", "x35 y" yPos " w18 h22 vPrefixCheck" A_Index, "")
    MyGui.Add("Edit", "x60 y" yPos " w340 h26 vNeedsPrefix" A_Index, "")
    yPos += 30
}

; Suffix 标签和输入框（带复选框）
MyGui.Add("Text", "x35 y150 w80 h20", "后缀:")
yPos := 175
loop 3 {
    MyGui.Add("CheckBox", "x35 y" yPos " w18 h22 vSuffixCheck" A_Index, "")
    MyGui.Add("Edit", "x60 y" yPos " w340 h26 vNeedsSuffix" A_Index, "")
    yPos += 30
}

; ========== 模块2: 改造模式 ==========
MyGui.Add("GroupBox", "x15 y305 w410 h250", "改造模式")

; 6个带复选框的输入框
yPos := 335
loop 6 {
    MyGui.Add("CheckBox", "x35 y" yPos " w18 h22 vModCheck" A_Index, "")
    MyGui.Add("Edit", "x60 y" yPos " w340 h26 vNeedsModifiers" A_Index, NeedsModifiers%A_Index%)
    yPos += 30
}

; ========== 模块3: 通货余额 ==========
MyGui.Add("GroupBox", "x15 y575 w410 h140", "通货余额")

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

yPos := 595
loop 5 {
    idx := A_Index
    ; 左列
    MyGui.Add("Text", "x30 y" yPos " w55 h20", currencyList[idx][1])
    MyGui.Add("Text", "x85 y" yPos " w50 h20 v" currencyList[idx][2], "0")
    ; 右列
    MyGui.Add("Text", "x220 y" yPos " w55 h20", currencyList[idx + 5][1])
    MyGui.Add("Text", "x275 y" yPos " w50 h20 v" currencyList[idx + 5][2], "0")
    yPos += 22
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
    Loop 3 {
        val := IniRead(CfgFile, "Prefix", "Check" A_Index, "0")
        MyGui["PrefixCheck" A_Index].Value := val
        val := IniRead(CfgFile, "Prefix", "Need" A_Index, "")
        MyGui["NeedsPrefix" A_Index].Value := val
    }
    ; 模块1: 后缀
    Loop 3 {
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
}

; 保存所有配置到ini文件
SaveAllConfig(*) {
    global CfgFile, MyGui
    ; 模块1: 前缀
    Loop 3 {
        IniWrite(MyGui["PrefixCheck" A_Index].Value, CfgFile, "Prefix", "Check" A_Index)
        IniWrite(MyGui["NeedsPrefix" A_Index].Value, CfgFile, "Prefix", "Need" A_Index)
    }
    ; 模块1: 后缀
    Loop 3 {
        IniWrite(MyGui["SuffixCheck" A_Index].Value, CfgFile, "Suffix", "Check" A_Index)
        IniWrite(MyGui["NeedsSuffix" A_Index].Value, CfgFile, "Suffix", "Need" A_Index)
    }
    ; 模块2: 改造模式
    Loop 6 {
        IniWrite(MyGui["ModCheck" A_Index].Value, CfgFile, "Modifiers", "Check" A_Index)
        IniWrite(MyGui["NeedsModifiers" A_Index].Value, CfgFile, "Modifiers", "Need" A_Index)
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
    Sleep 150
    Click("Right")
    Sleep 150
    
    MouseMove wupin_x, wupin_y
    Sleep 150
    Send "{Shift down}"
    Sleep 150

    Loop {
        Click() 
        Sleep 100
        
        A_Clipboard := ""
        Send "!^c" 
        if !ClipWait(0.5)
            continue
            
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
    Sleep 100
    Reload()
}
#HotIf