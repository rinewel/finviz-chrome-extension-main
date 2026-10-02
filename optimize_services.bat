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

rem 安全且常见的可改为“手动”的服务(不会禁用,需要时系统会自动拉起)
set "SVCS='Fax','XblAuthManager','XblGameSave','XboxGipSvc','XboxNetApiSvc','TabletInputService','RemoteRegistry','WMPNetworkSvc','MapsBroker','RetailDemo','lfsvc','DiagTrack'"

echo 将把以下服务改为“手动”并停止: Fax、Xbox 系列、触控键盘、远程注册表、
echo 媒体共享、离线地图、零售演示、定位服务、遥测(DiagTrack)。
echo.
set /p ANS1=没有蓝牙设备吗?要把蓝牙支持服务也改为手动吗 (Y/N):
if /i "%ANS1%"=="Y" set "SVCS=%SVCS%,'bthserv'"
set /p ANS2=没有打印机吗?要把打印后台处理服务也改为手动吗 (Y/N):
if /i "%ANS2%"=="Y" set "SVCS=%SVCS%,'Spooler'"

echo.
echo [1/3] 创建系统还原点(失败可忽略)...
powershell -NoProfile -Command "try { Enable-ComputerRestore -Drive $env:SystemDrive; Checkpoint-Computer -Description 'Before service optimize' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop; 'OK' } catch { '跳过: ' + $_.Exception.Message }"

echo [2/3] 备份原始启动类型到 %BK% ...
if exist "%BK%" (
  echo 备份已存在,保留最初的备份不覆盖。
) else (
  powershell -NoProfile -Command "Get-CimInstance Win32_Service | Where-Object { @(%SVCS%) -contains $_.Name } | Select-Object Name,StartMode | Export-Csv -Path '%BK%' -NoTypeInformation -Encoding UTF8"
)

echo [3/3] 修改服务...
powershell -NoProfile -Command "foreach ($n in @(%SVCS%)) { $s = Get-Service -Name $n -ErrorAction SilentlyContinue; if ($s) { Stop-Service -Name $n -Force -ErrorAction SilentlyContinue; Set-Service -Name $n -StartupType Manual; Write-Host ('已改为手动: ' + $n) } else { Write-Host ('不存在,跳过: ' + $n) } }"

echo.
echo 完成。如需恢复,请以管理员身份运行 restore_services.bat。
pause
endlocal
