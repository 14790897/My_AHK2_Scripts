#Requires AutoHotkey v2.0
#SingleInstance Force

; ========================================================
; 鼠标中键防抖动脚本 (AutoHotkey v2)
; ========================================================

*MButton::
{
    ; 设置防抖动阈值 (单位: 毫秒)
    ; 如果你的鼠标连击非常严重，可以适当调大这个数字 (例如 250 或 300)
    static threshold := 200
    
    ; 记录上一次有效点击的时间 (static 变量会记住上一次的值)
    static last_click_time := 0
    
    current_time := A_TickCount

    ; 如果当前时间 - 上次时间 < 阈值，则视为误触（连击），直接忽略
    if (current_time - last_click_time < threshold)
    {
        return
    }

    ; 更新最后一次有效点击时间
    last_click_time := current_time

    ; 发送中键按下信号
    ; {Blind} 确保如果你同时按着 Ctrl 或 Shift，组合键依然有效
    Send "{Blind}{MButton Down}"

    ; 等待物理按键松开（支持长按中键进行拖拽/滚屏）
    KeyWait "MButton"

    ; 发送中键松开信号
    Send "{Blind}{MButton Up}"
}