# flutter-ui Claude Code Skill Installer (Windows)
# DevCenter — https://devcenter.dev

$SkillName = "flutter-ui"
$SkillsDir = "$env:USERPROFILE\.claude\skills"
$Target = "$SkillsDir\$SkillName"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Source = "$ScriptDir\$SkillName"

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  flutter-ui — Claude Code Skill Installer" -ForegroundColor White
Write-Host "  DevCenter · https://devcenter.dev" -ForegroundColor Gray
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check source exists
if (-not (Test-Path "$Source\SKILL.md")) {
    Write-Host "❌  Error: flutter-ui\SKILL.md not found." -ForegroundColor Red
    Write-Host "   Run this script from the repo root:" -ForegroundColor Yellow
    Write-Host "   .\install.ps1" -ForegroundColor Yellow
    exit 1
}

# Create skills dir if needed
if (-not (Test-Path $SkillsDir)) {
    Write-Host "📁  Creating $SkillsDir" -ForegroundColor Gray
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}

# Handle existing install
if (Test-Path $Target) {
    Write-Host "⚠️   Existing install found at $Target" -ForegroundColor Yellow
    $confirm = Read-Host "   Overwrite? (y/N)"
    if ($confirm -notmatch '^[Yy]$') {
        Write-Host "   Cancelled." -ForegroundColor Gray
        exit 0
    }
    Remove-Item -Recurse -Force $Target
}

# Install
Write-Host "📦  Installing $SkillName to $Target" -ForegroundColor Cyan
Copy-Item -Recurse $Source $Target

# Verify
if (Test-Path "$Target\SKILL.md") {
    Write-Host ""
    Write-Host "✅  Installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "   Files installed:" -ForegroundColor Gray
    Get-ChildItem -Recurse $Target | Where-Object { -not $_.PSIsContainer } |
        ForEach-Object { Write-Host "   $($_.FullName.Replace($SkillsDir + '\', ''))" -ForegroundColor Gray }
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  How to use:"
    Write-Host "  1. Open Claude Code in your Flutter project"
    Write-Host "  2. Type: /flutter-ui"
    Write-Host "  3. Claude fills the checkpoint before any UI work"
    Write-Host ""
    Write-Host "  Run the audit script anytime:"
    Write-Host "  python $env:USERPROFILE\.claude\skills\flutter-ui\scripts\flutter_ui_audit.py ."
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "❌  Installation failed — SKILL.md not found at target." -ForegroundColor Red
    exit 1
}
