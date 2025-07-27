param (
    [Parameter(Mandatory = $true)]
    [string]$path,

    [Parameter(Mandatory = $true)]
    [string]$components
)

# Separar la lista de componentes por coma y eliminar espacios
$componentList = $components.Split(',') | ForEach-Object { $_.Trim() }

foreach ($component in $componentList) {
    $fullPath = Join-Path $path $component

    Write-Host "Generando componente '$component' en '$fullPath'..."

    # Ejecutar el comando ng generate component
    # Para evitar que falle si no estás en la carpeta del proyecto Angular, puedes agregar un Push-Location antes y Pop-Location después

    # Si quieres que lo genere dentro de la ruta relativa que le pasas
    ng generate component $fullPath

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error al generar el componente $component"
    }
}
