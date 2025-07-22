# Script para copiar archivos de configuración
# Autor: Script generado para copiar appsettings.json y launchsettings.json

# Definir rutas de origen
$documentosUsuario = [Environment]::GetFolderPath("MyDocuments")
$origenAppSettings = Join-Path $documentosUsuario "appsettings.json"
$origenLaunchSettings = Join-Path $documentosUsuario "launchsettings.json"

# Definir rutas de destino
$destinoBase = "C:\Users\Home\Documents\3code\siafi\siafi-api\siafi.api"
$destinoAppSettings = Join-Path $destinoBase "appsettings.json"
$destinoLaunchSettings = Join-Path $destinoBase "Properties\launchsettings.json"

# Definir rutas de respaldo en prod-settings
$respaldoBase = Join-Path $documentosUsuario "prod-settings"
$respaldoAppSettings = Join-Path $respaldoBase "appsettings.json"
$respaldoLaunchSettings = Join-Path $respaldoBase "launchsettings.json"

Write-Host "Iniciando copia de archivos de configuración..." -ForegroundColor Green
Write-Host "Documentos del usuario: $documentosUsuario" -ForegroundColor Yellow
Write-Host "Carpeta de respaldo: $respaldoBase" -ForegroundColor Yellow

# Función para copiar archivo con validaciones y respaldo
function Copy-ConfigFile {
    param(
        [string]$origen,
        [string]$destino,
        [string]$respaldo,
        [string]$nombreArchivo
    )
    
    Write-Host "`nProcesando $nombreArchivo..." -ForegroundColor Cyan
    
    # Verificar si el archivo origen existe
    if (-not (Test-Path $origen)) {
        Write-Host "ERROR: No se encontró $nombreArchivo en: $origen" -ForegroundColor Red
        return $false
    }
    
    $exitoso = $true
    
    # Crear directorio de destino si no existe
    $directorioDestino = Split-Path $destino -Parent
    if (-not (Test-Path $directorioDestino)) {
        Write-Host "Creando directorio de destino: $directorioDestino" -ForegroundColor Yellow
        try {
            New-Item -ItemType Directory -Path $directorioDestino -Force | Out-Null
        }
        catch {
            Write-Host "ERROR: No se pudo crear el directorio de destino $directorioDestino" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            $exitoso = $false
        }
    }
    
    # Crear directorio de respaldo si no existe
    $directorioRespaldo = Split-Path $respaldo -Parent
    if (-not (Test-Path $directorioRespaldo)) {
        Write-Host "Creando directorio de respaldo: $directorioRespaldo" -ForegroundColor Yellow
        try {
            New-Item -ItemType Directory -Path $directorioRespaldo -Force | Out-Null
        }
        catch {
            Write-Host "ERROR: No se pudo crear el directorio de respaldo $directorioRespaldo" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            $exitoso = $false
        }
    }
    
    # Copiar archivo al destino principal
    if ($exitoso) {
        try {
            Copy-Item -Path $origen -Destination $destino -Force
            Write-Host "✓ $nombreArchivo copiado al destino principal" -ForegroundColor Green
            Write-Host "  Destino: $destino" -ForegroundColor Gray
        }
        catch {
            Write-Host "ERROR: No se pudo copiar $nombreArchivo al destino principal" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            $exitoso = $false
        }
    }
    
    # Copiar archivo al respaldo
    if ($exitoso) {
        try {
            Copy-Item -Path $origen -Destination $respaldo -Force
            Write-Host "✓ $nombreArchivo guardado en prod-settings" -ForegroundColor Green
            Write-Host "  Respaldo: $respaldo" -ForegroundColor Gray
        }
        catch {
            Write-Host "ERROR: No se pudo guardar $nombreArchivo en prod-settings" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            $exitoso = $false
        }
    }
    
    if ($exitoso) {
        Write-Host "  Origen: $origen" -ForegroundColor Gray
    }
    
    return $exitoso
}

# Copiar appsettings.json
$appSettingsOk = Copy-ConfigFile -origen $origenAppSettings -destino $destinoAppSettings -respaldo $respaldoAppSettings -nombreArchivo "appsettings.json"

# Copiar launchsettings.json
$launchSettingsOk = Copy-ConfigFile -origen $origenLaunchSettings -destino $destinoLaunchSettings -respaldo $respaldoLaunchSettings -nombreArchivo "launchsettings.json"

# Resumen final
Write-Host "`n" + "="*50 -ForegroundColor Magenta
Write-Host "RESUMEN DE LA OPERACIÓN" -ForegroundColor Magenta
Write-Host "="*50 -ForegroundColor Magenta

if ($appSettingsOk) {
    Write-Host "✓ appsettings.json: COPIADO Y RESPALDADO" -ForegroundColor Green
} else {
    Write-Host "✗ appsettings.json: FALLÓ" -ForegroundColor Red
}

if ($launchSettingsOk) {
    Write-Host "✓ launchsettings.json: COPIADO Y RESPALDADO" -ForegroundColor Green
} else {
    Write-Host "✗ launchsettings.json: FALLÓ" -ForegroundColor Red
}

if ($appSettingsOk -and $launchSettingsOk) {
    Write-Host "`nTodos los archivos se copiaron exitosamente al destino y se guardaron en prod-settings." -ForegroundColor Green
} else {
    Write-Host "`nAlgunos archivos no se pudieron procesar. Revisa los errores anteriores." -ForegroundColor Yellow
}

Write-Host "`nPresiona cualquier tecla para continuar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")