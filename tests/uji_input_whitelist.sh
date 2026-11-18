#!/bin/bash

echo "=========================================="
echo "UJI DEMO INPUT PEKERJAAN & WHITELIST"
echo "=========================================="

mkdir -p data
: > data/antrean.txt

echo -e "\n[1] Skenario Positif (+): Input valid 'sleep 2'"
./scripts/submit_job.sh sleep 2
echo "exit status: $?"

echo -e "\n[2] Skenario Positif (+): Input valid 'echo Halo Sistem Operasi'"
./scripts/submit_job.sh echo Halo Sistem Operasi
echo "exit status: $?"

echo -e "\n[3] Skenario Negatif (-): Perintah di luar whitelist 'whoami'"
./scripts/submit_job.sh whoami
echo "exit status: $?"

echo -e "\n[4] Skenario Negatif (-): Parameter kosong/salah 'sleep'"
./scripts/submit_job.sh sleep
echo "exit status: $?"

echo -e "\n[5] Skenario Negatif (-): Indikasi command injection 'sleep 1; rm -rf /'"
./scripts/submit_job.sh "sleep 1; rm -rf /"
echo "exit status: $?"

echo -e "\n=== Isi File Antrean (data/antrean.txt) ==="
cat data/antrean.txt

echo -e "\n=== Isi Log Pengajuan (logs/submit.log) ==="
cat logs/submit.log
