# 贡献指南

感谢您对本项目的关注！

## 🤝 如何贡献

### 报告问题

如果您发现 bug 或有功能建议：

1. 在 [Issues](https://github.com/14790897/My_AHK2_Scripts/issues) 页面搜索是否已有相关问题
2. 如果没有，创建新的 Issue，并详细描述：
   - **Bug 报告**：系统版本、复现步骤、预期行为、实际行为
   - **功能建议**：使用场景、期望功能、可能的实现方式

### 提交代码

1. **Fork 本仓库**
   ```bash
   # 克隆您的 fork
   git clone https://github.com/YOUR_USERNAME/My_AHK2_Scripts.git
   cd My_AHK2_Scripts
   ```

2. **创建功能分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **进行修改**
   - 保持代码风格一致
   - 添加必要的注释
   - 测试您的修改

4. **提交更改**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **推送到您的 fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **创建 Pull Request**
   - 在 GitHub 上创建 PR
   - 描述您的更改和原因
   - 等待审核

## 📝 代码规范

### AutoHotkey 脚本

- 使用 4 个空格缩进
- 变量名使用 PascalCase（如 `WindowIMEMap`）
- 函数名使用 PascalCase（如 `GetCurrentIME()`）
- 添加清晰的注释说明功能

### 提交信息格式

使用语义化提交信息：

```
<type>: <subject>

[optional body]
```

类型（type）：
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构代码
- `test`: 添加测试
- `chore`: 构建过程或辅助工具的变动

示例：
```
feat: add auto-start configuration in tray menu

- Add registry check function
- Add enable/disable auto-start options
- Update tray menu dynamically
```

## 🧪 测试

在提交前请测试：

1. **功能测试**
   - 在 Windows 10/11 上运行脚本
   - 测试各个功能是否正常
   - 检查是否有错误提示

2. **编译测试**
   ```powershell
   .\compile.bat
   # 或
   & "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "WindowIMEMemory.ahk" /out "WindowIMEMemory.exe" /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
   ```

3. **运行测试**
   - 测试 exe 文件是否能正常运行
   - 检查托盘菜单功能
   - 验证开机自启动设置

## 📋 开发环境

### 必需软件

- [AutoHotkey v2.0+](https://www.autohotkey.com/)
- Git
- 文本编辑器（推荐 VS Code + AutoHotkey v2 扩展）

### VS Code 配置（推荐）

安装扩展：
1. AutoHotkey v2 Language Support
2. GitLens

## 🔖 发布流程

维护者发布新版本：

1. 更新版本号和 CHANGELOG
2. 运行快速发版脚本：
   ```powershell
   .\release.ps1 v1.0.0 "Release description"
   ```
3. GitHub Actions 自动构建和发布

## 📄 许可证

提交代码即表示您同意将代码按照 MIT 许可证发布。

## ❓ 问题

如有任何问题，欢迎：
- 创建 [Issue](https://github.com/14790897/My_AHK2_Scripts/issues)
- 发起 [Discussion](https://github.com/14790897/My_AHK2_Scripts/discussions)

感谢您的贡献！🎉
