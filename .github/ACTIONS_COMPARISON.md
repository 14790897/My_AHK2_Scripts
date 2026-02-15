# AutoHotkey GitHub Actions 对比

本文档列出了 GitHub Marketplace 上可用的 AutoHotkey 编译 Actions。

## 🎯 推荐使用

### ⭐ Banaanae/Action-Ahk2Exe

**当前项目使用**

- **链接**: [Marketplace](https://github.com/marketplace/actions/compile-ahk-script) | [源码](https://github.com/Banaanae/Action-Ahk2Exe)
- **版本**: v1.0.3
- **支持**: v1 和 v2
- **Star数**: 2

**优点**：
- ✅ 从 GitHub 仓库获取编译器（绕过 Cloudflare DDoS 保护）
- ✅ 同时支持 AutoHotkey v1 和 v2
- ✅ 可指定版本（通过 GitHub tag）
- ✅ 简单易用，参数清晰
- ✅ 持续维护

**使用示例**：
```yaml
- name: Compile Script
  uses: Banaanae/Action-Ahk2Exe@v1.0.3
  with:
    in: MyScript.ahk
    out: MyScript.exe
    version: latest    # 可选
    bits: 64          # 可选
```

**参数说明**：
- `in`: 输入脚本文件（必需）
- `out`: 输出文件名（可选）
- `version`: AutoHotkey 版本，可以是 GitHub tag 或 `latest`（可选）
- `bits`: 编译位数 32/64，v1 还可指定文本编码（可选）

---

## 📋 其他可用 Actions

### CCCC-L/Action-Ahk2Exe

- **链接**: [Marketplace](https://github.com/marketplace/actions/compile-ahkv2-script)
- **版本**: v1.0.0
- **支持**: 仅 v2
- **Star数**: 4

**特点**：
- 专注于 AutoHotkey v2
- 简单的参数设置

**使用示例**：
```yaml
- name: Compile Script
  uses: CCCC-L/Action-Ahk2Exe@main
  with:
    in: example.ahk
    out: example.exe  # 可选
    base: 64          # 可选: 32 或 64
```

---

### 其他 Actions（未详细测试）

以下 Actions 在 GitHub Marketplace 可用，但未进行详细测试：

1. **AutoHotkey Build**
   - [Marketplace](https://github.com/marketplace/actions/autohotkey-build)

2. **Compile AutoHotkey**
   - [Marketplace](https://github.com/marketplace/actions/compile-autohotkey)

3. **Compile AutoHotkey Script**
   - [Marketplace](https://github.com/marketplace/actions/compile-autohotkey-script)

4. **Ahk2Exe Action**
   - [Marketplace](https://github.com/marketplace/actions/ahk2exe-action)

5. **AHK2Exe GitHub Action**
   - [Marketplace](https://github.com/marketplace/actions/ahk2exe-github-action)

6. **Install AutoHotkey**
   - [Marketplace](https://github.com/marketplace/actions/install-autohotkey)
   - 用途：安装 AutoHotkey 并添加到 PATH，而不是编译

---

## 🔍 选择建议

### 如果你的项目...

- **只使用 v2 脚本** → 可以选择 `CCCC-L/Action-Ahk2Exe` 或 `Banaanae/Action-Ahk2Exe`
- **同时有 v1 和 v2 脚本** → 必须使用 `Banaanae/Action-Ahk2Exe`
- **需要指定特定版本** → 使用 `Banaanae/Action-Ahk2Exe`（支持 version 参数）
- **遇到网络问题** → 使用 `Banaanae/Action-Ahk2Exe`（从 GitHub 获取，更稳定）

### 为什么选择 Banaanae/Action-Ahk2Exe？

1. **稳定性**: 从 GitHub 仓库获取编译器，避免 Cloudflare 阻拦
2. **兼容性**: 支持 v1 和 v2，适合混合项目
3. **灵活性**: 可指定版本、位数等多个参数
4. **活跃度**: 有多个贡献者，持续维护

---

## 📝 注意事项

### 所有 Actions 的共同限制

1. **仅支持 Windows**: 所有编译 Actions 都要求 `runs-on: windows-latest`
2. **权限要求**: 需要在 workflow 中设置 `permissions: contents: write` 才能创建 Release
3. **一次一个文件**: 大多数 Action 每次只能编译一个脚本

### 使用建议

- 在 workflow 中使用 `continue-on-error: true` 处理可选脚本
- 使用 `if: success()` 或 `if: always()` 控制后续步骤
- 定期检查 Action 更新，保持使用最新版本

---

## 🔗 相关资源

- [AutoHotkey 官网](https://www.autohotkey.com/)
- [AutoHotkey v2 文档](https://www.autohotkey.com/docs/v2/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [GitHub Marketplace](https://github.com/marketplace?type=actions)

---

**最后更新**: 2026-02-15  
**当前项目使用**: Banaanae/Action-Ahk2Exe@v1.0.3
