 #!/bin/bash

cd /opt/duplicati
# check if env var DUPLICATI__IMPORT_CONFIG is a directory and there are .json files there
if [ -d "$DUPLICATI__IMPORT_CONFIG" ]; then
    echo "Importing configs from $DUPLICATI__IMPORT_CONFIG"
    
    # Check if there are any .json files
    shopt -s nullglob
    json_files=("$DUPLICATI__IMPORT_CONFIG"/*.json)
    shopt -u nullglob
    
    if [ ${#json_files[@]} -eq 0 ]; then
        echo "No .json files found in $DUPLICATI__IMPORT_CONFIG"
    else
        for file in "${json_files[@]}"; do
            echo "Checking $file"
            if [ -f "$file" ]; then
                echo "Importing config from $file"
                mono-sgen Duplicati.CommandLine.ConfigurationImporter.exe "$file" --import-metadata=true --server-datafolder=/data/Duplicati
                if [ $? -eq 0 ]; then
                    echo "Imported config from $file"
                    mv "$file" "$file.imported"
                else
                    echo "Failed to import config from $file"
                fi
            fi
        done
    fi
else
    echo "Nothing to import"
    echo ">>> DUPLICATI__IMPORT_CONFIG is not a directory or there are no .json files in it."
fi

# Run logrotate in a background loop
while true; do
    logrotate /etc/logrotate.d/duplicati
    sleep 1d
done &

# parse env vars
[ -n "${DUPLICATI__WEBSERVICE_PASSWORD}" ] && WEBSERVICE_PASSWORD="--webservice-password=${DUPLICATI__WEBSERVICE_PASSWORD}"
[ "${DUPLICATI__UNENCRYPTED_DATABASE,,}" == "true" ] && UNENCRYPTED_DATABASE="--unencrypted-database"
[ -z "${DUPLICATI__DEBUG_LEVEL}" ] && DUPLICATI__DEBUG_LEVEL="Information"
ARGS="${UNENCRYPTED_DATABASE} ${WEBSERVICE_PASSWORD} --webservice-interface=any --webservice-port=8200 --log-file=/backup/duplicati.log --log-level=${DUPLICATI__DEBUG_LEVEL} --log-retention=1M"

# Start Duplicati
/usr/bin/duplicati-server ${ARGS} &
duplicati_pid=$!

# Tail log file in background
sleep 1 && tail -F /backup/duplicati.log &
tail_pid=$!

# Wait for Duplicati process to exit
wait $duplicati_pid
duplicati_exit_code=$?
kill $tail_pid
exit $duplicati_exit_code
