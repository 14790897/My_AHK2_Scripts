# GitHub Actions 使用说明

## 自动发布 Release

本项目配置了自动构建和发布流程，当您推送版本标签时会自动触发。

### 📋 使用步骤

#### 1. 创建版本标签

在本地创建并推送标签：

```bash
# 创建标签（例如 v1.0.0）
git tag -a v1.0.0 -m "Release version 1.0.0"

# 推送标签到 GitHub
git push origin v1.0.0
```

#### 2. 自动构建

推送标签后，GitHub Actions 会自动：
1. ✅ 下载 AutoHotkey v2
2. ✅ 编译 WindowIMEMemory.ahk 为 exe
3. ✅ 编译 AutoLanguage.ahk 为 exe（如果存在）
4. ✅ 创建 GitHub Release
5. ✅ 上传编译好的 exe 文件
6. ✅ 打包源代码并上传

#### 3. 查看 Release

构建完成后，在 GitHub 仓库页面的 "Releases" 标签页可以看到新的 Release。

### 🔧 手动触发

也可以在 GitHub 网页上手动触发：

1. 进入仓库的 "Actions" 标签页
2. 选择 "Build and Release" workflow
3. 点击 "Run workflow"
4. 选择分支并运行

### 📝 版本号规范

建议使用语义化版本号：

- `v1.0.0` - 主要版本（重大更新）
- `v1.1.0` - 次要版本（新功能）
- `v1.0.1` - 补丁版本（bug 修复）

### ⚠️ 注意事项

1. **标签格式**：标签必须以 `v` 开头（如 `v1.0.0`）
2. **权限**：确保仓库设置中启用了 Actions 的写入权限
3. **首次运行**：第一次运行可能需要稍等片刻

### 🔍 查看构建日志

如果构建失败：
1. 进入 "Actions" 标签页
2. 点击失败的 workflow 运行
3. 查看详细日志定位问题

### 🎯 快速发布示例

```bash
# 1. 确保所有更改已提交
git add .
git commit -m "Update: improve IME memory feature"

# 2. 创建并推送标签
git tag -a v1.0.0 -m "First stable release"
git push origin main
git push origin v1.0.0

# 3. 等待 GitHub Actions 自动构建完成
# 4. 在 Releases 页面下载编译好的文件
```

### 📦 Release 包含内容

每个 Release 自动包含：
- `WindowIMEMemory.exe` - 主程序
- `AutoLanguage.exe` - 辅助工具（如果存在）
- `Source-vX.X.X.zip` - 源代码打包

### 🛠️ 自定义 Workflow

如需修改构建流程，编辑：
```
.github/workflows/release.yml
```

主要配置项：
- AutoHotkey 版本
- 编译参数
- Release 描述
- 上传的文件列表
