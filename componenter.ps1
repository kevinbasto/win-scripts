param(
    [parameter(Mandatory=$true)]
    [string]$Path
)

$ModuleName = Split-path $Path -Leaf

Write-Host "Generando estructura para: $ModuleName" -ForegroundColor Green
Write-Host "Ruta completada $Path" -ForegroundColor Yellow
Write-Host ""

if(-not (Test-Path "angular.json")){
    Write-Host "Error: Nose encontro angular.json, asegurate de estar en la raiz de un proyecto angular." -ForegroundColor Red
    exit 1
}

Write-Host "1. Generando componente sin standalone..." -ForegroundColor Blue
ng generate component $Path --standalone=false

Write-Host "2. generando servicio para el componente" -ForegroundColor Blue
ng generate service $Path/$ModuleName

Write-Host "Task completed, enjoy the result :)"