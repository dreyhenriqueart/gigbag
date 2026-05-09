#Requires -Version 5.1
<#
Grava o secret FIREBASE_SERVICE_ACCOUNT_GIGBAG_APP no GitHub (para o CI publicar sozinho).

1) No Firebase Console abra:
   https://console.firebase.google.com/project/gigbag-app/settings/serviceaccounts/adminsdk
2) "Gerar nova chave privada" — salve o arquivo JSON (ex.: C:\Users\Você\Downloads\gigbag-app-xxxxx.json)

3) Rode (ajuste o caminho do JSON):
   powershell -ExecutionPolicy Bypass -File .\scripts\configurar-secret-firebase-github.ps1 -CaminhoJson "C:\caminho\para\chave.json"

Na primeira vez também pedirá login GitHub no navegador (`gh auth login`).
#>
param(
    [Parameter(Mandatory = $true)]
    [string] $CaminhoJson
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $CaminhoJson)) {
    Write-Error "Arquivo não encontrado: $CaminhoJson"
}

$gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $gh) {
    Write-Error 'GitHub CLI (gh) não está instalado. Instale com: winget install GitHub.cli'
}

gh auth status *>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host '>>> Login no GitHub (uma vez neste PC)...'
    gh auth login -h github.com -p https -w
}

Write-Host '>>> Enviando secret FIREBASE_SERVICE_ACCOUNT_GIGBAG_APP para dreyhenriqueart/gigbag ...'
Get-Content -Raw -LiteralPath $CaminhoJson | gh secret set FIREBASE_SERVICE_ACCOUNT_GIGBAG_APP --repo dreyhenriqueart/gigbag

Write-Host ''
Write-Host 'Pronto. No GitHub: Actions → "Deploy Firebase Hosting" → Run workflow (ou faça um push na branch developer).'
