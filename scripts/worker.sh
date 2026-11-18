#!/bin/bash
QUEUE="data/antrean.txt"
LOCK="/tmp/worker.lock"
LOG="logs/worker.log"
source config/queue.conf

exec 200>"$LOCK"
flock -n 200 || { echo "Worker lain sedang berjalan"; exit 1; }

while [ -s "$QUEUE" ]; do
	JOB=$(head -n 1 "$QUEUE")
	timeout -s TERM -k 2 "${MAX_TIMEOUT}s" bash -c "$JOB" &
        PID=$!
        echo "$(date +%T) BERJALAN $JOB PID=$PID" | tee -a "$LOG"
        wait $PID
        RC=$?
        if [ $RC -eq 0 ]; then
             echo "$(date +%T) BERHASIL $JOB PID=$PID Exit=$RC" | tee -a "$LOG"
        else
            echo "$(date +%T) GAGAL/TIMEOUT $JOB PID=$PID Exit=$RC" | tee -a "$LOG"
        fi
        sed -i '1d' "$QUEUE"
done
exit $RC
