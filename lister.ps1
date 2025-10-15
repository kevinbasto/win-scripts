# Script para listar archivos .ps1 en C:/scripts

$ruta = "C:/Users/kevin/scripts"

# Verificar si la carpeta existe
if (Test-Path $ruta) {
    Write-Host "Buscando archivos .ps1 en: $ruta" -ForegroundColor Cyan
    Write-Host ("-" * 60) -ForegroundColor Gray
    
    # Obtener todos los archivos .ps1
    $archivos = Get-ChildItem -Path $ruta -Filter "*.ps1" -File
    
    if ($archivos.Count -gt 0) {
        Write-Host "Se encontraron $($archivos.Count) archivo(s) .ps1:`n" -ForegroundColor Green
        
        foreach ($archivo in $archivos) {
            Write-Host "Nombre: " -NoNewline -ForegroundColor Yellow
            Write-Host $archivo.Name
            Write-Host "Ruta completa: " -NoNewline -ForegroundColor Yellow
            Write-Host $archivo.FullName
            Write-Host "Tamaño: " -NoNewline -ForegroundColor Yellow
            Write-Host "$([math]::Round($archivo.Length/1KB, 2)) KB"
            Write-Host "Última modificación: " -NoNewline -ForegroundColor Yellow
            Write-Host $archivo.LastWriteTime
            Write-Host ("-" * 60) -ForegroundColor Gray
        }
    } else {
        Write-Host "No se encontraron archivos .ps1 en la carpeta." -ForegroundColor Yellow
    }
} else {
    Write-Host "ERROR: La carpeta $ruta no existe." -ForegroundColor Red
}