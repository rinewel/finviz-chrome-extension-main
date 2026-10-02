@echo off
chcp 65001 >nul
setlocal
set "BK=%USERPROFILE%\Desktop\services_backup.csv"

net session >nul 2>&1
if errorlevel 1 (
  echo 请右键本脚本,选择“以管理员身份运行”。
  pause
  exit /b 1
)

if not exist "%BK%" (
  echo 找不到备份文件: %BK%
  pause
  exit /b 1
)

powershell -NoProfile -Command "Import-Csv -Path '%BK%' | ForEach-Object { $t = switch ($_.StartMode) { 'Auto' {'Automatic'} 'Manual' {'Manual'} 'Disabled' {'Disabled'} default {'Manual'} }; Set-Service -Name $_.Name -StartupType $t -ErrorAction SilentlyContinue; Write-Host ('已恢复 ' + $_.Name + ' -> ' + $t) }"

echo.
echo 已按备份恢复启动类型(重启后生效)。
pause
endlocal
