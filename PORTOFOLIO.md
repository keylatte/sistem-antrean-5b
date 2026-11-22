# Portofolio Git: Fauziyah Zharfan Auliya

## 1. Identitas

- Nama / NIM: Fauziyah Zharfan Auliya / 2510512006
- Kelas dan kelompok: Kelas A, Kelompok 5
- Proyek: Pilihan 5B, Sistem Antrean Pekerjaan dan Monitoring Proses Linux
- Bagian saya: Anggota 2, antrean FIFO dan file lock
- Akun Git: `ziyafauziyah14`. Commit dari terminal VM tercatat atas nama `ziyafauziyah14`, sedangkan perubahan lewat antarmuka web GitHub tercatat atas nama profil `zeefazhh`. Keduanya akun saya dan memakai email yang sama (fauziyah.zharfan@gmail.com).

## 2. Asal proyek

Proyek ini dikerjakan secara berkelompok (5 anggota). Saya tidak mengklaim seluruhnya sebagai karya pribadi.

- Repository utama: https://github.com/ziyafauziyah14/sistem-antrean-5b
- Anggota: Nadiefa Khairina Lesmana (pengajuan dan validasi), Fauziyah Zharfan Auliya (antrean FIFO dan lock), Mysha Salma Aqila (status, PID, exit status), Ranita Carissa Siahaan (timeout dan penghentian), Jesica Bunga Keyla Simanjuntak (monitoring, akses, laporan, Docker).
- Commit acuan repository utama: [isi 7 karakter hash `main` saat pengumpulan]

## 3. Kontribusi pribadi

- `scripts/worker.sh`: worker yang memproses antrean secara berurutan (FIFO) dan memasang file lock `/tmp/worker.lock` dengan `flock -n` agar worker kedua ditolak. Komponen anggota lain (timeout, status, PID, log) kemudian disambungkan teman di titik eksekusi pekerjaan.
- `tests/data/antrean_contoh.txt` dan `tests/langkah_uji_worker.md`: data dan langkah uji positif dan negatif.
- `.gitignore`: mencegah log, antrean aktif, dan berkas VM ikut ter-commit.
- Bagian README tentang menjalankan dan menguji worker, serta penyusunan README kelompok (anggota, struktur repository, matriks skenario dan hasil).
- `evidence/antrean_fifo_lock.txt`: bukti uji TC-02-P dan TC-02-N dari terminal VM.
- Perbaikan integrasi: menemukan bahwa `config/queue.conf` yang berisi catatan perintah ikut dijalankan oleh `source` dan membuat worker memanggil dirinya sendiri berulang-ulang, lalu memperbaikinya (PR #10).

Bagian lain dikerjakan anggota lain: validasi pengajuan, status dan exit status, timeout, monitoring, permission, dan Docker.

## 4. Bukti kontribusi

| Commit | Tanggal | Keterangan |
| --- | --- | --- |
| bdc3ec6 | 13/11/2026 | Tambah worker.sh: antrean FIFO dengan lock flock (PR #1) |
| 3de7715 | 13/11/2026 | Tambah contoh antrean dummy untuk uji FIFO |
| fd4719f | 16/11/2026 | Tambah .gitignore (PR #4) |
| 47bef15 | 17/11/2026 | Tambah langkah uji worker (TC-02-P dan TC-02-N) (PR #4) |
| 7dee1bf | 17/11/2026 | Tambah petunjuk menjalankan dan menguji worker (PR #5) |
| d41fa64 | 17/11/2026 | Tambah bukti uji FIFO dan lock (PR #6) |
| c51cf49 | 18/11/2026 | Sesuaikan pesan penolakan lock di README dan langkah uji (PR #8) |
| d851393 | 20/11/2026 | Kembalikan queue.conf hanya berisi MAX_TIMEOUT (PR #10) |
| 4d9f864 | 20/11/2026 | Susun README kelompok (diubah lewat antarmuka web) |

Pull request: #1, #4, #5, #6, #8, #10 pada repository utama. Penelusuran lengkap: `git log --author=ziyafauziyah14` dan `git log --author=zeefazhh`.

## 5. Skenario individu

- **Tujuan:** pekerjaan diproses berurutan sesuai urutan masuk, dan hanya satu worker yang boleh berjalan pada satu waktu.
- **Kondisi awal:** tidak ada worker berjalan, `data/antrean.txt` berisi tiga pekerjaan (`tests/data/antrean_contoh.txt`).
- **Positif (TC-02-P):** pekerjaan satu, dua, tiga diproses berurutan lalu worker menyatakan "Antrean kosong."; exit status 0.
- **Negatif (TC-02-N):** worker pertama dijalankan di latar belakang dengan pekerjaan `sleep`; worker kedua yang dijalankan saat itu mencetak "Worker lain sedang berjalan" dan exit status 1; worker pertama tetap selesai.
- **Verifikasi:** urutan keluaran dan nilai `echo $?` (0 untuk positif, 1 untuk negatif).
- **Pemulihan:** isi ulang antrean dengan `cp tests/data/antrean_contoh.txt data/antrean.txt`. Lock lepas otomatis saat worker selesai.
- **Langkah dan hasil:** `tests/langkah_uji_worker.md` dan `evidence/antrean_fifo_lock.txt`. Bukti ini direkam dengan versi awal worker (commit bdc3ec6); versi terintegrasi memuat baris status tambahan dari komponen anggota lain, tetapi urutan FIFO dan penolakan lock sama.

## 6. Analisis konsep sistem operasi

**Sinkronisasi dan critical section.** Tanpa lock, dua worker yang berjalan bersamaan dapat membaca baris pertama antrean yang sama sebelum salah satunya menghapusnya, sehingga satu pekerjaan diproses dua kali. Dua perintah `sed -i '1d'` berurutan juga dapat menghapus dua baris padahal hanya satu pekerjaan yang diproses. Ini contoh race condition. Bagian dari `head` sampai `sed` adalah critical section. `flock -n` menerapkan mutual exclusion: hanya satu worker yang boleh masuk, worker lain langsung ditolak tanpa menunggu. Kernel melepas lock otomatis saat proses berakhir, sehingga tidak ada lock tersangkut.

**Antrean dan penjadwalan.** FIFO pada proyek ini adalah urutan baris pada file antrean (antrean aplikasi), bukan perubahan algoritma penjadwalan CPU. Penjadwal kernel Linux tetap memutuskan proses mana yang memakai CPU dan kapan.

**Deadlock.** Deadlock memerlukan mutual exclusion, hold and wait, no preemption, dan circular wait. Worker hanya memakai satu lock dan tidak pernah menunggu (`-n`), sehingga tidak ada hold and wait atau circular wait. Ini analisis desain, bukan implementasi deteksi deadlock.

**Proses dan sistem berkas.** Setiap pekerjaan dijalankan sebagai proses anak lewat `bash -c`, dan worker menunggunya selesai sebelum mengambil pekerjaan berikutnya. `sed -i` menulis ulang file lewat file sementara, sehingga lock saya taruh pada file terpisah (`/tmp/worker.lock`), bukan pada file antrean. `flock` bersifat advisory: hanya efektif bagi proses yang memakainya, sehingga pembatasan siapa yang boleh menulis antrean dilakukan lewat permission (bagian anggota lain).

## 7. Kendala dan penyelesaian

1. **`[-s: command not found`.** Pada `while`, tidak ada spasi setelah `[`. Di Bash `[` adalah perintah sehingga harus dipisah spasi: `while [ -s "$QUEUE" ]`.
2. **Uji lock awalnya tidak menolak.** Worker pertama sudah selesai sebelum worker kedua dijalankan, jadi tidak ada lock yang dipegang. Solusinya memakai `sleep` yang cukup lama dan menjalankan worker pertama dengan `&`, lalu worker kedua dijalankan satu detik kemudian.
3. **Catatan tertempel ke terminal sebagai perintah.** Baris bernomor dari catatan uji ikut dijalankan dan menghasilkan `1.: command not found`. Catatan harus ditempel ke editor atau berkas, bukan ke terminal.
4. **Folder `data/` dan `logs/` tidak ada setelah clone.** Keduanya diabaikan `.gitignore` dan Git tidak menyimpan folder kosong, sehingga antrean kosong atau muncul "No such file or directory". Solusinya `mkdir -p data logs` pada petunjuk README.
5. **Konflik riwayat Git (divergent branches).** Commit bukti terduplikasi di `main` lokal. Saya menyimpan cadangan di cabang terpisah, menyamakan `main` dengan GitHub, lalu menghapus cadangan setelah isinya terverifikasi sudah ada di GitHub.
6. **Pesan penolakan lock berubah setelah integrasi.** Worker terintegrasi mencetak "Worker lain sedang berjalan" tanpa kata "Ditolak". Dokumentasi saya disesuaikan lewat PR #8 (c51cf49).
7. **`queue.conf` memicu rekursi worker.** `worker.sh` memuat `config/queue.conf` dengan `source`. Setelah teman menambahkan catatan demo berisi perintah ke berkas itu, catatan ikut dijalankan dan memanggil `worker.sh` lagi tanpa henti. Saya mengembalikan isinya menjadi `MAX_TIMEOUT=5` (PR #10, d851393) dan memberi tahu pemilik berkas.

## 8. Refleksi

- **Sudah dikuasai:** Membuat cara kerja "flock", perbedaan FIFO aplikasi dan penjadwalan CPU, serta membaca dan menjalankan exit status
- **Masih perlu dipelajari:** menyelesaikan konflik merge yang lebih rumit.
- **Pelajaran dari kerja kelompok:** file bersama seperti `worker.sh` dan `queue.conf` mudah rusak kalau diubah tanpa saling memberi tahu, jadi perubahan perlu lewat pull request dan dikomunikasikan.

## Sumber dan bantuan

- Manual Linux: `man flock`, `man head`, `man sed`, `man bash`, `man timeout`.
- Silberschatz, Galvin, Gagne. *Operating System Concept
- Modul Praktikum dan Panduan Project Akhir Sistem Operasi, UPN "Veteran" Jakarta.
- Saya memakai asisten AI (Claude) untuk membantu menyusun dfaf dokumentasi ke github
- VM Ubuntu
