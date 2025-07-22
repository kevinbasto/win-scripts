# Obtener el nombre del usuario actual
$userProfile = $env:USERNAME

# Definir rutas
$sourcePath = "C:\Users\$userProfile\scripts"
$destinationPath = "D:\scripts"

# Verificar si la carpeta de origen existe
if (Test-Path $sourcePath) {
    # Crear la carpeta de destino si no existe
    if (-not (Test-Path $destinationPath)) {
        New-Item -Path $destinationPath -ItemType Directory | Out-Null
    }

    # Copiar los archivos y carpetas
    Copy-Item -Path $sourcePath\* -Destination $destinationPath -Recurse -Force

    Write-Host "Archivos copiados exitosamente de $sourcePath a $destinationPath."
} else {
    Write-Host "La carpeta de origen '$sourcePath' no existe."
}
