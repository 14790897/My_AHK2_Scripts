#!/usr/bin/env pwsh
# 快速发版脚本
# 用法: .\release.ps1 v1.0.0 "Release description"

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$false)]
    [string]$Message = "Release $Version"
)

# 检查版本号格式
if ($Version -notmatch '^v\d+\.\d+\.\d+$') {
    Write-Error "版本号格式错误！应该是 vX.Y.Z 格式，如 v1.0.0"
    exit 1
}

# 检查是否有未提交的更改
$status = git status --porcelain
if ($status) {
    Write-Host "检测到未提交的更改：" -ForegroundColor Yellow
    Write-Host $status
    $confirm = Read-Host "是否先提交这些更改？(Y/n)"
    if ($confirm -ne 'n' -and $confirm -ne 'N') {
        git add .
        $commitMsg = Read-Host "输入提交信息"
        git commit -m $commitMsg
        git push origin main
    }
}

# 检查标签是否已存在
$existingTag = git tag -l $Version
if ($existingTag) {
    Write-Error "标签 $Version 已存在！"
    exit 1
}

Write-Host "`n准备创建发布：" -ForegroundColor Green
Write-Host "版本号：$Version"
Write-Host "描述：$Message"
Write-Host ""

$confirm = Read-Host "确认创建并推送标签？(Y/n)"
if ($confirm -eq 'n' -or $confirm -eq 'N') {
    Write-Host "已取消" -ForegroundColor Yellow
    exit 0
}

# 创建标签
Write-Host "`n创建标签..." -ForegroundColor Cyan
git tag -a $Version -m $Message

# 推送标签
Write-Host "推送标签到远程仓库..." -ForegroundColor Cyan
git push origin $Version

Write-Host "`n✅ 标签已推送！" -ForegroundColor Green
Write-Host "GitHub Actions 正在自动构建，请稍后查看："
Write-Host "https://github.com/14790897/My_AHK2_Scripts/actions" -ForegroundColor Blue
Write-Host "`n构建完成后可在此查看 Release："
Write-Host "https://github.com/14790897/My_AHK2_Scripts/releases" -ForegroundColor Blue
