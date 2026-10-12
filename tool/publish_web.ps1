# Publication de Resto Web : copie build\web dans le dépôt de publication
# (C:\dev\resto-web\public), puis enregistrement et envoi vers GitHub ;
# Cloudflare met le site à jour automatiquement.
# Préalable : flutter build web --release --no-web-resources-cdn --dart-define-from-file=env/dev.json
param([string]$Message = "Mise à jour de Resto Web")
$ErrorActionPreference = 'Stop'
$src = 'C:\dev\resto\build\web'
$repo = 'C:\dev\resto-web'
if (-not (Test-Path "$src\main.dart.js")) { throw "Compilez d'abord la version Web (build\web introuvable)." }
if (Test-Path "$repo\public") { Remove-Item -Recurse -Force "$repo\public" -Confirm:$false }
Copy-Item -Recurse $src "$repo\public"
# Fichiers inutiles en ligne (symboles de débogage).
Get-ChildItem -Recurse "$repo\public" -Filter *.symbols | Remove-Item -Force -Confirm:$false
git -C $repo add -A
git -C $repo commit -q -m $Message
git -C $repo -c http.postBuffer=524288000 push -q origin main
Write-Output "Publié : $Message"
