@echo off
title Nefes Kitabi - Bilgisayari Nefes Aldir
color 0B

echo.
echo  ========================================
echo         NEFES KITABI
echo    Bilgisayari Nefes Aldir
echo  ========================================
echo.
echo  Bu script bilgisayarinizi hizlandirir.
echo  Gecici dosyalari temizler, RAM bosaltir.
echo.
echo  �Uyari: Yonetici haklari gerekli!
echo.
echo  Devam etmek icin bir tusa basin...
pause >nul

echo.
echo [BASLATILIYOR] Nefes Buyusu...
echo.

:: Yetki kontrolü
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [HATA] Bu script yonetici haklari ile calistirilmali!
    echo.
    echo Sag tikla - "Yonetici olarak calistir" secenegiyle acin.
    echo.
    pause
    exit /b 1
)

:: PowerShell scriptini çalıştır
powershell -ExecutionPolicy Bypass -File "%~dp0nefes.ps1"

echo.
echo [TAMAMLANDI] Nefes Buyusu uygulandi!
echo.
pause
