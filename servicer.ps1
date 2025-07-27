param (
    [Parameter(Mandatory = $true)]
    [string]$path,

    [Parameter(Mandatory = $true)]
    [string]$services
)

# Separar la lista de servicios por coma y eliminar espacios
$serviceList = $services.Split(',') | ForEach-Object { $_.Trim() }

foreach ($service in $serviceList) {
    $fullPath = Join-Path $path $service $service

    Write-Host "Generando servicio '$service' en '$fullPath'..."

    # Ejecutar el comando ng generate service
    # Para evitar que falle si no estás en la carpeta del proyecto Angular, puedes agregar un Push-Location antes y Pop-Location después

    # Si quieres que lo genere dentro de la ruta relativa que le pasas
    ng generate service $fullPath
    # write-host $fullPath

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error al generar el componente $component"
    }
}
