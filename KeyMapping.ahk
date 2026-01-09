#Requires AutoHotkey v2.0
#SingleInstance Force

; ================= 按键映射脚本 =================
; 功能：自定义按键映射和快捷键

; ================= 配置区域 =================

; 定义英文输入法的 ID (0x0409 是美式英语)
LANG_EN := 0x0409
; 定义中文输入法的 ID (0x0804 是简体中文)
LANG_CN := 0x0804

; ================= 按键映射 =================

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
