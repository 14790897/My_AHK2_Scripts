; if not A_IsAdmin
; {
;     Run "*RunAs `"" A_ScriptFullPath "`""
;     ExitApp
; }

#Requires AutoHotkey v2.0
#SingleInstance Force

; ================= 配置区域 =================

; 定义英文输入法的 ID (0x0409 是美式英语)
LANG_EN := 0x0409
; 定义中文输入法的 ID (0x0804 是简体中文)
LANG_CN := 0x0804

; 创建一个名为 "EnglishApps" 的分组
GroupAdd "EnglishApps", "ahk_exe WindowsTerminal.exe"  ; Windows Terminal
; GroupAdd "EnglishApps", "ahk_exe cmd.exe"              ; CMD
GroupAdd "EnglishApps", "ahk_exe powershell.exe"       ; PowerShell
GroupAdd "EnglishApps", "ahk_exe Termius.exe"          ; Termius
; GroupAdd "EnglishApps", "ahk_exe Code.exe"             ; VS Code

; ================= 脚本逻辑 =================

; 注册 Shell Hook
; 1. 关键修改：把 Gui 对象赋值给一个变量 (MyListener)，防止被自动回收
MyListener := Gui()

; 2. 设置为“最后找到的窗口” (依然保留这步，为了兼容性)
MyListener.Opt("+LastFound")

; 3. 直接从对象获取句柄 (比 WinExist 更稳)
hWnd := MyListener.Hwnd

; 4. 注册钩子
DllCall("RegisterShellHookWindow", "UInt", hWnd)
MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
OnMessage(MsgNum, WindowChange)

; 5. 显式声明脚本为持久运行 (防止因为没有 GUI 显示而自动退出)
Persistent(true)

; 当窗口发生变化时触发此函数
WindowChange(wParam, lParam, *) {
    ; 4 = HSHELL_WINDOWACTIVATED, 32772 = RNC_WINDOWACTIVATED
    if (wParam == 4 || wParam == 32772) {
        try {
            if WinActive("ahk_group EnglishApps") {
                SwitchIME(LANG_EN)
            } else {
                SwitchIME(LANG_CN)
            }
        }
    }
}

; 切换输入法的核心函数
SwitchIME(LangID) {
    hWnd := WinActive("A")
    if !hWnd
        return

    ; 1. 发送消息切换键盘布局 (0x50 = WM_INPUTLANGCHANGEREQUEST)
    PostMessage(0x50, 0, LangID, , "ahk_id " hWnd)

    ; 2. 【关键修改】如果是切换到中文，强制设置为“中文模式”
    if (LangID == LANG_CN) {
        ; 给一点缓冲时间让输入法先加载
        Sleep 50 
        ; 强制设置转换模式为“中文”
        SetIMEConversionMode(1) 
    }
}

; ================= 辅助函数：强制设置输入法模式 =================
; Mode 1 = 中文 (Native)
; Mode 0 = 英文 (Alphanumeric)
SetIMEConversionMode(Mode) {
    hWnd := WinActive("A")
    if !hWnd
        return

    ; 获取默认 IME 窗口的句柄
    DetectHiddenWindows(true)
    DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hWnd, "Uint")
    
    if (DefaultIMEWnd) {
        ; WM_IME_CONTROL = 0x283
        ; IMC_SETCONVERSIONMODE = 0x002
        ; 1025 = IME_CMODE_NATIVE (1) | IME_CMODE_CHINESE (1024)
        ; 简单的 1 也可以代表 Native 模式
        
        targetMode := (Mode == 1) ? 1025 : 0
        SendMessage(0x283, 0x002, targetMode, , "ahk_id " DefaultIMEWnd)
    }
    DetectHiddenWindows(false)
}

; 还原 Insert 变 F6 的功能
Insert::F6

; 禁用 CapsLock 原本的大写锁定功能
SetCapsLockState "AlwaysOff"

; 按下 CapsLock 切换中英文
CapsLock::
{
    ; 获取当前键盘布局
    hWnd := WinActive("A")
    ThreadID := DllCall("GetWindowThreadProcessId", "UInt", hWnd, "UInt", 0)
    CurLayout := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
    
    ; 如果低位是 0x0409 (英文)，就切中文
    if ((CurLayout & 0xFFFF) == 0x0409)
        PostMessage(0x50, 0, 0x0804, , "ahk_id " hWnd)
    else
        PostMessage(0x50, 0, 0x0409, , "ahk_id " hWnd)
}