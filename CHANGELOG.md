# 更新日志

所有重要的项目更改都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### 改进
- ♻️ 使用官方 GitHub Action (Banaanae/Action-Ahk2Exe) 替代手动下载编译器
- 📝 添加 Actions 对比文档 (.github/ACTIONS_COMPARISON.md)
- ⚡ 简化 workflow 配置，提高构建速度和稳定性
- 🔒 从 GitHub 仓库获取编译器（绕过 Cloudflare DDoS 保护）

### 计划功能
- [ ] 支持多显示器独立设置
- [ ] 添加黑白名单功能
- [ ] 支持导入导出配置

## [1.0.0] - 2026-02-15

### 新增
- ✨ WindowIMEMemory - 窗口输入法记忆工具
  - 自动记忆每个应用的输入法状态
  - 支持输入法语言和转换模式记忆
  - 持久化存储到本地文件
  - 系统托盘菜单管理
  - 开机自启动设置功能
  - 使用键盘图标标识
  - 自动请求管理员权限
  
- 🚀 GitHub Actions 自动构建和发布
  - 推送标签自动编译 exe
  - 自动创建 GitHub Release
  - 自动上传编译文件和源码包
  
- 📝 完善的项目文档
  - README.md 详细使用说明
  - CONTRIBUTING.md 贡献指南
  - .github/RELEASE.md 发布说明
  - 快速发版脚本 release.ps1

### 修复
- 🐛 修复 MsgBox 图标选项错误
- 🐛 修复编译时缺少 base 参数的问题

### 优化
- ♻️ 移除调试用的 F12 热键
- 📦 优化编译流程
- 🎨 改进托盘菜单动态显示

## [0.2.0] - 历史版本

### 包含
- AutoLanguage - 基于应用列表的输入法自动切换
- FixMiddleClick - 鼠标中键防抖动工具
- KeyMapping - 键盘映射工具

---

## 图例

- ✨ 新功能 (feat)
- 🐛 Bug 修复 (fix)
- 📝 文档 (docs)
- 🎨 代码格式 (style)
- ♻️ 重构 (refactor)
- ⚡ 性能优化 (perf)
- ✅ 测试 (test)
- 🔧 配置 (chore)
- 🚀 部署 (deploy)
- 📦 打包 (build)
