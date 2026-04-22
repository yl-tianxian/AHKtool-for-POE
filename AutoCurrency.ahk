#Requires AutoHotkey v2.0

WinGetClientPos &X, &Y, &PoeW, &PoeH, "流放之路"

; 1. 定义原始坐标
rawCoords := Map(
    "tuibian",  [32,  153],
    "gaizao",   [63,  153],
    "fuhao",    [243, 153],
    "E",        [169, 153],
    "boli",     [95,  153],
    "dianjin",  [275, 153],
    "C",        [306, 153],
    "zengfu",   [127, 186],
    "chongzhu", [243, 224],
    "wupin",    [186, 255]
)

; 2. 计算缩放比例
scaleFactor := PoeH / 600

; --- 核心功能函数 ---

; 函数：右键点击指定名称的货币
; 用法: ClickCurrency("gaizao")
UseCurrency(name) {
    global rawCoords, scaleFactor, X, Y ; 获取窗口偏移量 X, Y 如果需要绝对坐标
    
    if !rawCoords.Has(name) {
        MsgBox "错误: 找不到物品坐标 '" name "'"
        return
    }
    
    coords := rawCoords[name]
    ; 计算实际坐标并取整
    finalX := Round(coords[1] * scaleFactor)
    finalY := Round(coords[2] * scaleFactor)
    
    ; 注意：WinGetClientPos 获取的是客户区位置。
    ; 如果 Click 命令默认使用屏幕绝对坐标，需要加上窗口偏移量 X, Y
    ; 如果使用了 CoordMode "Pixel", "Client" 或 "Window"，则不需要加 X, Y
    ; 这里假设使用 Client 模式或相对坐标，根据实际情况调整：
    
    ; 方式 A: 如果设置了 CoordMode "Mouse", "Client" (推荐)
    Click finalX, finalY, "Right" ; 右键点击
    
    ; 方式 B: 如果使用屏幕绝对坐标 (默认)
    ; Click X + finalX, Y + finalY
}

; --- 使用示例 ---

; 设置鼠标坐标模式为客户区模式，这样坐标就是相对于游戏窗口左上角的
CoordMode "Mouse", "Client" 

; ; 现在点击非常简洁，不需要任何中间变量
; Sleep 3000
; UseCurrency("gaizao")
; Sleep 500
; UseCurrency("chongzhu")
; Sleep 500
; UseCurrency("tuibian")

; --- GUI 界面 ---

; 模块1变量
global NeedsPrefix1 := "", NeedsPrefix2 := "", NeedsPrefix3 := ""
global NeedsSuffix1 := "", NeedsSuffix2 := "", NeedsSuffix3 := ""

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
    MyGui.Add("Edit", "x60 y" yPos " w340 h26 vNeedsPrefix" A_Index, NeedsPrefix%A_Index%)
    yPos += 30
}

; Suffix 标签和输入框（带复选框）
MyGui.Add("Text", "x35 y150 w80 h20", "后缀:")
yPos := 175
loop 3 {
    MyGui.Add("CheckBox", "x35 y" yPos " w18 h22 vSuffixCheck" A_Index, "")
    MyGui.Add("Edit", "x60 y" yPos " w340 h26 vNeedsSuffix" A_Index, NeedsSuffix%A_Index%)
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
MyGui.Add("Button", "x30 y725 w100 h30", "开始")
MyGui.Add("Button", "x150 y725 w100 h30", "停止")
MyGui.Add("Button", "x270 y725 w100 h30", "保存配置")

; 显示窗口
MyGui.Show("w440 h770")

; 更新通货余额的函数（供后续调用）
UpdateCurrencyCount(name, value) {
    global MyGui
    try {
        MyGui[name].Text := value
    }
}