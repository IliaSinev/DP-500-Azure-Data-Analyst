Clear-Host
write-host "Starting script at $(Get-Date)"

$resourceGroupName="Spielwiese_Ilia_Sinev"
$dataLakeAccountName="datalakeqr9jb18"

# Upload files
write-host "Loading data..."
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $dataLakeAccountName
$storageContext = $storageAccount.Context
Get-ChildItem "./data/*.csv" -File | Foreach-Object {
    write-host ""
    $file = $_.Name
    Write-Host $file
    $blobPath = "sales/orders/$file"
    Set-AzStorageBlobContent -File $_.FullName -Container "files02" -Blob $blobPath -Context $storageContext
}

write-host "Script completed at $(Get-Date)"
