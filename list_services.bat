@echo off
chcp 65001 >nul
setlocal
set "OUT=%USERPROFILE%\Desktop\services_report.txt"

echo 正在收集服务信息,请稍候...

> "%OUT%" echo ===== 正在运行的服务 =====
powershell -NoProfile -Command "Get-Service | Where-Object Status -eq 'Running' | Sort-Object DisplayName | Format-Table Name,DisplayName -AutoSize | Out-String -Width 200" >> "%OUT%"

>> "%OUT%" echo ===== 开机自动启动的服务 =====
powershell -NoProfile -Command "Get-CimInstance Win32_Service | Where-Object StartMode -eq 'Auto' | Sort-Object DisplayName | Format-Table Name,DisplayName,State -AutoSize | Out-String -Width 200" >> "%OUT%"

>> "%OUT%" echo ===== 已禁用的服务 =====
powershell -NoProfile -Command "Get-CimInstance Win32_Service | Where-Object StartMode -eq 'Disabled' | Sort-Object DisplayName | Format-Table Name,DisplayName,State -AutoSize | Out-String -Width 200" >> "%OUT%"

>> "%OUT%" echo ===== 非微软的第三方服务 =====
powershell -NoProfile -Command "Get-CimInstance Win32_Service | Where-Object { $_.PathName -notmatch 'Windows|System32' } | Sort-Object DisplayName | Format-Table Name,DisplayName,State,StartMode -AutoSize | Out-String -Width 200" >> "%OUT%"

echo.
echo 完成!报告已保存到: %OUT%
start "" notepad "%OUT%"
pause
endlocal
