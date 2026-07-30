@echo off
title Baglanti Kitabi - WiFi Sorunlarini Coz
color 0B

echo.
echo  ========================================
echo       BAGLANTI KITABI
echo    WiFi Sorunlarini Coz
echo  ========================================
echo.
echo  Bu script WiFi ve internet baglanti
echo  sorunlarini cozer.
echo.
echo  Uyari: Yonetici haklari gerekli olabilir!
echo.
echo  Devam etmek icin bir tusa basin...
pause >nul

echo.
echo [BASLATILIYOR] Baglanti Buyusu...
echo.

:: Yetki kontrolü
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [UYARI] Yonetici haklari yok, bazi ozellikler calismayabilir.
    echo.
)

:: PowerShell scriptini çalıştır
powershell -ExecutionPolicy Bypass -File "%~dp0baglanti.ps1"

echo.
echo [TAMAMLANDI] Baglanti Buyusu uygulandi!
echo.
pause
