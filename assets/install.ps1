$url = "https://github.com/firefly-zero/firefly-cli/releases/latest/download/firefly_cli-x86_64-pc-windows-msvc.zip"
$archivePath = "c:\temp\firefly.zip"
Invoke-WebRequest -Uri $url -OutFile $archivePath
tar -xf $archivePath -C "c:\temp\"
c:\temp\firefly_cli.exe postinstall
Read-Host -Prompt "Press Enter to exit"
