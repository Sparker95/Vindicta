$missionFolders = Get-Childitem -directory -name "Vindicta.*"
forEach ($missionFolder in $missionFolders) {
    "Found mission folder: $missionFolder"
    Copy-Item "configs\stringtable.xml" $missionFolder
    "  updated stringtable.xml`n"
}

"`n`nDone!"

pause