# Carpeta a escanear
$folderPath = "C:\Users\Kevin-trabajo\scripts"

# Obtener todos los archivos .ps1 en la carpeta
$ps1Files = Get-ChildItem -Path $folderPath -Filter *.ps1

foreach ($file in $ps1Files) {
    $originalPath = $file.FullName
    $tempPath = Join-Path $folderPath ($file.BaseName + "_tmp.ps1")

    # Copiar contenido al archivo temporal
    Get-Content $originalPath | Set-Content $tempPath

    # Eliminar el archivo original
    Remove-Item $originalPath -Force

    # Renombrar el temporal con el nombre original
    Rename-Item -Path $tempPath -NewName $file.Name

    Write-Host "Procesado: $($file.Name)"
}

Write-Host "Todos los scripts .ps1 han sido regenerados correctamente."
