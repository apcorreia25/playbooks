
# ConfiguraÃ§Ãµes
$AWX_URL = "https://ansible.local"
$TOKEN = "TjPwEWybS7e2hx5GiJ8osEVGmVUlYk"
$Headers = @{
    Authorization = "Bearer $TOKEN"
}

# Filtros
$Params = @{
    "created__gte" = "2025-12-29T00:00:00Z"
    "created__lte" = "2026-01-04T23:59:59Z"
    "status"       = "successful"
    "labels__name__icontains" = "healthcheck"
    "page_size"= 200
}

# Monta URL com parÃ¢metros
$QueryString = ($Params.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
#$Endpoint = "$AWX_URL/api/v2/jobs/?$QueryString"
$Endpoint = "$AWX_URL/api/v2/workflow_jobs/?$QueryString"

# RequisiÃ§Ã£o
$response  = Invoke-RestMethod -Uri $Endpoint -Headers $Headers -Method Get

# Exportar para CSV
$results = $response.results | ForEach-Object {
    [PSCustomObject]@{
        ID       = $_.id
        Name     = $_.name
        Status   = $_.status
        Started  = $_.started
        Finished = $_.finished
        User     = $_.launched_by.name
        Labels   = ($_.summary_fields.labels | ForEach-Object { $_.name }) -join ","
    }
}

$results | Export-Csv -Path "awx_jobs_healthcheck.csv" -NoTypeInformation -Encoding UTF8
Write-Host "RelatÃ³rio gerado: awx_jobs_healthcheck.csv"
