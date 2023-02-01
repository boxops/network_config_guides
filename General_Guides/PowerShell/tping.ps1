# Timestamped Ping with Powershell
# Usage
# .\tping 1.1.1.1

Ping.exe -t $args[0] | ForEach {"{0}: {1}" -f (Get-Date -Format "dd/MM/yyyy HH:mm:ss.fff"),$_}
