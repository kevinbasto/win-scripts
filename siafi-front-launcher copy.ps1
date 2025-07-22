Set-Location "$env:USERPROFILE\Documents\3code\siafi\siafi-front"
code .
Start-Process powershell -ArgumentList "npm start"
Start-Sleep -Seconds 60
$url = "http://localhost:4200"
$bravePath = "$env:PROGRAMFILES\BraveSoftware\Brave-Browser\Application\brave.exe"
if (-not (Test-Path $bravePath)) {
    $bravePath = "$env:PROGRAMFILES(X86)\BraveSoftware\Brave-Browser\Application\brave.exe"
}
$braveRunning = Get-Process | Where-Object { $_.Name -like "brave*" }
if ($braveRunning) {
    Start-Process "$bravePath" --args "$url"
} else {
    Start-Process "$bravePath" "$url"
}
