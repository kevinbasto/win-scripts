# Script para generar modulo, componente y servicio en Angular
# Uso: .\moduler.ps1 <ruta>
# Ejemplo: .\moduler.ps1 pages/client/staff

param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

# Obtener el nombre del modulo/componente
$ModuleName = Split-Path $Path -Leaf

Write-Host "Generando estructura para: $ModuleName" -ForegroundColor Green
Write-Host "Ruta completa: $Path" -ForegroundColor Yellow
Write-Host ""

# Verificar si estamos en un proyecto Angular
if (-not (Test-Path "angular.json")) {
    Write-Host "Error: No se encontro angular.json. Asegurate de estar en la raiz de un proyecto Angular." -ForegroundColor Red
    exit 1
}

Write-Host "1. Generando modulo con routing..." -ForegroundColor Cyan
ng generate module $Path --routing
if ($LASTEXITCODE -eq 0) {
    Write-Host "Modulo generado exitosamente" -ForegroundColor Green
} else {
    Write-Host "Error al generar el modulo" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Generando componente..." -ForegroundColor Cyan
ng generate component $Path --standalone=false
if ($LASTEXITCODE -eq 0) {
    Write-Host "Componente generado exitosamente" -ForegroundColor Green
} else {
    Write-Host "Error al generar el componente" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "3. Generando servicio..." -ForegroundColor Cyan
ng generate service "$Path/$ModuleName"
if ($LASTEXITCODE -eq 0) {
    Write-Host "Servicio generado exitosamente" -ForegroundColor Green
} else {
    Write-Host "Error al generar el servicio" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Generacion completada!" -ForegroundColor Green
Write-Host "Archivos creados:" -ForegroundColor Yellow
Write-Host "   - $Path/$ModuleName.module.ts"
Write-Host "   - $Path/$ModuleName-routing.module.ts"
Write-Host "   - $Path/$ModuleName.component.ts"
Write-Host "   - $Path/$ModuleName.component.html"
Write-Host "   - $Path/$ModuleName.component.css"
Write-Host "   - $Path/$ModuleName.component.spec.ts"
Write-Host "   - $Path/$ModuleName.service.ts"
Write-Host "   - $Path/$ModuleName.service.spec.ts"
Write-Host ""
Write-Host "Recuerda importar el modulo en tu app.module.ts o donde corresponda" -ForegroundColor Blue