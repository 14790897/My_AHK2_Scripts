#Requires AutoHotkey v2.0
#SingleInstance Force

; 强制以管理员权限运行（防止无法读取任务管理器等窗口的信息）
if not A_IsAdmin {
    try {
        Run "*RunAs " A_ScriptFullPath
    }
    ExitApp
}

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

; 当前活跃窗口标识（只用进程名）
CurrentWindowID := ""

; 当前活跃窗口句柄
CurrentWindowHwnd := 0

; 上次记录的输入法状态（用于检测变化）
LastIMEState := ""

; ================= 脚本初始化 =================

; 加载已保存的输入法记忆到内存
LoadIMEMemory()

; 注册 Shell Hook
MyListener := Gui()
MyListener.Opt("+LastFound")
hWnd := MyListener.Hwnd
DllCall("RegisterShellHookWindow", "UInt", hWnd)
MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
OnMessage(MsgNum, WindowChange)

; 启动定时器轮询 IME 状态变化（每 100ms 检测一次）
SetTimer(CheckIMEStateChange, 100)

Persistent(true)

; ================= 主要功能函数 =================

; 当窗口发生变化时触发
WindowChange(wParam, lParam, *) {
    ; 4 = HSHELL_WINDOWACTIVATED, 32772 = RDP/全屏
    if (wParam == 4 || wParam == 32772) {
        NewHwnd := lParam

        try {
            if !WinExist("ahk_id " NewHwnd)
                return

            ; 获取新窗口的进程名
            NewProcessName := WinGetProcessName("ahk_id " NewHwnd)
            NewWindowKey := NewProcessName

            ; ===== 关键修复：先保存旧窗口的状态 =====
            ; 必须在窗口切换前，用旧窗口句柄获取旧窗口的 IME 状态
            if (CurrentWindowHwnd != 0 && CurrentWindowID != "") {
                ; 只有当旧窗口还存在时才保存(防止窗口关闭后报错)
                if WinExist("ahk_id " CurrentWindowHwnd) {
                    SaveWindowIMEStateByHwnd(CurrentWindowID, CurrentWindowHwnd)
                }
            }

            ; 更新当前窗口信息
            global CurrentWindowID, CurrentWindowHwnd, LastIMEState
            CurrentWindowID := NewWindowKey
            CurrentWindowHwnd := NewHwnd

            ; 恢复新窗口的输入法状态
            RestoreWindowIMEState(NewWindowKey)

            ; 更新初始 IME 状态记录，防止切回来瞬间误判为状态变化
            LastIMEState := GetIMEStateByHwnd(NewHwnd)
        }
    }
}

; 定时检测 IME 状态变化（监听 Shift 切换）
CheckIMEStateChange() {
    global CurrentWindowID, CurrentWindowHwnd, LastIMEState

    if (CurrentWindowHwnd == 0 || CurrentWindowID == "")
        return

    ; 只有当窗口是活跃状态时才检测（防止后台误读）
    if (WinActive("A") != CurrentWindowHwnd)
        return

    ; 获取当前 IME 状态
    CurrentState := GetIMEStateByHwnd(CurrentWindowHwnd)

    ; 如果状态变化了，保存新状态
    if (CurrentState != "" && CurrentState != LastIMEState) {
        SaveWindowIMEStateByHwnd(CurrentWindowID, CurrentWindowHwnd)
        LastIMEState := CurrentState
    }
}

; 根据窗口句柄获取 IME 状态字符串
GetIMEStateByHwnd(hWnd) {
    if !hWnd
        return ""

    try {
        LangID := GetIMEByHwnd(hWnd)
        ConvMode := GetIMEConversionModeByHwnd(hWnd)
        return LangID . "|" . ConvMode
    }
    return ""
}

; 根据窗口句柄保存 IME 状态
SaveWindowIMEStateByHwnd(WindowKey, hWnd) {
    try {
        StateString := GetIMEStateByHwnd(hWnd)
        if (StateString != "") {
            WindowIMEMap[WindowKey] := StateString
            ; 同时保存到 ini 文件
            IniWrite(StateString, IME_DATA_FILE, "WindowIME", WindowKey)
        }
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
            ; 如果读到了，也更新进内存 Map，下次就不用读文件了
            if (StateString != "")
                WindowIMEMap[WindowKey] := StateString
        }

        if (StateString != "") {
            ; 解析状态字符串 "LangID|ConversionMode"
            Parts := StrSplit(StateString, "|")
            TargetLangID := Integer(Parts[1])

            ; 切换键盘布局
            SwitchIME(TargetLangID)

            ; 如果有转换模式信息，且是中文模式下，恢复该模式
            if (Parts.Length >= 2 && TargetLangID == LANG_CN) {
                TargetConvMode := Integer(Parts[2])
                Sleep 50  ; 给系统一点时间反应
                SetIMEConversionMode(TargetConvMode)
            }
        } else {
            ; 第一次遇到这个窗口，记录当前状态但不切换
            CurrentLangID := GetCurrentIME()
            CurrentConvMode := GetIMEConversionMode()
            StateString := CurrentLangID . "|" . CurrentConvMode
            WindowIMEMap[WindowKey] := StateString
            IniWrite(StateString, IME_DATA_FILE, "WindowIME", WindowKey)
        }
    }
}

; 获取当前窗口的当前输入法
GetCurrentIME() {
    hWnd := WinActive("A")
    if !hWnd
        return LANG_CN
    return GetIMEByHwnd(hWnd)
}

; 根据窗口句柄获取输入法
GetIMEByHwnd(hWnd) {
    if !hWnd
        return LANG_CN

    try {
        ThreadID := DllCall("GetWindowThreadProcessId", "UInt", hWnd, "UInt", 0)
        CurLayout := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
        return (CurLayout & 0xFFFF)
    }
    return LANG_CN
}

; 获取当前的输入法转换模式
GetIMEConversionMode() {
    hWnd := WinActive("A")
    if !hWnd
        return 0
    return GetIMEConversionModeByHwnd(hWnd)
}

; 根据窗口句柄获取输入法转换模式
GetIMEConversionModeByHwnd(hWnd) {
    if !hWnd
        return 0

    DetectHiddenWindows(true)
    try {
        DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hWnd, "Uint")
        if (DefaultIMEWnd) {
            ; 0x283 = WM_IME_CONTROL, 0x001 = IMC_GETCONVERSIONMODE
            ConvMode := SendMessage(0x283, 0x001, 0, , "ahk_id " DefaultIMEWnd)
            DetectHiddenWindows(false)
            return ConvMode
        }
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
SetIMEConversionMode(Mode) {
    hWnd := WinActive("A")
    if !hWnd
        return

    DetectHiddenWindows(true)
    try {
        DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hWnd, "Uint")
        if (DefaultIMEWnd) {
            ; 0x283 = WM_IME_CONTROL, 0x002 = IMC_SETCONVERSIONMODE
            SendMessage(0x283, 0x002, Mode, , "ahk_id " DefaultIMEWnd)
        }
    }
    DetectHiddenWindows(false)
}

; ================= 数据持久化函数 =================

; 加载已保存的输入法记忆到内存 Map
LoadIMEMemory() {
    if (!FileExist(IME_DATA_FILE)) {
        return
    }

    try {
        ; 读取整个 Section
        Content := IniRead(IME_DATA_FILE, "WindowIME")

        ; 遍历每一行解析
        Loop Parse, Content, "`n", "`r" {
            if (A_LoopField = "")
                continue

            ; 分割 Key=Value
            Parts := StrSplit(A_LoopField, "=", , 2)
            if (Parts.Length = 2) {
                Key := Parts[1]
                Value := Parts[2]
                WindowIMEMap[Key] := Value
            }
        }
    }
}

; ================= 调试热键 =================
F12::
{
    global CurrentWindowID, CurrentWindowHwnd, LastIMEState

    CurrentIME := GetCurrentIME()
    CurrentConvMode := GetIMEConversionMode()
    CurrentProcess := WinGetProcessName("A")

    ModeText := (CurrentConvMode = 0) ? "英文" : ((CurrentConvMode & 1) ? "中文" : "其他")
    SavedState := WindowIMEMap.Has(CurrentProcess) ? WindowIMEMap[CurrentProcess] : "无记录"

    ToolTip "当前输入法: " . Format("0x{:04X}", CurrentIME)
        . "`n转换模式: " . CurrentConvMode . " (" . ModeText . ")"
        . "`n进程名: " . CurrentProcess
        . "`n已保存: " . SavedState
        . "`n上一次: " . LastIMEState
    SetTimer(() => ToolTip(), 5000)
}