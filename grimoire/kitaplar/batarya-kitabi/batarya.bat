@echo off
title Batarya Kitabi - Pil Omrunu Uzat
color 0B
echo.
echo  ========================================
echo       BATARYA KITABI
echo      Pil Omrunu Uzat
echo  ========================================
echo.
echo  Bu script pil durumunu gosterir ve
echo  guc planini tasarruf moduna alir.
echo.
pause >nul
powershell -ExecutionPolicy Bypass -File "%~dp0batarya.ps1"
echo.
echo [TAMAMLANDI]
pause
