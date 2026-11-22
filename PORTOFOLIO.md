# Portofolio: Jesica Bunga Keyla Simanjuntak

## 1. Identitas
- NIM: 2510512013
- Kelas A - Kelompok 5, Proyek 5B: Sistem Antrean Pekerjaan dan Monitoring Proses Linux
- Akun GitHub: keylatte
- Repository utama: https://github.com/ziyafauziyah14/sistem-antrean-5b
- Fork pribadi: https://github.com/keylatte/sistem-antrean-5b

## 2. Bagian yang dikerjakan (Mahasiswa 5)
Pemantauan CPU/memori, pengaturan user dan permission Linux, pembuatan `laporan.txt`, dan penghubungan ke Docker read-only.

## 3. Berkas yang saya buat
| Berkas | Fungsi |
| --- | --- |
| `scripts/monitor.sh` | Mencatat CPU dan memori ke `output/laporan.txt` |
| `config/setup_permission.sh` | Membuat grup `antrean`, akun `petugas` dan `tamu`, folder `/srv/antrean` |
| `tests/uji_permission.sh` | Uji hak akses dengan akun berbeda |
| `tests/uji_docker_readonly.sh` | Uji container Docker membaca laporan secara read-only |

## 4. Skenario uji
- (+) Container `alpine:3.20` membaca `laporan.txt` lewat bind mount read-only, exit 0. Akun `petugas` (anggota grup) menulis ke antrean, exit 0.
- (-) Container menulis ke `laporan.txt` ditolak (`Read-only file system`), exit 1, checksum host sama sebelum dan sesudah. Akun `tamu` (bukan anggota grup) ditolak menulis ke antrean (`Permission denied`), exit 1.

## 5. Commit dan bukti
- Commit 7d0b8f2 (PR #2, merge d1d63f4): monitoring, permission, Docker read-only
- Commit 1caf17b (PR #12, merge cfd070a): perbaikan `monitor.sh` memakai `vmstat`
- Bukti: `evidence/monitoring_beban.txt`, `evidence/permission_test.txt`, `evidence/docker_readonly.txt`

## 6. Konsep SO yang dipelajari
- Proteksi: izin owner/group/others dan prinsip least privilege
- CPU dan memori: pemantauan utilisasi sumber daya
- Isolasi: bind mount read-only pada container

## 7. Kendala dan solusi
1. **Login `git push` ditolak.** Password biasa tidak didukung GitHub untuk operasi Git. Solusinya memakai Personal Access Token.
2. **VM tidak responsif.** Dua proses `yes` berjalan bersamaan di VM 2 vCPU. Solusinya `pkill yes` dan memakai satu proses dengan `nice -n 19`.
3. **Pengukuran CPU salah baca.** `awk` mengambil kolom `top` yang posisinya bergeser, sehingga CPU yang menganggur terbaca 100%. Solusinya beralih ke `vmstat`.
4. **Beban berat belum terlihat jelas.** Pada sesi pengukuran akhir, CPU beban berat belum menunjukkan kenaikan yang nyata. Proses beban perlu dipastikan berjalan (dengan `vmstat` atau `pgrep`) sebelum mengukur.

## 8. Refleksi
Hal yang paling saya pelajari dari proyek ini adalah bagaimana mekanisme proteksi dan isolasi pada sistem operasi Linux bekerja secara nyata, khususnya penerapan prinsip *least privilege* melalui pembagian *user*, *group*, dan *permission* berkas, serta pembatasan akses kontainer Docker menggunakan *bind mount read-only* agar integritas data di host tetap terjaga.

Bagian yang paling sulit bagi saya adalah mendapatkan hasil pengukuran utilisasi CPU yang akurat sekaligus menjaga VM tetap responsif saat pengujian beban. Pada percobaan awal, menjalankan dua proses `yes` secara bersamaan membuat VM sempat *hang*, yang kemudian saya atasi dengan memakai satu proses berprioritas rendah (`nice -n 19`). Selain itu, pembacaan kolom `top` menggunakan `awk` sempat menghasilkan angka yang keliru, sehingga saya beralih menggunakan `vmstat`. Penyesuaian autentikasi `git push` menggunakan Personal Access Token serta pengelolaan sesi `sudo` saat menjalankan skrip pengujian otomatis juga cukup menantang di awal.

Jika mengerjakan proyek serupa di lain waktu, saya akan menguji potongan perintah pemrosesan teks seperti `awk` dan `vmstat` langsung di terminal pada sampel kecil terlebih dahulu sebelum memasukkannya ke dalam skrip otomatis. Saya juga akan memeriksa kapasitas sumber daya VM (seperti jumlah vCPU) dan memastikan proses beban benar-benar berjalan sebelum mengukur, serta memastikan kredensial Git dan sesi autentikasi siap sebelum menjalankan skrip pengujian agar proses berjalan lebih efisien.

## Sumber dan bantuan
- Manual Linux: `man chmod`, `man chown`, `man vmstat`, `man free`, `man nice`.
- Silberschatz, Galvin, Gagne. *Operating System Concepts*.
- Dokumentasi Docker: bind mounts.
- Modul Praktikum dan Panduan Proyek Akhir Sistem Operasi, UPN "Veteran" Jakarta.
- Saya memakai asisten AI (Claude) untuk membantu memahami tugas, menyusun draf skrip dan panduan langkah, serta merapikan dokumentasi. Seluruh pengujian saya jalankan sendiri di VM.
- VM Ubuntu 26.04 LTS (VirtualBox), 2 vCPU, 3,3 GB RAM.
