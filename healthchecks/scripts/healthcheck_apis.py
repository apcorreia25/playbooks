import requests
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor
import json
import urllib3
import sys
import os

# Desativa os avisos de certificado inseguro
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Recebe URLs informadas no arquivo urls.txt
with open(sys.argv[1], 'r') as f:
    urls = [linha.strip() for linha in f if linha.strip()]

# Endpoint da API de logs do Dynatrace e token
dynatrace_log_api = "https://nev24035.live.dynatrace.com/api/v2/logs/ingest"
dynatrace_token = sys.argv[2]

# Cabeçalhos para autenticação
headers = {
    "Authorization": f"Api-Token {dynatrace_token}",
    "Content-Type": "application/json"
}

# Função para verificar URL e gerar log
def verificar_url(url):
    try:
        response = requests.get(url, verify=False, timeout=5)
        status_code = response.status_code
    except requests.exceptions.RequestException as e:
        status_code = "no_response"

    timestamp = datetime.now(timezone.utc).isoformat()
    return {
        "content": f"Healthcheck result {url}",
        "url": url,
        "status_code": str(status_code),
        "timestamp": timestamp,
        "severity": "info"
    }

# Executa em paralelo
with ThreadPoolExecutor(max_workers=5) as executor:
    log_entries = list(executor.map(verificar_url, urls))

# Envio para Dynatrace
try:
    post_response = requests.post(
        dynatrace_log_api,
        headers=headers,
        verify=False,
        data=json.dumps(log_entries)
    )
    print(f"POST para Dynatrace OK, status_code: {post_response.status_code}")
except requests.RequestException as e:
    print(f"Falha ao enviar logs para Dynatrace: {e}")
