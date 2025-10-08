#!/bin/bash

# Desativa verificação de certificado SSL
export CURL_SSL_NO_VERIFY=1

# Lista de URLs a verificar
URLS=("https://www.google.com.br")

# Endpoint da API de logs do Dynatrace e token
DYNATRACE_LOG_API="https://nev24035.live.dynatrace.com/api/v2/logs/ingest"
DYNATRACE_TOKEN="dt0c01.CCP7LLWRZWENPQMGMKSJC2C5.WOODTVQ7I6JSPLVDIWQBFOPPQLN53EGAVNVQMMZGJCPSUTFEWKCTPIUUUHTX55EH"

# Cabeçalhos
HEADERS=(
  -H "Authorization: Api-Token $DYNATRACE_TOKEN"
  -H "Content-Type: application/json"
)

# Coleta dos dados
LOG_ENTRIES="["

for URL in "${URLS[@]}"; do
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" --insecure --max-time 10 "$URL")
  if [ "$STATUS_CODE" == "000" ]; then
    STATUS_CODE="error"
  fi

  ENTRY=$(cat <<EOF
{
  "content": "Healthcheck result $URL",
  "url": "$URL",
  "status_code": "$STATUS_CODE",
  "timestamp": "$TIMESTAMP",
  "severity": "info"
}
EOF
)
  LOG_ENTRIES+="$ENTRY,"
done

# Remove última vírgula e fecha o array
LOG_ENTRIES="${LOG_ENTRIES%,}]"

# Exibe os logs
echo "$LOG_ENTRIES"

# Envia para Dynatrace
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --insecure "${HEADERS[@]}" -d "$LOG_ENTRIES" "$DYNATRACE_LOG_API")
echo "POST para Dynatrace retornou: $RESPONSE"
