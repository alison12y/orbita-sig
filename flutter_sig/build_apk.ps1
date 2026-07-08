# Script de PowerShell para limpiar y generar el APK de Órbita en modo debug

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   Iniciando compilación de Órbita APK" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "[1/3] Limpiando el proyecto (flutter clean)..." -ForegroundColor Yellow
flutter clean

Write-Host "[2/3] Obteniendo dependencias (flutter pub get)..." -ForegroundColor Yellow
flutter pub get

Write-Host "[3/3] Construyendo el APK (flutter build apk --debug)..." -ForegroundColor Yellow
flutter build apk --debug
$STATUS = $LASTEXITCODE

Write-Host "=========================================" -ForegroundColor Cyan
if ($STATUS -eq 0) {
    Write-Host "✅ APK generado correctamente!" -ForegroundColor Green
    Write-Host "📂 Lo encontrarás en: build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor Green
} else {
    Write-Host "❌ Hubo un error al compilar el APK." -ForegroundColor Red
}
Write-Host "=========================================" -ForegroundColor Cyan
