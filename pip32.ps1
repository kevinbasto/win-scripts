# Ruta del Python de 32 bits basada en $env:USERPROFILE
$python32 = Join-Path $env:USERPROFILE "AppData\Local\Programs\Python\Python313-32\python.exe"

# Ejecuta pip con los argumentos que reciba el script
& $python32 -m pip @args
