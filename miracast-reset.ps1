# limpiar_miracast.ps1

# Mostrar mensaje
Write-Host "Reiniciando servicios de red y limpiando caché de dispositivos emparejados..."

# Eliminar dispositivos Miracast (desde configuración)
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Roku*" -or $_.FriendlyName -like "*Wireless Display*" } | ForEach-Object {
    Disable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false
    Remove-PnpDevice -InstanceId $_.InstanceId -Confirm:$false
}

# Reiniciar servicios de red
Stop-Service -Name "Netman" -Force
Start-Service -Name "Netman"

Stop-Service -Name "WlanSvc" -Force
Start-Service -Name "WlanSvc"

# Reiniciar servicio de proyección inalámbrica
Stop-Service -Name "PushToInstall" -Force
Start-Service -Name "PushToInstall"

Write-Host "Proceso completado. Reinicia tu PC para mejores resultados."
