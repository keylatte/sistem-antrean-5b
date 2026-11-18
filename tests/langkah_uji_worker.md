# Uji Anggota 2: worker antrean FIFO dan lock

Jalankan dari folder utama repository.

## Persiapan (sekali saja)
```bash
mkdir -p data
chmod +x scripts/worker.sh
```

## TC-02-P (positif): pekerjaan diproses urut FIFO
```bash
cp tests/data/antrean_contoh.txt data/antrean.txt
./scripts/worker.sh
echo $?
```
Diharapkan: pekerjaan satu, dua, tiga berurutan, lalu "Antrean kosong.", exit status 0.

## TC-02-N (negatif): worker kedua ditolak
```bash
printf 'echo pekerjaan satu\nsleep 60\necho pekerjaan dua\n' > data/antrean.txt
./scripts/worker.sh &
sleep 1
./scripts/worker.sh
echo $?
wait
```
Diharapkan: "Worker lain sedang berjalan", exit status 1.

## Pemulihan
Isi ulang antrean: `cp tests/data/antrean_contoh.txt data/antrean.txt`. File lock lepas otomatis saat worker selesai.
