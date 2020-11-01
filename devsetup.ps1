If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}
Set-Location $PSScriptRoot

"Setting up user_local_config.hpp..."
if (-not (Test-Path "src\config\user_local_config.hpp")) {
    "   Copied file"
    Copy-Item "src\config\user_local_config.hpp.template" -Destination "src\config\user_local_config.hpp"
} else {
    "   File already exists, file not copied"
}

"`nSetting up symlinks for src folder..."
$missionFolders = Get-Childitem -directory -name "Vindicta*.*"
forEach ($missionFolder in $missionFolders) {
    "   Found mission folder: $missionFolder"
    if (-not (Test-Path "$missionFolder\src")) {
        New-Item -ItemType SymbolicLink -name "$missionFolder\src" -value "src" > $null
        "       Created symbolic link $missionFolder\src -> src"
    }

    "  Copying common files..."
    $filesToCopy = "cba_settings.sqf", "description.ext", "init.sqf", "onPlayerRespawn.sqf", "stringtable.xml"
    forEach ($fileName in $filesToCopy) {
        Copy-Item "configs\$fileName" $missionFolder -Force
    }

    Copy-Item "configs\pboVariant_standalone.hpp" "$missionFolder\pboVariant.hpp" -Force
}

pause