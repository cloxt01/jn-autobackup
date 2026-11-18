@echo off
setlocal
cd /d "%~dp0"

:: === LOKASI FOLDER SCRIPT & LOG UTAMA ===
set "SCRIPT_DIR=%~dp0"
set "LOG_DIR=%SCRIPT_DIR%log"
set "MASTER_LOG=%LOG_DIR%\master_backup_log.txt"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: === FUNGSI AMAN UNTUK LOG & LAYAR ===
call :LogMsg "====================================================================="
call :LogMsg "=== MEMULAI SELURUH PROSES BACKUP OTOMATIS ==="

:: === 1. JALANKAN BACKUP RADIUS ===
if exist "%SCRIPT_DIR%backup_radius.bat" (
    call :LogMsg "[1/4] Menjalankan backup_radius.bat..."
    call "%SCRIPT_DIR%backup_radius.bat"
    call :LogMsg "[1/4] Selesai backup_radius.bat (Exit Code: %errorlevel%)"
) else (
    call :LogMsg "[SKIP] File backup_radius.bat tidak ditemukan."
)

:: === 2. JALANKAN BACKUP CACTI ===
if exist "%SCRIPT_DIR%backup_cacti.bat" (
    call :LogMsg "[2/4] Menjalankan backup_cacti.bat..."
    call "%SCRIPT_DIR%backup_cacti.bat"
    call :LogMsg "[2/4] Selesai backup_cacti.bat (Exit Code: %errorlevel%)"
) else (
    call :LogMsg "[SKIP] File backup_cacti.bat tidak ditemukan."
)

:: === 3. JALANKAN BACKUP ZIMBRA DB ===
if exist "%SCRIPT_DIR%backup_zimbra.bat" (
    call :LogMsg "[3/4] Menjalankan backup_zimbra.bat..."
    call "%SCRIPT_DIR%backup_zimbra.bat"
    call :LogMsg "[3/4] Selesai backup_zimbra.bat (Exit Code: %errorlevel%)"
) else (
    call :LogMsg "[SKIP] File backup_zimbra.bat tidak ditemukan."
)

:: === 4. JALANKAN BACKUP ZIMBRA MAILBOX ===
if exist "%SCRIPT_DIR%backup_zimbra_mailbox.bat" (
    call :LogMsg "[4/4] Menjalankan backup_zimbra_mailbox.bat..."
    call "%SCRIPT_DIR%backup_zimbra_mailbox.bat"
    call :LogMsg "[4/4] Selesai backup_zimbra_mailbox.bat (Exit Code: %errorlevel%)"
) else (
    call :LogMsg "[SKIP] File backup_zimbra_mailbox.bat tidak ditemukan."
)

:: === SELESAI ===
call :LogMsg "=== SELURUH PROSES BACKUP SELESAI ==="
call :LogMsg "====================================================================="
goto :EOF

:LogMsg
echo [%DATE% %TIME%] %~1
echo [%DATE% %TIME%] %~1 >> "%MASTER_LOG%" 2>nul
goto :EOF
