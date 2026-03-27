# commit-and-suspend.ps1
# Commitea cambios en todos los repos y suspende la computadora

param(
    [string]$ReposPath = "C:\Users\DevTeam\repo",
    [string]$CommitMessage = "[AUTO]: pre shutdown work saving"
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
        # Verificar si hay cambios
        $status = git status --porcelain 2>$null

        if (-not $status) {
            Write-Host "   ✅ Sin cambios pendientes" -ForegroundColor DarkGray
            $results += [PSCustomObject]@{ Repo = $repoName; Estado = "⏭️  Sin cambios"; Rama = (git rev-parse --abbrev-ref HEAD 2>$null) }
            continue
        }

        Write-Host "   📝 Cambios detectados:" -ForegroundColor Yellow
        $status | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkYellow }

        # Stage de todos los cambios
        git add -A 2>&1 | Out-Null
        Write-Host "   ➕ Archivos añadidos al stage" -ForegroundColor Cyan

        # Commit
        $commitOutput = git commit -m $CommitMessage 2>&1
        $currentBranch = git rev-parse --abbrev-ref HEAD 2>$null

        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Commit realizado en '$currentBranch'" -ForegroundColor Green

            # Push
            Write-Host "   ⬆️  Subiendo cambios..." -ForegroundColor Cyan
            $pushOutput = git push origin $currentBranch 2>&1

            if ($LASTEXITCODE -eq 0) {
                Write-Host "   ✅ Push exitoso" -ForegroundColor Green
                $results += [PSCustomObject]@{ Repo = $repoName; Estado = "✅ Commit + Push"; Rama = $currentBranch }
            } else {
                Write-Host "   ⚠️  Commit OK pero falló el push" -ForegroundColor Yellow
                $results += [PSCustomObject]@{ Repo = $repoName; Estado = "⚠️  Commit OK / Push falló"; Rama = $currentBranch }
            }
        } else {
            Write-Host "   ❌ Error al hacer commit" -ForegroundColor Red
            Write-Host "   $commitOutput" -ForegroundColor DarkRed
            $results += [PSCustomObject]@{ Repo = $repoName; Estado = "❌ Error en commit"; Rama = $currentBranch }
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

# Suspender la computadora
Write-Host "💤 Suspendiendo la computadora en 5 segundos..." -ForegroundColor Magenta
Start-Sleep -Seconds 5
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Suspend, $false, $false)