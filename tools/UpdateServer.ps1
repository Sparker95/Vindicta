$pbo_output_path = C:\server\mpmissions
while($true) {
    $releases = Invoke-WebRequest "https://api.github.com/repos/Sparker95/Vindicta/releases" | ConvertFrom-Json
    #$releases
    # $releases = Invoke-WebRequest "https://api.github.com/repos/Sparker95/Vindicta/releases"
    $latest_release = $releases.Get(0)
    $latest_release_name = $latest_release.name
    $latest_release_file_sanitized = $latest_release_name.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
    $latest_release_file_name = "Vindicta_$latest_release_file_sanitized.zip"
    if(-Not (Test-Path $latest_release_file_name)) {
        Write-Host "Updating Vindicta to $latest_release_name"
        Invoke-WebRequest $releases.Get(0).zipball_url -OutFile $latest_release_file_name
        $latest_release_dir = $latest_release_file_name + ".dir"
        New-Item -Path $latest_release_dir -ItemType Directory
        "Uncompressing downloaded files..."
        Expand-Archive -Path $latest_release_file_name -OutputPath $latest_release_dir
        "Searching for build script..."
        $build_script = Get-Childitem -Path $latest_release_dir -Include setup_and_build.bat -Recurse
        "Executing build script..."
        Start-Process -FilePath $build_script -Wait
        "Moving all found pbos to target location $pbo_output_path..."
        Get-Childitem -Path $latest_release_dir -Include *.pbo -Recurse | Move-Item -Destination $pbo_output_path
        "Removing temp directory..."
        Remove-Item -Path $latest_release_dir
    }

    Start-Sleep -Seconds 300
}