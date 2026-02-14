#Requires AutoHotkey v2.0
#SingleInstance Force

; ================= 配置区域 =================

; 定义英文输入法的 ID
LANG_EN := 0x0409
; 定义中文输入法的 ID
LANG_CN := 0x0804

; 输入法记忆数据文件路径
IME_DATA_FILE := A_ScriptDir "\ime_memory.ini"

; ================= 全局变量 =================

; 存储窗口与输入法的对应关系 (使用 Map 存储)
WindowIMEMap := Map()

; 当前活跃窗口标识
CurrentWindowID := ""

; ================= 脚本初始化 =================

; 加载已保存的输入法记忆
LoadIMEMemory()

; 注册 Shell Hook
MyListener := Gui()
MyListener.Opt("+LastFound")
hWnd := MyListener.Hwnd
DllCall("RegisterShellHookWindow", "UInt", hWnd)
MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
OnMessage(MsgNum, WindowChange)

; 监听输入法变化事件 (WM_INPUTLANGCHANGE = 0x51)
OnMessage(0x51, IMEChange)

Persistent(true)

; ================= 主要功能函数 =================

; 当窗口发生变化时触发
WindowChange(wParam, lParam, *) {
    ; 4 = HSHELL_WINDOWACTIVATED
    if (wParam == 4 || wParam == 32772) {
        hWnd := lParam
        
        try {
            ; 获取当前窗口的唯一标识
            WindowTitle := WinGetTitle("ahk_id " hWnd)
            ProcessName := WinGetProcessName("ahk_id " hWnd)
            ; 假设当前情况如下： 你打开了 记事本。ProcessName = "notepad.exe" WindowTitle = "日记.txt - 记事本" 执行这行代码后：WindowKey := "notepad.exe" . ":" . "日记.txt - 记事本"
            WindowKey := ProcessName . ":" . WindowTitle
            
            ; 如果之前有活跃窗口，保存其输入法状态
            if (CurrentWindowID != "") {
                SaveWindowIMEState(CurrentWindowID)
            }
            
            ; 更新当前窗口
            CurrentWindowID := WindowKey
            
            ; 恢复该窗口上次保存的输入法状态
            RestoreWindowIMEState(WindowKey)
        }
    }
}

; 当输入法状态发生变化时触发（例如用户按Shift切换输入法）
IMEChange(wParam, lParam, msg, hwnd) {
    try {
        ; 立即获取当前活动窗口信息并保存，避免时序问题
        if (hWnd := WinActive("A")) {
            WindowTitle := WinGetTitle("ahk_id " hWnd)
            ProcessName := WinGetProcessName("ahk_id " hWnd)
            WindowKey := ProcessName . ":" . WindowTitle
            
            ; 短暂延迟以确保输入法状态已经完全切换，然后立即保存
            SetTimer(() => SaveWindowIMEState(WindowKey), -30)
            
            ; 同时更新 CurrentWindowID（如果这是当前窗口）
            global CurrentWindowID
            CurrentWindowID := WindowKey
        }
    }
}

; 保存窗口的输入法状态
SaveWindowIMEState(WindowKey) {
    try {
        CurrentLangID := GetCurrentIME()
        CurrentConvMode := GetIMEConversionMode()
        
        ; 保存格式: "LangID|ConversionMode"
        StateString := CurrentLangID . "|" . CurrentConvMode
        WindowIMEMap[WindowKey] := StateString
        
        ; 同时保存到 ini 文件
        IniWrite(StateString, IME_DATA_FILE, "WindowIME", WindowKey)
    }
}

; 恢复窗口的输入法状态
RestoreWindowIMEState(WindowKey) {
    try {
        StateString := ""
        
        if (WindowIMEMap.Has(WindowKey)) {
            ; 从内存中获取历史状态
            StateString := WindowIMEMap[WindowKey]
        } else {
            ; 尝试从文件中读取
            StateString := IniRead(IME_DATA_FILE, "WindowIME", WindowKey, "")
        }

        if (StateString != "") {
            ; 解析状态字符串 "LangID|ConversionMode"
            Parts := StrSplit(StateString, "|")
            TargetLangID := Integer(Parts[1])
            
            ; 切换键盘布局
            SwitchIME(TargetLangID)
            
            ; 如果有转换模式信息，恢复该模式
            if (Parts.Length >= 2) {
                TargetConvMode := Integer(Parts[2])
                Sleep 100  ; 等待输入法切换完成
                SetIMEConversionMode(TargetConvMode)
            }
        } else {
            ; 第一次遇到这个窗口，记录当前状态但不切换
            CurrentLangID := GetCurrentIME()
            CurrentConvMode := GetIMEConversionMode()
            StateString := CurrentLangID . "|" . CurrentConvMode
            WindowIMEMap[WindowKey] := StateString
            ; 保存初始状态到文件
            IniWrite(StateString, IME_DATA_FILE, "WindowIME", WindowKey)
        }
    }
}

; 获取当前窗口的当前输入法
GetCurrentIME() {
    hWnd := WinActive("A")
    if !hWnd
        return LANG_CN
    
    ThreadID := DllCall("GetWindowThreadProcessId", "UInt", hWnd, "UInt", 0)
    CurLayout := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
    
    ; 提取低16位作为语言ID
    return (CurLayout & 0xFFFF)
}

; 获取当前的输入法转换模式
GetIMEConversionMode() {
    hWnd := WinActive("A")
    if !hWnd
        return 0
    
    DetectHiddenWindows(true)
    DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hWnd, "Uint")
    
    if (DefaultIMEWnd) {
        ; 0x283 = WM_IME_CONTROL, 0x001 = IMC_GETCONVERSIONMODE
        ConvMode := SendMessage(0x283, 0x001, 0, , "ahk_id " DefaultIMEWnd)
        DetectHiddenWindows(false)
        return ConvMode
    }
    
    DetectHiddenWindows(false)
    return 0
}

; 切换输入法
SwitchIME(LangID) {
    hWnd := WinActive("A")
    if !hWnd
        return

    ; 发送消息切换键盘布局 (0x50 = WM_INPUTLANGCHANGEREQUEST)
    PostMessage(0x50, 0, LangID, , "ahk_id " hWnd)
}

; 强制设置输入法转换模式
; Mode: 转换模式值（通常 0=英文, 1=中文, 1025=中文全拼）
SetIMEConversionMode(Mode) {
    hWnd := WinActive("A")
    if !hWnd
        return

    DetectHiddenWindows(true)
    DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hWnd, "Uint")
    
    if (DefaultIMEWnd) {
        ; 0x283 = WM_IME_CONTROL, 0x002 = IMC_SETCONVERSIONMODE
        SendMessage(0x283, 0x002, Mode, , "ahk_id " DefaultIMEWnd)
    }
    DetectHiddenWindows(false)
}

; ================= 数据持久化函数 =================

; 加载已保存的输入法记忆
LoadIMEMemory() {
    if (!FileExist(IME_DATA_FILE)) {
        return
    }
    
    try {
        ; 读取 ini 文件中的所有条目
        sections := IniRead(IME_DATA_FILE)
        
        ; 简单的实现：遍历所有键
        ; 注意：AHK2 的 IniRead 返回格式可能需要手动解析
        ; 这里采用更简单的方式：在需要时动态读取
    }
}

; ================= 快捷键（可选）=================

; 可以添加快捷键手动切换输入法
; Ctrl+Alt+E 切换到英文
^!e::
{
    if WinActive("A") {
        SwitchIME(LANG_EN)
        ToolTip "Switched to English"
        SetTimer(() => ToolTip(), 1000)
    }
}

; Ctrl+Alt+C 切换到中文
^!c::
{
    if WinActive("A") {
        SwitchIME(LANG_CN)
        ToolTip "Switched to Chinese"
        SetTimer(() => ToolTip(), 1000)
    }
}

; 输出调试信息的热键
F12::
{
    CurrentIME := GetCurrentIME()
    CurrentConvMode := GetIMEConversionMode()
    CurrentWindow := WinGetTitle("A")
    
    ; 解析转换模式
    ModeText := (CurrentConvMode = 0) ? "英文" : ((CurrentConvMode & 1) ? "中文" : "其他")
    
    ToolTip "当前输入法: " . Format("0x{:04X}", CurrentIME) 
        . "`n转换模式: " . CurrentConvMode . " (" . ModeText . ")"
        . "`n窗口: " . CurrentWindow
    SetTimer(() => ToolTip(), 3000)
}