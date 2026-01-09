# My AHK2 Scripts

AutoHotkey v2 脚本集合，包含实用的系统自动化工具。

## 脚本说明

### 1. AutoLanguage.ahk

**功能描述**：自动切换输入法脚本

根据当前活动窗口的应用自动切换输入法，提高多语言工作效率。

**主要功能**：
- 监听窗口变化事件
- 英文应用群组自动切换到英文输入法 (US)
- 其他应用自动切换到中文输入法
- 支持的英文应用：
  - Windows Terminal
  - PowerShell
  - Termius

**配置方式**：

修改脚本中的以下变量来自定义语言 ID：
```ahk2
LANG_EN := 0x0409   ; 美式英语
LANG_CN := 0x0804   ; 简体中文
```

在 `EnglishApps` 群组中添加或移除应用：
```ahk2
GroupAdd "EnglishApps", "ahk_exe WindowsTerminal.exe"
GroupAdd "EnglishApps", "ahk_exe powershell.exe"
; 添加更多应用...
```

---

### 2. FixMiddleClick.ahk

**功能描述**：鼠标中键防抖动脚本

解决鼠标中键容易连击或误触的问题。

**主要功能**：
- 自动检测并过滤鼠标中键的误触
- 支持长按中键进行拖拽和滚屏
- 防抖动阈值可自定义

**防抖动阈值调整**：

默认防抖动延迟为 200 毫秒，可根据鼠标情况调整：
```ahk2
static threshold := 200  ; 单位：毫秒（可调大以解决严重连击问题）
```

---

## 系统要求

- Windows 系统
- AutoHotkey v2.0 及以上
- 管理员权限（可选，某些功能可能需要）

## 使用方法

1. 下载 [AutoHotkey v2.0](https://www.autohotkey.com/)
2. 将脚本文件 (`.ahk`) 双击运行，或在命令行执行：
   ```
   AutoHotkey.exe 脚本名.ahk
   ```
3. 脚本将在后台持久运行

## 注意事项

- AutoLanguage.ahk 需要启用 Shell Hook 功能来监听窗口变化
- 对于某些杀毒软件或系统管理工具，可能需要添加脚本到白名单
- 修改脚本后需要重新启动脚本才能生效

## 许可证

MIT License

## 作者

liuweiqing
