param (
    [string]$verPatch = "666"
)

Push-Location

Set-Location "$PSScriptRoot\..\..\"

"Read the config.json file..."
$configString = get-content -path (Join-path -path $PSScriptRoot -childPath "config.json")
$config = ConvertFrom-Json -InputObject ($configString -as [String])
$combinedFolderName = "$($config.simpleName)_missions".toLower()
$combinedMissionsLocation = "_build\missions\$combinedFolderName"

"`nSetup temporary directories..."
New-Item -Path "_build" -ItemType Directory -Force > $null
if (Test-Path "_build\missions") {
    # It's impossible to delete a symlink due to some PowerShell bug
    # So they are deletes with a workaround
    <#
    (Get-Childitem "_build\missions" -Directory) | ForEach-Object {
        #"Checking subfolder:"
        $_.fullName
        $srcPath = Join-Path -Path $_.fullName -ChildPath "src"
        if (Test-Path $srcPath) {
            #"Deleting src symlink"
            (Get-Item -Path $srcPath).Delete()
        }
    }
    #>
    Remove-Item -Path "_build\missions" -Recurse -Force
}
New-Item -Path "_build\missions" -ItemType Directory -Force > $null
New-Item -Path "_build\missions\separatePBO" -ItemType Directory -Force > $null
New-Item -Path "_build\missions\$combinedFolderName" -ItemType Directory -Force > $null

"`nRead version..."
$verMajor = Get-Content -path "configs\majorVersion.hpp"
$verMinor = Get-Content -path "configs\minorVersion.hpp"
if ($verMajor.Count -gt 1) {
    "ERROR: majorVersion.hpp contains a new line"
    exit 100
}
if ($verMinor.Count -gt 1) {
    "ERROR: minirVersion.hpp countains a new line"
    exit 100
}
# VerPatch is wrapped in quotes because we can put a string into buildVersion, although typically it is a number
"`"$verPatch`"" | Out-File -FilePath "_build\missions\buildVersion.hpp" -NoNewline -Encoding UTF8

# Generate common strings
$verFullDots = "$verMajor.$verMinor.$verPatch"
$verFullUnderscores = "$verMajor_$verMinor_$verPatch"
"Mission Version: $verFullDots"
$briefingName = "$($config.displayName) $verMajor.$verMinor.$verPatch"

"`nCheck all mission folders..."
$missionFolders = Get-Childitem -directory -name ($config.missionFolderWildcard -as [String])
$mapNames = @()
forEach ($missionFolder in $missionFolders) {
    "Found mission folder: $missionFolder"
    #Ensure that .sqm file exists here
    if (-not (Test-Path (Join-Path -path $missionFolder -childPath "mission.sqm"))) {
        "ERROR: mission.sqm was not found in $missionFolder"
        exit 200
    }
    $mapNames += $missionFolder.Split(".")[-1]
}

"`nBuild individual mission PBOs..."
for (($i = 0); ($i -lt $mapNames.count); ($i++) ) {
    $mapName = $mapNames[$i]
    $missionFolder = $missionFolders[$i]
    $oneMissionFolderName = "$($config.simpleName)_$mapName.$mapName".toLower()
    $oneMissionPboName = ($config.oneMissionPboName -f $verMajor, $verMinor, $verPatch, $mapName).toLower()
    $tempMissionLocation = "$combinedMissionsLocation\$oneMissionFolderName"
    New-Item -path $tempMissionLocation -ItemType Directory > $null

    "Building $oneMissionPboName"

    # Copy files
    "Copying files..."
    $sw = [system.diagnostics.stopwatch]::startNew()
    Copy-Item "src" -Destination $tempMissionLocation -Recurse
    # It was a bad idea to make symlink instead of copying folder, because then we paste config files to src/config
    #New-Item -ItemType SymbolicLink -name "$tempMissionLocation\src" -value "src" > $null
    Copy-Item "_build\missions\buildVersion.hpp" -Destination "$tempMissionLocation\src\config"
    Copy-Item "$missionFolder\mission.sqm" -Destination $tempMissionLocation
    forEach ($pathPair in $config.copyFiles) {
        $pathDest = Join-Path -Path $tempMissionLocation -ChildPath $pathPair.to
        Copy-Item $pathPair.from -Destination $pathDest -Recurse
    }
    "`tDone in $($sw.ElapsedMilliseconds)ms"

    # Build PBO
    $sw.restart()
    "Building PBO with armake..."
    .$PSScriptRoot\hemtt armake build --force -i include $tempMissionLocation "_build\missions\separatePBO\$oneMissionPboName" -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
    "`tDone in $($sw.ElapsedMilliseconds)ms"
}


# GENERATE CONFIG.CPP

"`nGenerate config.cpp"
$sCfgPatches = ""
$sClassMissions = ""
$sClassMPMissions = ""

$sCfgPatches += "class CfgPatches {`n";
$sCfgPatches += " class $($config.cfgPatchesClassName) {`n";
$sCfgPatches += "  name = ""$($config.displayName) Missions"";`n";
$sCfgPatches += "  units[] = {};`n";
$sCfgPatches += "  weapons[] = {};`n";
$sCfgPatches += "  requiredVersion = 1.56;`n";
$sCfgPatches += "  requiredAddons[] = {""vindicta_main""};`n";
$sCfgPatches += "  author = ""Vindicta Team"";`n";
$sCfgPatches += "  authors[] = {""""};`n";
$sCfgPatches += "  versionAr[] = {1,0,0,0};`n";
$sCfgPatches += "  versionStr = ""1.0.0.0"";`n";
$sCfgPatches += " };`n";
$sCfgPatches += "};`n";

$sReadme = "Example class Missions for server.cfg:`n`n"
$sReadme += "class Missions`n{`n"
for (($i = 0); ($i -lt $mapNames.count); ($i++) ) {
    $mapName = $mapNames[$i]
    $missionFolder = $missionFolders[$i]
    $briefingNameMap = "$($config.displayName) $mapName $verMajor.$verMinor.$verPatch"
    $className = "$($config.simpleName)_$mapName".toLower()
    $missionsMissionFolder = "$($config.simpleName)_$mapname.$mapName".toLower()
    $directory = "$combinedFolderName\$className.$mapName".toLower()
    
    $sReadme += "  class $className`n"
    $sReadme += "  {`n"
    $templateValue = "$className.$mapName".toLower()
    $sReadme += "    template = $templateValue;`n"
    $sReadme += "    difficulty = ""veteran"";`n"
    $sReadme += "    class Params {};`n"
    $sReadme += "  };`n"

    $newClass = ""
    $newClass += "  class $className`n";
    $newClass += "  {`n";
    $newClass += "   briefingName = ""$briefingNameMap"";`n";
    $newClass += "   directory = ""$directory"";`n";
    $newClass += "  };`n";

    $sClassMissions += $newClass
    $sClassMPMissions += $newClass
}
$sReadme += "};"
$sReadme | Out-File -FilePath "_build\FOR_DEDICATED_SERVER_CFG.TXT"

$sConfigCPP = ""

$sConfigCPP += $sCfgPatches

$sConfigCPP += "class CfgMissions`n";
$sConfigCPP += "{`n";

$sConfigCPP += " class MPMissions`n";
$sConfigCPP += " {`n";
$sConfigCPP +=   $sClassMPMissions;
$sConfigCPP += " };`n";

$sConfigCPP += " class Missions`n";
$sConfigCPP += " {`n";
$sConfigCPP += "  class $($config.simpleName)";
$sConfigCPP += "  {`n";
$sConfigCPP += "  briefingName = ""$briefingName"";`n";
$sConfigCPP +=    $sClassMissions;
$sConfigCPP += "  };`n";
$sConfigCPP += " };`n";

$sConfigCPP += "};`n";

$sConfigCPP | Out-File -FilePath "$combinedMissionsLocation\config.cpp" -NoNewline -Encoding UTF8

"`nBuild combined missions PBO..."

$sw = [system.diagnostics.stopwatch]::startNew()
.$PSScriptRoot\hemtt armake build --force -i include $combinedMissionsLocation "_build\missions\$combinedFolderName.pbo" -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
"`tDone in $($sw.ElapsedMilliseconds)ms"

Pop-Location