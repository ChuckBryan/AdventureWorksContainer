$url = "https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksLT2017.bak"
$outputPath = "AdventureWorksLT2017.bak"

Invoke-WebRequest -Uri $url -OutFile $outputPath

Write-Host "Download completed. File saved to $outputPath"
