# ConfiguraÃ§Ãµes
$AWX_URL = "https://ansible.local"
$TOKEN = ""
$Headers = @{
    Authorization = "Bearer $TOKEN"
}

$mode="remediation"

# Filtros
$Params = @{
    "created__gte" = "2025-12-29T00:00:00Z"
    "created__lte" = "2026-01-04T23:59:59Z"
    "status"       = "successful"
    "labels__name__icontains" = "$mode"
    #"launch_type"  = "manual"
    "page_size"= 500
}

# Monta QueryString
$QueryString = ($Params.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"

# ===== Requisição Jobs =====
$jobsEndpoint = "$AWX_URL/api/v2/unified_jobs/?$QueryString"
$jobsResponse = Invoke-RestMethod -Uri $jobsEndpoint -Headers $Headers -Method Get

$jobsResults = $jobsResponse.results | ForEach-Object {
    [PSCustomObject]@{
        ID       = $_.id
        Name     = $_.name
        Type     = "job"
        Status   = $_.status
        Started  = $_.started
        Finished = $_.finished
        Launch_Type = $_.launch_type
        User     = $_.launched_by.name
        Labels   = ($_.summary_fields.labels | ForEach-Object { $_.name }) -join ","
    }
}

# Exporta para CSV
$jobsResults | Export-Csv -Path "awx_jobs_report_$mode.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Relatório gerado: awx_jobs_report_$mode.csv"

