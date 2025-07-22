param (
    [Parameter(Mandatory = $true)]
    [string]$RootPath
)

# Verifica si la ruta existe
if (-Not (Test-Path $RootPath)) {
    Write-Error "La ruta especificada no existe: $RootPath"
    exit 1
}

# Obtiene todas las subcarpetas del directorio raíz
$subfolders = Get-ChildItem -Path $RootPath -Directory

foreach ($folder in $subfolders) {
    $packageJsonPath = Join-Path $folder.FullName "package.json"

    if (Test-Path $packageJsonPath) {
        Write-Host "Entrando en $($folder.Name) y ejecutando 'npm install'..."
        Push-Location $folder.FullName
        try {
            npm install
        } catch {
            Write-Warning "Ocurrió un error en $($folder.Name): $_"
        }
        Pop-Location
    } else {
        Write-Host "Saltando $($folder.Name) (no tiene package.json)"
    }
}

Write-Host "Proceso completado."
 