param (
    [string]$verPatch = "666"
)

"Setup temporary directories..."
New-Item -Path "_build" -ItemType Directory -Force > $null
if (Test-Path "_build\missions") {
    Get-Childitem "_build\missions" -Directory forEach-Object {

    } 
    Remove-Item -Path "_build\missions" -Force -Recurse
}
New-Item -Path "_build\missions" -ItemType Directory -Force > $null

"`nRead the config.json file..."
$configString = get-content -path (Join-path -path $PSScriptRoot -childPath "config.json")
$config = ConvertFrom-Json -InputObject ($configString -as [String])

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
$verPatch | Out-File -FilePath "_build\missions\buildVersion.hpp" -NoNewline

# Generate common strings
$verFullDots = "$verMajor.$verMinor.$verPatch"
$verFullUnderscores = "$verMajor_$verMinor_$verPatch"
"Mission Version: $verFullDots"
$briefingName = "$($config.missionDisplayName) $verMajor.$verMinor.$verPatch"
# Must match to common pbo name
$missionsPboPrefix = "$($config.missionTechnicalName)_missions".toLower()

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
    $tempMissionFolderName = $config.oneMissionFolderName -f $verMajor, $verMinor, $verPatch, $mapName
    $tempMissionFolderName = $tempMissionFolderName.toLower()
    "Temp mission folder name: $tempMissionFolderName"
    $tempMissionLocation = "_build\missions\$tempMissionFolderName"
    New-Item -path $tempMissionLocation -ItemType Directory > $null

    # Copy files
    "Copying files..."
    $sw = [system.diagnostics.stopwatch]::startNew()
    #Copy-Item "src" -Destination $tempMissionLocation -Recurse
    New-Item -ItemType SymbolicLink -name "$tempMissionLocation\src" -value "src" > $null
    Copy-Item "_build\missions\buildVersion.hpp" -Destination (Join-Path -Path $tempMissionLocation -ChildPath "src\config")
    Copy-Item (Join-Path -Path $missionFolder -ChildPath "mission.sqm") -Destination $tempMissionLocation
    forEach ($pathPair in $config.copyFiles) {
        $pathDest = Join-Path -Path $tempMissionLocation -ChildPath $pathPair.to
        Copy-Item $pathPair.from -Destination $pathDest -Recurse
    }
    "`tDone in $($sw.ElapsedMilliseconds)ms"

    # Build PBO
    $sw.restart()
    "Launching armake"
    .\tools\Builder\hemtt armake build --force -i include $tempMissionLocation "_build\missions\$tempMissionFolderName.pbo" -w unquoted-string -w redefinition-wo-undef -w excessive-concatenation
    "`tDone in $($sw.ElapsedMilliseconds)ms"
}

"`nGenerate config.cpp"
$sCfgPatches = ""
$sClassMissions = ""
$sClassMPMissions = ""

$sCfgPatches += "class CfgPatches {`n";
$sCfgPatches += " class $($config.cfgPatchesClassName) {`n";
$sCfgPatches += "  name = $($config.missionDisplayName) Missions;`n";
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

"Available server.cfg classes:"
for (($i = 0); ($i -lt $mapNames.count); ($i++) ) {
    $mapName = $mapNames[$i]
    $missionFolder = $missionFolders[$i]
    $briefingNameMap = "$briefingName $mapName"
    $className = "$($config.missionTechnicalName)_$mapName".toLower()
    $missionsMissionFolder = "$($config.missionTechnicalName)_$mapname.$mapName".toLower()
    $directory = "$missionsPboPrefix\$className.$mapName".toLower()
    
    "$className.$mapName".toLower()

    $newClass = ""
    $newClass += "  class $className`n";
    $newClass += "  {`n";
    $newClass += "   briefingName = ""$briefingNameMap"";`n";
    $newClass += "   directory = ""$directory"";`n";
    $newClass += "  };`n";

    $sClassMissions += $newClass
    $sClassMPMissions += $newClass
}

$sConfigCPP = ""

$sConfigCPP += "`n`n";
$sConfigCPP += "class CfgMissions`n";
$sConfigCPP += "{`n";

$sConfigCPP += " class MPMissions`n";
$sConfigCPP += " {`n";
$sConfigCPP +=   $sClassMPMissions;
$sConfigCPP += " };`n";

$sConfigCPP += " class Missions`n";
$sConfigCPP += " {`n";
$sConfigCPP += "  class $($config.missionTechnicalName)";
$sConfigCPP += "  {`n";
$sConfigCPP += "  briefingName = ""$briefingName"";`n";
$sConfigCPP +=    $sClassMissions;
$sConfigCPP += "  };`n";
$sConfigCPP += " };`n";

$sConfigCPP += "};`n";

$sConfigCPP > "_build\missions\config.cpp"

$pause