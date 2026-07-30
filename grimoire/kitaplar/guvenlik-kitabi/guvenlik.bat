@echo off
title Guvenlik Kitabi - Koruma Durumunu Kontrol Et
color 0B
echo.
echo  ========================================
echo        GUVENLIK KITABI
echo   Koruma Durumunu Kontrol Et
echo  ========================================
echo.
echo  Uyari: Yonetici haklari gerekli!
echo.
pause >nul
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [HATA] Yonetici olarak calistirin!
    pause
    exit /b 1
)
powershell -ExecutionPolicy Bypass -File "%~dp0guvenlik.ps1"
echo.
echo [TAMAMLANDI]
pause
