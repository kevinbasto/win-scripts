param (
    [Parameter(Mandatory = $true)]
    [string]$Carpeta
)

# Verifica si la carpeta existe
if (-Not (Test-Path -Path $Carpeta -PathType Container)) {
    Write-Host "Error: '$Carpeta' no es una carpeta válida." -ForegroundColor Red
    exit 1
}

# Obtiene todos los archivos recursivamente
$archivos = Get-ChildItem -Path $Carpeta -Recurse -File

if ($archivos.Count -eq 0) {
    Write-Host "No se encontraron archivos en '$Carpeta'."
    exit 0
}

# Abre cada archivo con VS Code
foreach ($archivo in $archivos) {
    code $archivo.FullName
}
