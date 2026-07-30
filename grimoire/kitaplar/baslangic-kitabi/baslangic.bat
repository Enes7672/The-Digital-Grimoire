@echo off
title Baslangic Kitabi - Acilis Uygulamalarini Yonet
color 0B

echo.
echo  ========================================
echo       BASLANGIC KITABI
echo    Acilis Uygulamalarini Yonet
echo  ========================================
echo.
echo  Bu script acilista otomatik baslayan
echo  uygulamalari listeler ve secileni kapatir.
echo.
echo  Uyari: Yonetici haklari gerekli!
echo.
pause >nul

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [HATA] Bu script yonetici haklari ile calistirilmali!
    echo Sag tikla - "Yonetici olarak calistir" secenegiyle acin.
    pause
    exit /b 1
)

powershell -ExecutionPolicy Bypass -File "%~dp0baslangic.ps1"

echo.
echo [TAMAMLANDI]
pause
