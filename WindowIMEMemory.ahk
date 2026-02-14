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

; 保存窗口的输入法状态
SaveWindowIMEState(WindowKey) {
    try {
        CurrentLangID := GetCurrentIME()
        WindowIMEMap[WindowKey] := CurrentLangID
        ; 同时保存到 ini 文件
        IniWrite(CurrentLangID, IME_DATA_FILE, "WindowIME", WindowKey)
    }
}

; 恢复窗口的输入法状态
RestoreWindowIMEState(WindowKey) {
    try {
        if (WindowIMEMap.Has(WindowKey)) {
            ; 从内存中获取
            TargetLangID := WindowIMEMap[WindowKey]
        } else {
            ; 尝试从文件中读取
            TargetLangID := IniRead(IME_DATA_FILE, "WindowIME", WindowKey, LANG_CN)
        }
        
        ; 切换输入法
        SwitchIME(TargetLangID)
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

; 切换输入法
SwitchIME(LangID) {
    hWnd := WinActive("A")
    if !hWnd
        return

    ; 发送消息切换键盘布局 (0x50 = WM_INPUTLANGCHANGEREQUEST)
    PostMessage(0x50, 0, LangID, , "ahk_id " hWnd)

    ; 如果切换到中文，强制设置转换模式
    if (LangID == LANG_CN) {
        Sleep 50 
        SetIMEConversionMode(1) 
    } else if (LangID == LANG_EN) {
        Sleep 50
        SetIMEConversionMode(0)
    }
}

; 强制设置输入法模式
; Mode 1 = 中文 (Native)
; Mode 0 = 英文 (Alphanumeric)
SetIMEConversionMode(Mode) {
    hWnd := WinActive("A")
    if !hWnd
        return

    DetectHiddenWindows(true)
    DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hWnd, "Uint")
    
    if (DefaultIMEWnd) {
        targetMode := (Mode == 1) ? 1025 : 0
        SendMessage(0x283, 0x002, targetMode, , "ahk_id " DefaultIMEWnd)
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
    CurrentWindow := WinGetTitle("A")
    ToolTip "Current IME: " . Format("0x{:04X}", CurrentIME) . "`nWindow: " . CurrentWindow
    SetTimer(() => ToolTip(), 2000)
}
