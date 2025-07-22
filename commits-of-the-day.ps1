# Obtener la fecha actual en formato yyyy-MM-dd
$fecha = Get-Date -Format "yyyy-MM-dd"

# Construir el nombre del archivo
$archivo = "git-commits-$fecha.json"

# Ruta del archivo (reemplazá <tu_usuario> por tu nombre de usuario real o usá $env:USERNAME)
$ruta = "C:\Users\$env:USERNAME\logs\$archivo"

# Verificar si el archivo existe
if (Test-Path $ruta) {
    # Leer el contenido del JSON
    $contenido = Get-Content $ruta -Raw | ConvertFrom-Json

    # Contar los commits (asumiendo que es un array de objetos JSON)
    $cantidad = $contenido.Count

    Write-Host "Se encontraron $cantidad commits en el archivo '$archivo'."
} else {
    Write-Host "El archivo '$archivo' no existe en la ruta especificada."
}
