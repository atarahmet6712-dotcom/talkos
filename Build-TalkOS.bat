@echo off
REM =============================================
REM  TalkOS ISO Builder - WSL Kurulum ve Build
REM  Bu scripti YONETICI olarak calistirin!
REM =============================================
echo.
echo ============================================
echo   TalkOS ISO Builder (WSL ile)
echo ============================================
echo.

REM WSL kontrol
wsl --status >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] WSL aktif degil. Bilgisayari yeniden baslatin.
    echo [!] Yeniden baslattiktan sonra bu scripti tekrar calistirin.
    pause
    exit /b 1
)

REM Debian kurulu mu kontrol et
wsl -d Debian -- echo "ok" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [*] Debian WSL yukleniyor...
    wsl --install -d Debian --no-launch
    echo [*] Debian kuruldu. Simdi build basliyor...
)

REM Proje dizinini WSL icinden erisim icin ayarla
set "WIN_PATH=%~dp0talkos-build"
echo [*] Proje dizini: %WIN_PATH%

REM WSL icerisinde build calistir
echo [*] WSL icerisinde build baslatiliyor...
echo [*] Bu islem 30-60 dakika surebilir. Lutfen bekleyin...
echo.

wsl -d Debian -u root -- bash -c "cd /mnt/c/Users/ahmet/Downloads/talkos && bash docker-build.sh"

if %ERRORLEVEL% equ 0 (
    echo.
    echo ============================================
    echo   BASARILI! ISO olusturuldu!
    echo   Konum: %~dp0TalkOS-amd64-bookworm.iso
    echo ============================================
) else (
    echo.
    echo [!] Build basarisiz oldu. Loglari kontrol edin.
)
pause
