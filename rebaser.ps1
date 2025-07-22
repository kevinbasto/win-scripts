$ErrorActionPreference = "Stop"

try {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    Write-Host "📌 Rama actual: $currentBranch"
    Write-Host "`n🔀 Cambiando a 'develop'..."
    git checkout develop
    if ($LASTEXITCODE -ne 0) { throw "❌ Error al hacer checkout a develop." }
    Write-Host "`n⬇️  Actualizando 'develop'..."
    git pull origin develop
    if ($LASTEXITCODE -ne 0) { throw "❌ Error al hacer pull de develop." }
    Write-Host "`n↩️  Regresando a '$currentBranch'..."
    git checkout $currentBranch
    if ($LASTEXITCODE -ne 0) { throw "❌ Error al volver a $currentBranch." }
    Write-Host "`n🧬 Haciendo rebase sobre develop..."
    git rebase develop
    if ($LASTEXITCODE -ne 0) { throw "❌ Error durante el rebase." }

    Write-Host "`n✅ Rebase completo sin errores." -ForegroundColor Green
}
catch {
    Write-Host "`n🚨 Ocurrió un error: $_" -ForegroundColor Red
}
