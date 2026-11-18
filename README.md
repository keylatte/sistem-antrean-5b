# sistem-antrean-5b
Project akhir OS - Sistem Antrean Pekerjaan dan Monitoring Proses Linux


## Menjalankan dan menguji worker (Anggota 2: antrean FIFO dan lock)

Worker (`scripts/worker.sh`) memproses antrean `data/antrean.txt` secara berurutan (FIFO, baris teratas lebih dulu) dan memasang file lock `/tmp/worker.lock` agar worker kedua yang berjalan bersamaan ditolak. FIFO di sini adalah antrean aplikasi, bukan penjadwalan CPU kernel.

Kebutuhan: Linux dengan Bash dan `flock` (paket util-linux, bawaan Ubuntu). Jalankan semua perintah dari folder utama repository.

### Persiapan (sekali saja)

```bash
mkdir -p data
chmod +x scripts/worker.sh
```

### Uji positif (TC-02-P): pekerjaan diproses urut FIFO

```bash
cp tests/data/antrean_contoh.txt data/antrean.txt
./scripts/worker.sh
echo $?
```

Hasil diharapkan: pekerjaan satu, dua, tiga muncul berurutan, lalu `Antrean kosong.`, dan exit status `0`.

### Uji negatif (TC-02-N): worker kedua ditolak

```bash
printf 'echo pekerjaan satu\nsleep 60\necho pekerjaan dua\n' > data/antrean.txt
./scripts/worker.sh &
sleep 1
./scripts/worker.sh
echo $?
wait
```

Hasil diharapkan: worker kedua mencetak `Worker lain sedang berjalan` dan exit status `1`. Worker pertama tetap berjalan sampai selesai (`wait` menunggunya).

### Pemulihan

Setelah uji, antrean kosong. Isi ulang dengan `cp tests/data/antrean_contoh.txt data/antrean.txt`. File lock lepas otomatis saat worker selesai, jadi tidak ada yang perlu dibersihkan manual.

Rincian langkah uji ada di `tests/langkah_uji_worker.md`.
