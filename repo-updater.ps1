# update-repos.ps1
# Recorre todos los repositorios git y hace pull en master o main

param(
    [string]$ReposPath = "C:\Users\DevTeam\repo"
)

$reposPath = Resolve-Path $ReposPath
Write-Host "`n📁 Buscando repositorios en: $reposPath`n" -ForegroundColor Cyan

$repos = Get-ChildItem -Path $reposPath -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName ".git")
}

if ($repos.Count -eq 0) {
    Write-Host "⚠️  No se encontraron repositorios git en '$reposPath'" -ForegroundColor Yellow
    exit 1
}

Write-Host "🔍 Se encontraron $($repos.Count) repositorio(s)`n" -ForegroundColor Green

$results = @()

foreach ($repo in $repos) {
    $repoName = $repo.Name
    $repoPath = $repo.FullName

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "📦 $repoName" -ForegroundColor White

    Push-Location $repoPath

    try {
        # Obtener ramas disponibles
        $branches = git branch --list 2>$null | ForEach-Object { $_.Trim().TrimStart('* ') }
        $remoteBranches = git branch -r 2>$null | ForEach-Object { $_.Trim() }

        # Determinar rama principal
        $targetBranch = $null

        if ($branches -contains "main" -or $remoteBranches -match "origin/main") {
            $targetBranch = "main"
        } elseif ($branches -contains "master" -or $remoteBranches -match "origin/master") {
            $targetBranch = "master"
        }

        if (-not $targetBranch) {
            Write-Host "   ⚠️  No se encontró rama 'main' ni 'master'" -ForegroundColor Yellow
            $results += [PSCustomObject]@{ Repo = $repoName; Estado = "⚠️  Sin rama principal"; Rama = "-" }
            continue
        }

        # Cambiar a la rama objetivo
        $currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($currentBranch -ne $targetBranch) {
            Write-Host "   🔀 Cambiando de '$currentBranch' → '$targetBranch'" -ForegroundColor DarkYellow
            git checkout $targetBranch 2>&1 | Out-Null
        }

        # Hacer pull
        Write-Host "   ⬇️  Descargando cambios en '$targetBranch'..." -ForegroundColor Cyan
        $pullOutput = git pull origin $targetBranch 2>&1

        if ($LASTEXITCODE -eq 0) {
            if ($pullOutput -match "Already up to date") {
                Write-Host "   ✅ Ya está actualizado" -ForegroundColor Green
                $results += [PSCustomObject]@{ Repo = $repoName; Estado = "✅ Actualizado"; Rama = $targetBranch }
            } else {
                Write-Host "   ✅ Pull exitoso" -ForegroundColor Green
                $results += [PSCustomObject]@{ Repo = $repoName; Estado = "✅ Pull exitoso"; Rama = $targetBranch }
            }
        } else {
            Write-Host "   ❌ Error al hacer pull" -ForegroundColor Red
            Write-Host "   $pullOutput" -ForegroundColor DarkRed
            $results += [PSCustomObject]@{ Repo = $repoName; Estado = "❌ Error en pull"; Rama = $targetBranch }
        }

    } catch {
        Write-Host "   ❌ Excepción: $_" -ForegroundColor Red
        $results += [PSCustomObject]@{ Repo = $repoName; Estado = "❌ Excepción"; Rama = "-" }
    } finally {
        Pop-Location
    }
}

# Resumen final
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📊 RESUMEN`n" -ForegroundColor Cyan
$results | Format-Table -AutoSize