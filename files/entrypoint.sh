#!/bin/bash

/usr/bin/duplicati-server --log-file=/backup/duplicati.log --log-level=info --webservice-port=8200 --webservice-interface=any &
pid1=$!

sleep 1 && tail -f /backup/duplicati.log &
pid2=$!

wait $pid1 && exit 1

# Run logrotate in a background loop
while true; do
    logrotate /etc/logrotate.d/duplicati
    sleep 1d
done &

/usr/bin/duplicati-server --log-file=/backup/duplicati.log --log-level=info --webservice-port=8200 --webservice-interface=any &
duplicati_pid=$!

# Tail log file in background
sleep 1 && tail -F /backup/duplicati.log &
tail_pid=$!

# Wait for Duplicati process to exit
wait $duplicati_pid
duplicati_exit_code=$?
kill $tail_pid
exit $duplicati_exit_code
