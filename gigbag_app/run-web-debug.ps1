# Debug web: Chrome + hot reload. Exige Git no PATH (o Flutter invoca o git).
$gitBin = "C:\Program Files\Git\bin"
if (Test-Path $gitBin) {
  $env:Path = "$gitBin;$env:Path"
}
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$cmd = Get-Command flutter -ErrorAction SilentlyContinue
$flutter = if ($cmd) { $cmd.Source } elseif (Test-Path "C:\tools\flutter\bin\flutter.bat") {
  "C:\tools\flutter\bin\flutter.bat"
} else { $null }
if (-not $flutter) {
  Write-Error "Flutter nao encontrado. Adicione ao PATH ou instale em C:\tools\flutter."
}

# Porta fixa: o mesmo URL em cada execução (atualize a página no browser após hot reload/restart).
# Se a porta estiver ocupada, encerre o processo anterior ou altere $WebPort.
$WebPort = 8080
Write-Host "Preview: http://127.0.0.1:$WebPort" -ForegroundColor Cyan
& $flutter run -d chrome --web-port=$WebPort
