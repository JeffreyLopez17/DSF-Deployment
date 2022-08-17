param(
	[Parameter()]
	[string]$basePath,
	
	[Parameter()]
	[string]$dsfHostString,
	
	[Parameter()]
	[string]$action
	
)

$currentPath = Get-Location 

cls
Write-Host "=============================="
Write-Host "=== DSF Package Deployment ==="
Write-Host "=============================="

# Check if *basePath* argument was used
if ($basePath -eq "") {
	$path = ".\"
} else {
	$path = $basePath
}

if (!(Test-Path -Path $path)) {
	Write-Host "ERROR - Path $path not available"
	return
}
Set-Location $path

# Check if *defHostString* argument was used
if ($dsfHostString -eq "") {
	$hostString = "localhost:9089"
} else {
	$hostString = $dsfHostString
}

# Check if *action* argument was used
if ($action -eq "") {
	$action = "deploy"
} 

# Obtain the list of DSF packages
$fileList = Get-ChildItem -Path .\*.zip
$dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$fileCount = $fileList.Count
Write-Host "Files found: $fileCount"

if ($fileCount -gt 0) {
	# Check if Processed folder exists
	$processedRoot = "Processed"
	if (!(Test-Path -Path $processedRoot)) {
		New-Item -Name "Processed" -Type Directory
	} 

	# Create Directory for current execution
	$newFolder = $processedRoot + "\" + $dateTime
	New-Item -Name $newFolder -Type Directory

	$url = "http://" + $hostString + "/dsf-iris/api/v1.0.0/meta/dsfpackages/" + $action + "?retry=false"
	
	# Deploy each package
	foreach ($file in $fileList) {
		$filename = $file.Name
		Write-Host "Deploying package $filename"
		curl -X POST -L -F "package=@$filename;type=application/zip" $url
		$movedFilename = $newFolder + "\" + $filename
		Move-Item $file -Destination $movedFilename
	}
	Set-Location $currentPath	
} else {
	Write-Host "No packages found!"
}