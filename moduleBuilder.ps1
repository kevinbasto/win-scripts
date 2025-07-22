param (
    [Parameter(Mandatory = $true)][string]$DestinationPath,
    [Parameter(Mandatory = $true)][string]$ModuleName
)

function Get-Plural($word) {
    if ($word.EndsWith("s")) {
        return $word
    } else {
        return "$word" + "s"
    }
}

# Mantener el nombre original pero con la primera letra en mayúscula
$capitalModule = $ModuleName.Substring(0,1).ToUpper() + $ModuleName.Substring(1)
$camelModule = $ModuleName.Substring(0,1).ToLower() + $ModuleName.Substring(1)
$pluralModule = Get-Plural $capitalModule
$namespaceBase = "siafi.api.Application.$capitalModule"

$folders = @("Domain", "Controllers", "Services", "Repositories", "Interfaces")
$moduleFolder = Join-Path $DestinationPath $capitalModule
New-Item -ItemType Directory -Path $moduleFolder -Force | Out-Null

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path (Join-Path $moduleFolder $folder) -Force | Out-Null
}

$filesToCreate = @{
    "Domain" = @("$capitalModule.cs", "${capitalModule}VM.cs")
    "Controllers" = @("${capitalModule}Controller.cs")
    "Services" = @("${capitalModule}Service.cs")
    "Repositories" = @("${capitalModule}Repository.cs")
    "Interfaces" = @("I${capitalModule}Service.cs", "I${capitalModule}Repository.cs")
}

function Get-FileContent($folder, $filename) {
    $namespace = "$namespaceBase.$folder"
    $nameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($filename)
    
    # Para evitar concatenar doble nombre, limpiamos el sufijo
    $cleanName = $nameWithoutExtension -replace "^$capitalModule", ""
    if ($folder -eq "Controllers") {
        $className = "$capitalModule" + "Controller"
    }
    elseif ($folder -eq "Services") {
        $className = "$capitalModule" + "Service"
    }
    elseif ($folder -eq "Repositories") {
        $className = "$capitalModule" + "Repository"
    }
    elseif ($folder -eq "Interfaces") {
        $className = "I" + "$capitalModule" + $cleanName
    }
    else {
        $className = "$capitalModule" + $cleanName
    }

    switch ($folder) {
        "Controllers" {
            $serviceClass = "$capitalModule" + "Service"
            $content = @"
using Microsoft.AspNetCore.Mvc;
using $namespaceBase.Services;

namespace $namespace
{
    [ApiController]
    [Route(""api/[controller]"")]
    public class $className : $serviceClass
    {
        // Implementa los métodos del controlador aquí
    }
}
"@
            return $content
        }
        "Services" {
            $content = @"
namespace $namespace
{
    public class $className
    {
        // Implementa el servicio aquí
    }
}
"@
            return $content
        }
        "Repositories" {
            $content = @"
namespace $namespace
{
    public class $className
    {
        // Implementa el repositorio aquí
    }
}
"@
            return $content
        }
        "Interfaces" {
            $content = @"
namespace $namespace
{
    public interface $className
    {
        // Define la interfaz aquí
    }
}
"@
            return $content
        }
        "Domain" {
            $content = @"
namespace $namespace
{
    public class $className
    {
        // Define el dominio o ViewModel aquí
    }
}
"@
            return $content
        }
        default {
            return ""
        }
    }
}

foreach ($folder in $filesToCreate.Keys) {
    $path = Join-Path $moduleFolder $folder
    foreach ($file in $filesToCreate[$folder]) {
        $content = Get-FileContent $folder $file
        Set-Content -Path (Join-Path $path $file) -Value $content -Encoding UTF8
    }
}

Write-Host "✅ Módulo '$capitalModule' generado en '$DestinationPath'"
