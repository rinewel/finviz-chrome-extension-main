@echo off
chcp 65001 >nul
setlocal
set "OUT=%USERPROFILE%\Desktop\threads_report.txt"

echo 正在收集所有进程和线程信息,请稍候(线程可能有几千条)...

> "%OUT%" echo ===== 各进程线程数(从多到少) =====
powershell -NoProfile -Command "Get-Process | Select-Object ProcessName,Id,@{N='Threads';E={$_.Threads.Count}} | Sort-Object Threads -Descending | Format-Table -AutoSize | Out-String -Width 200" >> "%OUT%"

>> "%OUT%" echo ===== 线程总数 =====
powershell -NoProfile -Command "(Get-Process | ForEach-Object { $_.Threads.Count } | Measure-Object -Sum).Sum" >> "%OUT%"

>> "%OUT%" echo.
>> "%OUT%" echo ===== 全部线程明细 =====
powershell -NoProfile -Command "Get-Process | ForEach-Object { $p = $_; try { $p.Threads | ForEach-Object { [pscustomobject]@{ Process=$p.ProcessName; PID=$p.Id; TID=$_.Id; State=$_.ThreadState; Priority=$_.CurrentPriority; WaitReason=$(if ($_.ThreadState -eq 'Wait') { $_.WaitReason }) } } } catch {} } | Sort-Object Process,PID,TID | Format-Table -AutoSize | Out-String -Width 200" >> "%OUT%"

echo.
echo 完成!报告已保存到: %OUT%
start "" notepad "%OUT%"
pause
endlocal
