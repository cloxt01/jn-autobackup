@echo off
setlocal enabledelayedexpansion

:: === PENGATURAN KONEKSI & FOLDER ===
set "SCP_USER=root"
set "SCP_PASS="
set "SCP_HOST="
set "SCP_PORT=22"
set "REMOTE_DIR=/path/to/backupdir"
set "LOCAL_DIR=C:\pato\to\lokaldir"


:: === PENGATURAN WAKTU TERPISAH ===
:: 1. Batas umur file di server yang akan didownload (hari)
set "DAYS_TO_DOWNLOAD=1"
:: 2. Batas umur file di folder lokal sebelum dihapus otomatis (hari)
set "DAYS_TO_KEEP_LOCAL=7"

:: === FILTER FILE AKHIRAN (SUFFIX) ===
set "FILE_SUFFIX=@jangkaunet.com.zip"

:: === LOKASI FOLDER LOG DI DALAM FOLDER SCRIPT (%~dp0log) ===
set "SCRIPT_DIR=%~dp0"
set "LOG_DIR=%SCRIPT_DIR%log"
set "LOG_FILE=%LOG_DIR%\backup_mailbox_log.txt"
set "WINSCP_LOG=%LOG_DIR%\winscp_mailbox_detail.log"

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
echo [%DATE% %TIME%] Memulai proses backup Mailbox Zimbra dari %SCP_HOST%...
echo [%DATE% %TIME%] Memulai proses backup Mailbox Zimbra dari %SCP_HOST%... >> "%LOG_FILE%"

:: === 2. BANGUN FILEMASK (BERDASARKAN DAYS_TO_DOWNLOAD) ===
set "FILEMASK=*%FILE_SUFFIX%>=%DAYS_TO_DOWNLOAD%D"

echo [DEBUG] Filter download WinSCP (maks %DAYS_TO_DOWNLOAD% hari): !FILEMASK!
echo [DEBUG] Retensi simpan lokal: %DAYS_TO_KEEP_LOCAL% hari
echo [DEBUG] Lokasi Log: %LOG_FILE%

:: === 3. DOWNLOAD FILE BARU VIA WINSCP ===
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

:: === 4. AUTO CLEANUP FILE LOKAL LAMA (BERDASARKAN DAYS_TO_KEEP_LOCAL) ===
echo.
echo [CLEANUP] Mengecek file lokal yang lebih tua dari %DAYS_TO_KEEP_LOCAL% hari...
echo [%DATE% %TIME%] Membersihkan file lokal yang lebih tua dari %DAYS_TO_KEEP_LOCAL% hari... >> "%LOG_FILE%"

forfiles /p "%LOCAL_DIR%" /s /m "*%FILE_SUFFIX%" /D -%DAYS_TO_KEEP_LOCAL% /C "cmd /c (echo [CLEANUP] Menghapus file lama: @file & echo [%DATE% %TIME%] [CLEANUP] Menghapus file lama: @file >> \"%LOG_FILE%\" & del /q @path)" 2>nul

:: Hapus sub-folder di lokal yang sudah kosong
for /f "delims=" %%D in ('dir "%LOCAL_DIR%" /s /b /ad ^| sort /r') do (
    rd "%%D" 2>nul && (
        echo [CLEANUP] Menghapus folder kosong: %%D
        echo [%DATE% %TIME%] [CLEANUP] Menghapus folder kosong: %%D >> "%LOG_FILE%"
    )
)

echo.
echo [%DATE% %TIME%] Proses selesai!
echo [%DATE% %TIME%] Proses selesai! >> "%LOG_FILE%"
echo ===================================================================== >> "%LOG_FILE%"
