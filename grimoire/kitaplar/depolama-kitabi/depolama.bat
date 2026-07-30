@echo off
title Depolama Kitabi - Diskini Bosalt
color 0B

echo.
echo  ========================================
echo       DEPOLAMA KITABI
echo      Diskini Bosalt
echo  ========================================
echo.
echo  Bu script disk dolulugu sorunlarini cozer.
echo  Gereksiz dosyalari temizler.
echo.
echo  Uyari: Yonetici haklari gerekli olabilir!
echo.
echo  Devam etmek icin bir tusa basin...
pause >nul

echo.
echo [BASLATILIYOR] Depolama Buyusu...
echo.

:: Yetki kontrolü
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [UYARI] Yonetici haklari yok, bazi ozellikler calismayabilir.
    echo.
)

:: PowerShell scriptini çalıştır
powershell -ExecutionPolicy Bypass -File "%~dp0depolama.ps1"

echo.
echo [TAMAMLANDI] Depolama Buyusu uygulandi!
echo.
pause
