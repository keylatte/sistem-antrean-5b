#!/bin/bash

WHITELIST="config/whitelist.conf"
QUEUE="data/antrean.txt"
LOG="logs/submit.log"

mkdir -p data logs

# 1. Validasi input kosong (exit 2)
if [ $# -eq 0 ] || [ -z "$1" ]; then
    echo "DITOLAK: Pekerjaan tidak boleh kosong." >&2
    echo "$(date +%T) DITOLAK (Kosong) Exit=2" >> "$LOG"
    exit 2
fi

INPUT_JOB="$*"

# 2. Validasi keamanan / command injection (exit 3)
if [[ "$INPUT_JOB" =~ (\;|\&\&|\|\||\||\`|\$\(|\>|\<) ]]; then
    echo "DITOLAK: Terdeteksi karakter berbahaya (indikasi command injection) pada '$INPUT_JOB'." >&2
    echo "$(date +%T) DITOLAK (Injeksi: $INPUT_JOB) Exit=3" >> "$LOG"
    exit 3
fi

CMD="$1"
PARAM="$2"

# 3. Validasi whitelist (exit 1)
if [ ! -f "$WHITELIST" ] || ! grep -Fxq "$CMD" "$WHITELIST"; then
    echo "DITOLAK: Perintah '$CMD' tidak terdaftar dalam whitelist." >&2
    echo "$(date +%T) DITOLAK (Non-Whitelist: $INPUT_JOB) Exit=1" >> "$LOG"
    exit 1
fi

# 4. Validasi parameter spesifik perintah (exit 2)
if [ "$CMD" = "sleep" ]; then
    if [ -z "$PARAM" ] || ! [[ "$PARAM" =~ ^[0-9]+$ ]] || [ $# -gt 2 ]; then
        echo "DITOLAK: Parameter untuk 'sleep' harus berupa angka detik yang valid (contoh: sleep 2)." >&2
        echo "$(date +%T) DITOLAK (Parameter Salah: $INPUT_JOB) Exit=2" >> "$LOG"
        exit 2
    fi
elif [ "$CMD" = "echo" ]; then
    if [ -z "$PARAM" ]; then
        echo "DITOLAK: Parameter teks untuk 'echo' tidak boleh kosong." >&2
        echo "$(date +%T) DITOLAK (Parameter Kosong: $INPUT_JOB) Exit=2" >> "$LOG"
        exit 2
    fi
fi

# 5. Skenario Positif: Masukkan pekerjaan ke antrean (exit 0)
echo "$INPUT_JOB" >> "$QUEUE"
echo "DITERIMA: Pekerjaan '$INPUT_JOB' berhasil masuk ke antrean ($QUEUE)."
echo "$(date +%T) DITERIMA ($INPUT_JOB) Exit=0" >> "$LOG"
exit 0
