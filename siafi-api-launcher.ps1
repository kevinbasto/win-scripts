# Cambiar a escritorio virtual 2 (requiere herramienta externa, ver abajo)

# Abrir Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Esperar un poco a que inicie Docker Desktop (ajustar si es necesario)
Start-Sleep -Seconds 10

# Iniciar todos los contenedores
docker start $(docker ps -aq)

# Navegar al directorio y abrir VS Code
Set-Location "$env:USERPROFILE\Documents\3code\siafi\siafi-api"
code .

# Ejecutar la API
Set-Location "$env:USERPROFILE\Documents\3code\siafi\siafi-api\siafi.api"
dotnet run
