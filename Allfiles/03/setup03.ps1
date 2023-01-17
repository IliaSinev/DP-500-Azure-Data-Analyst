Clear-Host
write-host "Starting script at $(Get-Date)"

$resourceGroupName="Spielwiese_Ilia_Sinev"
$synapseWorkspace = "synapseqr9jb18"
$dataLakeAccountName="datalakeqr9jb18"
$sqlDatabaseName = "sqlqr9jb18"
$sqlUser="SQLuser"
$sqlPassword="SC1004i$"


# Create database
write-host "Creating the $sqlDatabaseName database..."
sqlcmd -S "$synapseWorkspace.sql.azuresynapse.net" -U $sqlUser -P $sqlPassword -d $sqlDatabaseName -I -i setup.sql

# Load data
write-host "Loading data..."
Get-ChildItem "./data/*.txt" -File | Foreach-Object {
    write-host ""
    $file = $_.FullName
    Write-Host "$file"
    $table = $_.Name.Replace(".txt","")
    bcp dbo.$table in $file -S "$synapseWorkspace.sql.azuresynapse.net" -U $sqlUser -P $sqlPassword -d $sqlDatabaseName -f $file.Replace("txt", "fmt") -q -k -E -b 5000
}

# Pause SQL Pool
write-host "Pausing the $sqlDatabaseName SQL Pool..."
Suspend-AzSynapseSqlPool -WorkspaceName $synapseWorkspace -Name $sqlDatabaseName -AsJob

# Upload solution script
write-host "Uploading script..."
$solutionScriptPath = "Solution.sql"
Set-AzSynapseSqlScript -WorkspaceName $synapseWorkspace -DefinitionFile $solutionScriptPath -sqlPoolName $sqlDatabaseName -sqlDatabaseName $sqlDatabaseName

write-host "Script completed at $(Get-Date)"
