@echo off
title Ses Kitabi - Ses Cikisi ve Mikrofon Sorunlarini Coz
color 0B
echo.
echo  ========================================
echo         SES KITABI
echo   Ses ve Mikrofon Sorunlarini Coz
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
powershell -ExecutionPolicy Bypass -File "%~dp0ses.ps1"
echo.
echo [TAMAMLANDI]
pause
