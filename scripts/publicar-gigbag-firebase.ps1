#Requires -Version 5.1
<#
Publica o Gigbag em https://gigbag-app.web.app (Firebase Hosting).

Execute na raiz do repositório (onde está firebase.json):
  powershell -ExecutionPolicy Bypass -File .\scripts\publicar-gigbag-firebase.ps1

Na primeira vez o Firebase abrirá o navegador para você autorizar com a conta Google
que tem acesso ao projeto "gigbag-app".
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot

function Resolve-Flutter {
    $fc = Get-Command flutter -ErrorAction SilentlyContinue
    if ($fc) { return 'flutter' }
    foreach ($p in @(
            'C:\Repo\.flutter_sdk\extract_3419\flutter\bin\flutter.bat',
            (Join-Path $RepoRoot '..\flutter_sdk\extract_3419\flutter\bin\flutter.bat'),
            (Join-Path $env:LOCALAPPDATA 'flutter\bin\flutter.bat')
        )) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

$FlutterCmd = Resolve-Flutter
if (-not $FlutterCmd) {
    Write-Error 'Flutter não encontrado. Coloque `flutter` no PATH ou instale em C:\Repo\.flutter_sdk\extract_3419\flutter'
}

$AppDir = Join-Path $RepoRoot 'gigbag_app'
if (-not (Test-Path $AppDir)) {
    Write-Error "Pasta gigbag_app não encontrada em $RepoRoot"
}

Push-Location $AppDir
try {
    Write-Host '>>> flutter pub get'
    & $FlutterCmd pub get
    Write-Host '>>> flutter build web --release --base-href=/'
    & $FlutterCmd build web --release --base-href='/'
}
finally {
    Pop-Location
}

Push-Location $RepoRoot
try {
    Write-Host '>>> firebase login (siga as instruções no terminal/navegador)'
    firebase login
    Write-Host '>>> firebase deploy --only hosting --project gigbag-app'
    firebase deploy --only hosting --project gigbag-app
    Write-Host ''
    Write-Host 'Publicado: https://gigbag-app.web.app'
}
finally {
    Pop-Location
}
