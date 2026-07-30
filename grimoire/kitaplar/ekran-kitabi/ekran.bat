@echo off
title Ekran Kitabi - Goruntu Sorunlarini Coz
color 0B
echo.
echo  ========================================
echo         EKRAN KITABI
echo    Goruntu Sorunlarini Coz
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
powershell -ExecutionPolicy Bypass -File "%~dp0ekran.ps1"
echo.
echo [TAMAMLANDI]
pause
