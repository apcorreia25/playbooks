import requests
from datetime import datetime, timezone
import json
import urllib3

# Desativa os avisos de certificado inseguro
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Lista de URLs a verificar
urls = [
    "https://www.google.com.br"
]

# Endpoint da API de logs do Dynatrace e token
dynatrace_log_api="https://nev24035.live.dynatrace.com/api/v2/logs/ingest"
dynatrace_token=""


# Cabeçalhos para autenticação
headers = {
    "Authorization": f"Api-Token {dynatrace_token}",
    "Content-Type": "application/json"
}

# Coleta dos dados
log_entries = []

for url in urls:
    try:
        response = requests.get(url, verify=False, timeout=10)
        status_code = response.status_code
    except requests.RequestException:
        status_code = "error"

    timestamp = timestamp = datetime.now(timezone.utc).isoformat()
    log_entries.append({
        "content": f"Healthcheck result {url}",
        "url": url,
        "status_code": f"{status_code}",
        "timestamp": timestamp,
        "severity": "info"
    })

print(json.dumps(log_entries))
# Envio para Dynatrace
try:
    post_response = requests.post(dynatrace_log_api, headers=headers, verify=False, data=json.dumps(log_entries))
    print(f"POST para Dynatrace retornou: {post_response.status_code}")
except requests.RequestException as e:
    print(f"Falha ao enviar logs para Dynatrace: {e}")
                                                              
