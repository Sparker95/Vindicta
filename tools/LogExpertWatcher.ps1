$logExpert = 'C:\ProgramData\chocolatey\bin\LogExpert.exe'

$watcherClient = New-Object System.IO.FileSystemWatcher
$watcherClient.Path = "$env:localappdata\Arma 3"
$watcherClient.Filter = "arma3*.rpt"
$watcherClient.IncludeSubdirectories = $false
$watcherClient.EnableRaisingEvents = $false

$actionClient = {
    $path = $Event.SourceEventArgs.FullPath
    & $logExpert $path
}
Register-ObjectEvent $watcherClient "Created" -Action $actionClient
