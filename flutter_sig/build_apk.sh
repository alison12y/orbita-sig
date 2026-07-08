#!/bin/bash
# Script para limpiar y generar el APK de Órbita en modo debug

echo "========================================="
echo "   Iniciando compilación de Órbita APK"
echo "========================================="

echo "[1/3] Limpiando el proyecto (flutter clean)..."
flutter clean

echo "[2/3] Obteniendo dependencias (flutter pub get)..."
flutter pub get

echo "[3/3] Construyendo el APK (flutter build apk --debug)..."
flutter build apk --debug
STATUS=$?

echo "========================================="
if [ $STATUS -eq 0 ]; then
    echo "✅ APK generado correctamente!"
    echo "📂 Lo encontrarás en: build/app/outputs/flutter-apk/app-debug.apk"
else
    echo "❌ Hubo un error al compilar el APK."
fi
echo "========================================="
