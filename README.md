# My AHK2 Scripts

[![Build and Release](https://github.com/14790897/My_AHK2_Scripts/actions/workflows/release.yml/badge.svg)](https://github.com/14790897/My_AHK2_Scripts/actions/workflows/release.yml)
[![GitHub release](https://img.shields.io/github/v/release/14790897/My_AHK2_Scripts)](https://github.com/14790897/My_AHK2_Scripts/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

AutoHotkey v2 脚本集合，包含实用的系统自动化工具。

## 🚀 快速开始

### 下载安装

**方式一：下载编译好的 exe（推荐）**

1. 进入 [Releases](https://github.com/14790897/My_AHK2_Scripts/releases) 页面
2. 下载最新版本的 `WindowIMEMemory.exe`
3. 双击运行即可使用

**方式二：克隆仓库运行脚本**

```bash
git clone https://github.com/14790897/My_AHK2_Scripts.git
cd My_AHK2_Scripts
# 需要先安装 AutoHotkey v2.0
AutoHotkey.exe WindowIMEMemory.ahk
```

## 快速导航

- [AutoLanguage](#1-autolanguageahk) - 自动切换输入法
- [FixMiddleClick](#2-fixmiddleclickahk) - 鼠标中键防抖动
- [WindowIMEMemory](#3-windowimememoryahk--windowimememoryexe) - 窗口输入法记忆 ⭐推荐

## 文件列表

| 文件 | 类型 | 说明 |
|------|------|------|
| `AutoLanguage.ahk` | 脚本 | 自动切换输入法工具 |
| `AutoLanguage.exe` | 可执行文件 | AutoLanguage 编译版本 |
| `WindowIMEMemory.ahk` | 脚本 | 窗口输入法记忆工具 |
| `WindowIMEMemory.exe` | 可执行文件 | WindowIMEMemory 编译版本 |
| `FixMiddleClick.ahk` | 脚本 | 鼠标中键防抖动工具 |
| `KeyMapping.ahk` | 脚本 | 键盘映射工具 |
| `ime_memory.ini` | 配置文件 | WindowIMEMemory 数据存储 |
| `compile.bat` | 批处理 | 编译脚本辅助工具 |

## 脚本说明

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

### 3. WindowIMEMemory.ahk / WindowIMEMemory.exe

**功能描述**：窗口输入法记忆工具

自动记忆并恢复每个应用程序的输入法状态，让每个应用保持独立的输入法设置。

**主要功能**：
- 🧠 **智能记忆**：自动记录每个应用最后使用的输入法状态
- 🔄 **自动切换**：切换应用时自动恢复对应的输入法状态
- 💾 **持久化存储**：输入法状态保存到本地文件，重启后依然生效
- 🚀 **开机自启动**：支持通过托盘菜单设置开机自启动
- 🎨 **系统托盘图标**：使用键盘图标，方便识别和管理
- 👑 **管理员权限**：自动请求管理员权限，确保对所有窗口生效

**使用方法**：

1. **直接运行 exe**（推荐）：
   ```
   双击 WindowIMEMemory.exe 即可运行
   ```

2. **运行 ahk 脚本**：
   ```
   AutoHotkey.exe WindowIMEMemory.ahk
   ```

**托盘菜单功能**：

右键点击系统托盘中的键盘图标，可以使用以下功能：
- **输入法记忆管理**：查看程序信息
- **设置开机自启动**：添加到Windows启动项
- **取消开机自启动**：从Windows启动项移除
- **重新加载**：重启程序
- **退出**：关闭程序

**编译为可执行文件**：

如果需要重新编译脚本，使用以下命令：
```powershell
& "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" `
  /in "WindowIMEMemory.ahk" `
  /out "WindowIMEMemory.exe" `
  /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
```

或使用提供的批处理文件：
```
compile.bat
```

**配置说明**：

脚本中的输入法 ID 配置：
```ahk2
LANG_EN := 0x0409   ; 英文输入法
LANG_CN := 0x0804   ; 中文输入法
```

记忆数据存储位置：
```ahk2
IME_DATA_FILE := A_ScriptDir "\ime_memory.ini"
```

**工作原理**：
1. 使用 Shell Hook 监听窗口切换事件
2. 切换窗口前保存当前窗口的输入法状态
3. 切换到新窗口后恢复该窗口的历史输入法状态
4. 使用定时器检测用户手动切换输入法，实时更新记忆

**技术特点**：
- 基于进程名识别应用，无需配置应用列表
- 记录输入法语言 ID 和转换模式（中文/英文状态）
- 内存 + 文件双重存储，快速响应且数据持久
- 自动请求管理员权限，支持所有系统窗口

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
- WindowIMEMemory 需要管理员权限才能对所有窗口生效（首次运行会自动请求）
- WindowIMEMemory 会在脚本目录下生成 `ime_memory.ini` 文件保存输入法记忆数据
- 对于某些杀毒软件或系统管理工具，可能需要添加脚本到白名单
- 修改脚本后需要重新启动脚本才能生效
- WindowIMEMemory 使用 `#SingleInstance Force`，运行时会自动关闭旧实例

## 常见问题


### Q: WindowIMEMemory 为什么需要管理员权限？

**A:** 管理员权限可以确保程序能够读取和控制所有窗口的输入法状态，包括任务管理器、UAC对话框等系统窗口。如果不使用管理员权限，部分窗口可能无法记忆输入法状态。

### Q: 如何清除输入法记忆数据？

**A:** 删除脚本目录下的 `ime_memory.ini` 文件，然后重启程序即可。

### Q: 编译后的 exe 文件可以单独使用吗？

**A:** 可以。编译后的 exe 文件包含了完整的 AutoHotkey v2 运行时，可以在任何 Windows 系统上独立运行，无需安装 AutoHotkey。

### Q: 如何卸载开机自启动？

**A:** 右键点击系统托盘图标，选择"取消开机自启动"，或者手动删除注册表项：
```
HKCU\Software\Microsoft\Windows\CurrentVersion\Run\WindowIMEMemory
```

## 开发说明

### 编译脚本

项目包含 `compile.bat` 批处理文件，可以快速编译 WindowIMEMemory：
```batch
compile.bat
```

或使用 PowerShell 命令：
```powershell
& "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" `
  /in "WindowIMEMemory.ahk" `
  /out "WindowIMEMemory.exe" `
  /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
```

### 自定义图标

将图标文件命名为 `WindowIMEMemory.ico` 并放在脚本目录下，重新编译后即可使用自定义图标。

### 自动发布 Release

项目配置了 GitHub Actions 自动构建流程。推送版本标签即可自动编译并发布：

```bash
# 创建版本标签
git tag -a v1.0.0 -m "Release version 1.0.0"

# 推送标签触发自动构建
git push origin v1.0.0
```

GitHub Actions 会自动：
- ✅ 使用官方 AutoHotkey Action 编译脚本（[Banaanae/Action-Ahk2Exe](https://github.com/Banaanae/Action-Ahk2Exe)）
- ✅ 生成独立可执行文件（exe）
- ✅ 创建 GitHub Release
- ✅ 上传编译文件和源码包

**特点**：
- 无需手动下载 AutoHotkey
- 支持 v1 和 v2 脚本
- 从 GitHub 仓库获取编译器（更快更稳定）
- 自动检测并编译所有 ahk 文件

详细说明请查看 [.github/RELEASE.md](.github/RELEASE.md)

## 🤝 参与贡献

欢迎提交 Issue 和 Pull Request！

详细的贡献指南请查看 [CONTRIBUTING.md](CONTRIBUTING.md)

## 📋 更新日志

查看 [CHANGELOG.md](CHANGELOG.md) 了解版本更新历史。

## 📚 相关链接

- [AutoHotkey v2 官方文档](https://www.autohotkey.com/docs/v2/)
- [项目 Issues](https://github.com/14790897/My_AHK2_Scripts/issues)
- [项目 Releases](https://github.com/14790897/My_AHK2_Scripts/releases)
- [GitHub Actions 工作流](.github/workflows/release.yml)

## 许可证

MIT License

## 作者

liuweiqing
