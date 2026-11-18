# 📦 Automated Backup Center (Cacti, Radius & Zimbra)

Dokumentasi ini menjelaskan arsitektur, konfigurasi, dan cara penggunaan kumpulan skrip Batch Windows (`.bat`) untuk menarik (*pull*) data cadangan secara otomatis dari server remote ke PC server lokal menggunakan protokol SCP/SFTP (**WinSCP**).

---

## 📂 Daftar Skrip & Target Server

| No | Nama Layanan | IP Remote (`SCP_HOST`) | Folder Sumber Remote (`REMOTE_DIR`) | Folder Tujuan Lokal (`LOCAL_DIR`) | Pola / Filter File |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **1** | **Cacti Backup** | `103.174.121.4` | `/root/backup_cactidb` | `C:\BackupDB\cacti` | `backupCactidb_*`, `cacti_files_backup_*` |
| **2** | **Radius Backup** | `103.174.121.3` | `/root/backup_radiusdb` | `C:\BackupDB\radius` | `backupRadiusdb_*` |
| **3** | **Zimbra MySQL** | `103.174.121.18` | `/opt/zimbra/backup/mailbox` | `C:\BackupDB\zimbra` | `zimbra_mysql_*` |
| **4** | **Zimbra Mailbox** | `103.174.121.18` | `/opt/zimbra/backup/mailbox` | `C:\BackupDB\zimbra` | `*@jangkaunet.com.zip` |

---

## ⚙️ Fitur Utama


1. **Download Selektif (`-neweronly` & Filemask):** Hanya mengunduh file baru berdasarkan rentang hari yang ditentukan (`DAYS_TO_KEEP` / `DAYS_TO_DOWNLOAD`) sehingga menghemat bandwidth.
3. **Auto-Cleanup & Retensi Lokal:** Otomatis menghapus file cadangan lokal yang melebihi batas retensi (default **7 hari**) beserta sub-folder kosong di dalamnya (khusus Zimbra Mailbox).

---

## 🛠️ Prasyarat (Prerequisites)

1. **Sistem Operasi:** Windows / Windows Server.
2. **WinSCP:** Sudah terinstal pada PC lokal.

---

## 🎛️ Struktur Direktori yang Disarankan

```text
C:\BackupDB\                    <-- Working directiry
├── task.xml                  
├── backup_cacti.bat
├── backup_radius.bat
├── backup_zimbra_mysql.bat
├── backup_zimbra_mailbox.bat
├── run.bat
│   └── log\                       <-- Otomatis dibuat saat skrip berjalan
│       ├── backup_cacti_log.txt
│       ├── winscp_cacti_detail.log
│       └── ...
├── cacti\                         <-- Hasil backup Cacti
├── radius\                        <-- Hasil backup Radius
└── zimbra\                        <-- Hasil backup Zimbra (MySQL & Mailbox)
```

---

## 🚀 Cara Penjadwalan Otomatis (Task Scheduler)

Agar seluruh proses backup berjalan otomatis setiap hari tanpa interaksi manual:

### Opsi A: Menggunakan Import XML (Jika file `task.xml` tersedia)
Buka **Command Prompt (Run as Administrator)** dan jalankan perintah:
```cmd
schtasks /create /xml "C:\BackupDB\task.xml" /tn "Auto Backup Database"
```

### Opsi B: Setup Manual via GUI Task Scheduler
1. Buka **Task Scheduler** dari menu Start.
2. Klik **Create Task...** di panel sebelah kanan.
3. Pada tab **General**:
   * **Name:** `Backup Radius Cacti Zimbra`
   * Pilih **Run whether user is logged on or not** dan centang **Run with highest privileges**.
4. Pada tab **Triggers**:
   * Klik **New...**, pilih **Daily**, dan atur jam eksekusi (disarankan dini hari, misal `02:30:00`, setelah proses backup di sisi server Linux selesai).
5. Pada tab **Actions**:
   * Klik **New...** untuk menambahkan setiap skrip `.bat` secara berurutan:
     * **Action:** `Start a program`
     * **Program/script:** `C:\BackupDB\script\backup_cacti.bat` *(sesuaikan lokasi file)*
     * **Start in (optional):** `C:\BackupDB\script\`
   * Ulangi langkah ini untuk skrip Radius, Zimbra MySQL, dan Zimbra Mailbox.
6. Klik **OK** dan masukkan password Administrator Windows saat diminta.


---

## 🔍 Troubleshooting

* **File gagal terunduh (`[ERROR]`):** Periksa file `winscp_*_detail.log` di folder `log/` untuk melihat penyebab spesifik 