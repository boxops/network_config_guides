while($true){
Write-Host "Support Team IP Tester" -ForegroundColor Green
Write-Host ""
Write-Host "Make sure that the system allows for running scripts before using." -ForegroundColor Red
Write-Host "If you get a security error when running this you will need to manually alter your powershell run permissions using this command in an admin powershell window before running:" -ForegroundColor Red
Write-Host "Set-ExecutionPolicy RemoteSigned" -ForegroundColor Yellow
Write-Host ""

$ipAddress = Read-Host "Enter IP address you would like to test"
Write-Host ""
$nohop = Read-Host "Number of Tracert Hops"
Write-Host ""
$port = Read-Host "Enter the port number to test"

Write-Host ""
Write-Host "This will take a second to load...." -ForegroundColor Green

$portTest = Test-NetConnection -ComputerName $ipAddress -Port $port -InformationLevel Quiet


$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$outputFolder = Join-Path $scriptPath "IP Test results"
$outputFile = Join-Path $outputFolder "IP Test results.txt"

if (!(Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

"" | Out-File -FilePath $outputFile -Append
"Results" | Out-File -FilePath $outputFile -Append
"------------------------------------------" | Out-File -FilePath $outputFile -Append
ping $ipAddress -n 5 | Out-File -FilePath $outputFile -Append
tracert /h $nohop $ipAddress | Out-File -FilePath $outputFile -Append
"" | Out-File -FilePath $outputFile -Append
if ($portTest -eq "True") {
    "The device at $ipAddress is accessible on port $port."| Out-File -FilePath $outputFile -Append
}
else {
    "The device at $ipAddress is not accessible on port $port." | Out-File -FilePath $outputFile -Append
}
"------------------------------------------" | Out-File -FilePath $outputFile -Append

Write-Host ""
Write-Host "Results saved to: $outputFile"-ForegroundColor Green

Read-Host "Press Enter to test another IP"
}
