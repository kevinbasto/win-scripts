# 🕕 SON LAS 6PM - SE ACABÓ EL TURNO

$userProcesses = Get-Process | Where-Object {
    $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle -ne ""
}

Write-Host "`n🕕 SON LAS 6PM. SE ACABÓ." -ForegroundColor Cyan
Write-Host "Cerrando todo este desmadre..`n" -ForegroundColor Cyan
Start-Sleep -Seconds 1

foreach ($proc in $userProcesses) {
    Write-Host "🖕 Fuck you, $($proc.MainWindowTitle)" -ForegroundColor Red
    Start-Sleep -Milliseconds 300
    try { $proc.Kill() } catch {}
}

Write-Host "`n✅ Todo cerrado." -ForegroundColor Green
Write-Host "🍺 Ya puedes irte a tu casa, champ." -ForegroundColor Yellow
Start-Sleep -Seconds 3

Stop-Computer -Force