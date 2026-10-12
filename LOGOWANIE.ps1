$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$ghPath = Join-Path $taskRoot 'work\tools\cli\bin\gh.exe'
if (!(Test-Path -LiteralPath $ghPath)) { throw 'Brak pobranego gh.exe. Użyj własnego gh auth login.' }
& $ghPath auth login --hostname github.com --git-protocol https --web
if ($LASTEXITCODE -ne 0) { throw 'Logowanie nie zostało ukończone.' }
& $ghPath auth status
