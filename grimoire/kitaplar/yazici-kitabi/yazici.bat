@echo off
title Yazici Kitabi - Sikisan Yazdirma Kuyrugunu Temizle
color 0B
echo.
echo  ========================================
echo         YAZICI KITABI
echo   Sikisan Kuyrugu Temizle
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
powershell -ExecutionPolicy Bypass -File "%~dp0yazici.ps1"
echo.
echo [TAMAMLANDI]
pause
