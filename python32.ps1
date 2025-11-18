# Ruta del Python de 32 bits basada en $env:USERPROFILE
$python32 = Join-Path $env:USERPROFILE "AppData\Local\Programs\Python\Python313-32\python.exe"

# Ejecuta Python con argumentos pasados al script
& $python32 @args
