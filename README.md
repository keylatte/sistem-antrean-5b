# sistem-antrean-5b

Project akhir Sistem Operasi (Kelas A, Kelompok 5), Pilihan 5B: Sistem Antrean Pekerjaan dan Monitoring Proses Linux.

Sistem ini mengelola antrean pekerjaan sederhana di Linux (Bash): pekerjaan yang diajukan divalidasi dengan whitelist, diproses berurutan (FIFO) oleh satu worker yang dilindungi lock, dicatat status/PID/exit status-nya, dibatasi waktu eksekusinya, dipantau CPU/memorinya, dan ringkasan laporannya dibaca oleh container Docker secara read-only. FIFO di sini adalah antrean aplikasi, bukan perubahan penjadwalan CPU kernel.

## Anggota dan pembagian

| Anggota | Bagian | Berkas utama |
| --- | --- | --- |
| Nadiefa Khairina Lesmana | Pengajuan dan validasi (whitelist) | `scripts/submit_job.sh`, `config/whitelist.conf` |
| Fauziyah Zharfan Auliya | Antrean FIFO dan lock | `scripts/worker.sh` |
| Mysha Salma Aqila | Status, PID, dan exit status | `scripts/status_job.sh` |
| Ranita Carissa Siahaan | Timeout dan penghentian | `config/queue.conf`, `tests/job_cepat.sh`, `tests/job_lama.sh` |
| Jesica Bunga Keyla Simanjuntak | Monitoring, akses, laporan, dan Docker | `scripts/monitor.sh`, `config/setup_permission.sh`, `output/laporan.txt` |

## Struktur repository

- `scripts/`: skrip utama (pengajuan, worker, status, monitoring)
- `config/`: konfigurasi (whitelist, batas waktu, setup user/grup)
- `tests/`: skrip dan data uji
- `evidence/`: bukti uji terpilih dari terminal
- `output/`: `laporan.txt` yang dibaca container Docker
- `docs/`: laporan akhir

## Matriks skenario dan hasil

| ID | Penanggung jawab | Positif | Negatif | Hasil aktual | Status | Bukti |
| --- | --- | --- | --- | --- | --- | --- |
| A1 | Diefa | `sleep 2` dan `echo Halo Sistem Operasi` diterima masuk antrean | `whoami` (di luar whitelist), `sleep` tanpa parameter, dan `sleep 1; rm -rf /` (indikasi injeksi) ditolak | Positif: exit 0, pekerjaan masuk `data/antrean.txt`. Negatif: exit 1, 2, dan 3 | Lulus | `evidence/input_whitelist_test.txt` |
| A2 | Fauziyah Zharfan Auliya | Tiga pekerjaan diproses sesuai urutan masuk (FIFO) | Worker kedua ditolak saat worker pertama aktif | Positif: pekerjaan satu, dua, tiga berurutan, exit 0. Negatif: "Worker lain sedang berjalan", exit 1 | Lulus | `evidence/antrean_fifo_lock.txt` |
| A3 | Mysha Salma Aqila | `sleep 1` tercatat BERHASIL | `bash -c 'exit 3'` tercatat GAGAL | Positif: STATUS=BERHASIL, EXIT=0. Negatif: STATUS=GAGAL, EXIT=3. Tanpa parameter: exit 2 | Lulus | `evidence/status_test.txt`, `evidence/status_pid_exit.txt` |
| A4 | Ranita Carissa Siahaan| `job_cepat` selesai sebelum batas waktu | `job_lama` melewati batas waktu dihentikan | Positif: BERHASIL, exit 0. Negatif: GAGAL/TIMEOUT, exit 124 (MAX_TIMEOUT=5) | Lulus | `evidence/uji_timeout.txt` |
| A5 | Keyla | Container (alpine:3.20) membaca `laporan.txt`; petugas (grup antrean) menulis ke antrean | Container menulis ke mount read-only; tamu (bukan anggota grup) menulis ke antrean | Positif: laporan tampil, exit 0; petugas exit 0. Negatif: "Read-only file system", exit 1, checksum sama sebelum dan sesudah; tamu "Permission denied", exit 1 | Lulus | `evidence/docker_readonly.txt`, `evidence/permission_test.txt`, `evidence/monitoring_beban.txt` |

Format kolom tabel ini mengikuti contoh README kelompok lain. Seluruh isinya diambil dari bukti pengujian kelompok sendiri.

## Menjalankan sistem

Jalankan semua perintah dari folder utama repository.

```bash
mkdir -p data logs
chmod +x scripts/*.sh tests/*.sh
```

1. Ajukan pekerjaan (divalidasi whitelist): `./scripts/submit_job.sh sleep 2`
2. Jalankan worker: `./scripts/worker.sh`

## Menguji worker (antrean FIFO dan lock)

Worker (`scripts/worker.sh`) memproses `data/antrean.txt` secara berurutan (baris teratas lebih dulu) dan memasang file lock `/tmp/worker.lock` agar worker kedua yang berjalan bersamaan ditolak.

Uji positif (FIFO):

```bash
cp tests/data/antrean_contoh.txt data/antrean.txt
./scripts/worker.sh
echo $?
```

Hasil diharapkan: pekerjaan satu, dua, tiga berurutan dan exit status `0`.

Uji negatif (worker kedua ditolak). Angka `sleep` harus lebih kecil dari `MAX_TIMEOUT` di `config/queue.conf`:

```bash
printf 'echo pekerjaan satu\nsleep 3\necho pekerjaan dua\n' > data/antrean.txt
./scripts/worker.sh & sleep 1; ./scripts/worker.sh; echo $?; wait
```

Hasil diharapkan: worker kedua mencetak `Worker lain sedang berjalan` dan exit status `1`.

## Menguji komponen lain

- Pengajuan dan whitelist: `tests/uji_input_whitelist.sh`
- Status, PID, exit status: `tests/uji_status.sh`
- Timeout: `tests/job_cepat.sh` (selesai sebelum batas) dan `tests/job_lama.sh` (melewati batas)
- Akses dan permission: `config/setup_permission.sh` dan `tests/uji_permission.sh`
- Docker read-only: `tests/uji_docker_readonly.sh`

Rincian langkah dan hasil tiap uji ada di folder `evidence/`.

## Pemulihan

Setelah uji, antrean kosong. Isi ulang dengan `cp tests/data/antrean_contoh.txt data/antrean.txt`. File lock lepas otomatis saat worker selesai.
