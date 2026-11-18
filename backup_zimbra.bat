@echo off
setlocal enabledelayedexpansion


:: === PENGATURAN KONEKSI & FOLDER ===
set "SCP_USER=root"
set "SCP_PASS="
set "SCP_HOST="
set "SCP_PORT=22"
set "REMOTE_DIR=/path/to/backupdir"
set "LOCAL_DIR=C:\pato\to\lokaldir"
set "DAYS_TO_KEEP=7"


:: === ARRAY PREFIX (Pisahkan dengan spasi jika ingin menambah lagi) ===
set "PREFIX_LIST=zimbra_mysql_"

:: === LOKASI FOLDER LOG DI DALAM FOLDER SCRIPT (%~dp0log) ===
set "SCRIPT_DIR=%~dp0"
set "LOG_DIR=%SCRIPT_DIR%log"
set "LOG_FILE=%LOG_DIR%\backup_zimbra_log.txt"
set "WINSCP_LOG=%LOG_DIR%\winscp_zimbra_detail.log"

:: === AUTO DETEKSI LOKASI WINSCP.COM ===
set "WINSCP_EXE=WinSCP.com"
if exist "C:\Program Files (x86)\WinSCP\WinSCP.com" (
    set "WINSCP_EXE=C:\Program Files (x86)\WinSCP\WinSCP.com"
) else if exist "C:\Program Files\WinSCP\WinSCP.com" (
    set "WINSCP_EXE=C:\Program Files\WinSCP\WinSCP.com"
) else if exist "%LOCALAPPDATA%\Programs\WinSCP\WinSCP.com" (
    set "WINSCP_EXE=%LOCALAPPDATA%\Programs\WinSCP\WinSCP.com"
)

:: === 1. BUAT FOLDER LOKAL & FOLDER LOG JIKA BELUM ADA ===
if not exist "%LOCAL_DIR%" mkdir "%LOCAL_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: === CATAT WAKTU MULAI ===
echo ===================================================================== >> "%LOG_FILE%"
echo [%DATE% %TIME%] Memulai proses backup Zimbra dari %SCP_HOST%...
echo [%DATE% %TIME%] Memulai proses backup Zimbra dari %SCP_HOST%... >> "%LOG_FILE%"

:: === 2. BANGUN FILEMASK (HANYA FOLDER UTAMA, ABAIKAN SUB-FOLDER) ===
set "FILEMASK="
for %%P in (%PREFIX_LIST%) do (
    if "!FILEMASK!"=="" (
        set "FILEMASK=%%P*>=%DAYS_TO_KEEP%D"
    ) else (
        set "FILEMASK=!FILEMASK!; %%P*>=%DAYS_TO_KEEP%D"
    )
)
set "FILEMASK=!FILEMASK! | */"

echo [DEBUG] Filter download WinSCP: !FILEMASK!
echo [DEBUG] Lokasi Log: %LOG_FILE%

:: === 3. DOWNLOAD FILE BARU VIA WINSCP (AUTO ACCEPT HOSTKEY) ===
"%WINSCP_EXE%" /ini=nul /log="%WINSCP_LOG%" /command ^
    "open scp://%SCP_USER%:%SCP_PASS%@%SCP_HOST%:%SCP_PORT%/ -hostkey=""*""" ^
    "lcd ""%LOCAL_DIR%""" ^
    "cd ""%REMOTE_DIR%""" ^
    "get -neweronly -filemask=""!FILEMASK!"" *" ^
    "exit"

if !errorlevel! equ 0 (
    echo [SUKSES] Proses download dari %SCP_HOST% selesai!
    echo [%DATE% %TIME%] [SUKSES] Proses download selesai! >> "%LOG_FILE%"
) else (
    echo [ERROR] Terjadi kesalahan saat download. Cek %WINSCP_LOG%
    echo [%DATE% %TIME%] [ERROR] Terjadi kesalahan saat download! >> "%LOG_FILE%"
)

:: === 4. AUTO CLEANUP FILE LOKAL LAMA ===
echo.
echo [CLEANUP] Mengecek file lokal yang lebih tua dari %DAYS_TO_KEEP% hari...
echo [%DATE% %TIME%] Membersihkan file lokal yang lebih tua dari %DAYS_TO_KEEP% hari... >> "%LOG_FILE%"

for %%P in (%PREFIX_LIST%) do (
    forfiles /p "%LOCAL_DIR%" /s /m %%P* /D -%DAYS_TO_KEEP% /C "cmd /c (echo [CLEANUP] Menghapus file lama: @file & echo [%DATE% %TIME%] [CLEANUP] Menghapus file lama: @file >> \"%LOG_FILE%\" & del /q @path)" 2>nul
)

echo.
echo [%DATE% %TIME%] Proses selesai!
echo [%DATE% %TIME%] Proses selesai! >> "%LOG_FILE%"
echo ===================================================================== >> "%LOG_FILE%"
