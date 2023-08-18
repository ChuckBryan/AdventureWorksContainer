param (
    [Parameter(Mandatory=$true)]
    [string]$dockerHubUsername,

    [Parameter(Mandatory=$true)]
    [string]$version
)

# Define the URL and output path
$url = "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksLT2017.bak"
$outputPath = "AdventureWorksLT2017.bak"

# Download the .bak file
Invoke-WebRequest -Uri $url -OutFile $outputPath

Write-Host "Download completed. File saved to $outputPath"

# Define Docker image details
$imageName = "adventureworkslt2017"

# Build the Docker image
docker build -t "${dockerHubUsername}/${imageName}:${version}" -t "${dockerHubUsername}/${imageName}:latest" .

# Push both tags to Docker Hub
docker push "${dockerHubUsername}/${imageName}:${version}"
docker push "${dockerHubUsername}/${imageName}:latest"

Write-Host "Docker images pushed to Docker Hub"

# Delete the .bak file
Remove-Item -Path $outputPath -Force

Write-Host "$outputPath deleted successfully"
