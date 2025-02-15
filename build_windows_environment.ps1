# Variable definitions
$VisualStudioVersion = "2022"
$VisualStudioType = "Community"
$MSVCVariant = "MSVC"
$MSVCVersion = "14.43.34808"
$WindowsVersion = "10"
$WindowsSDKVersion = "10.0.22621.0"
$FilterExtraLibs = $true  
$FilterPDB = $true  
$RemoveTempFolder = $true  

# List of subdirectories to exclude
$excludeDirs = @("onecore", "store", "uwp", "enclave")

# Source paths definition
$msvcPaths = @{
    "atlmfc\include" = "C:\Program Files\Microsoft Visual Studio\$VisualStudioVersion\$VisualStudioType\VC\Tools\$MSVCVariant\$MSVCVersion\atlmfc\include"
    "atlmfc\lib" = "C:\Program Files\Microsoft Visual Studio\$VisualStudioVersion\$VisualStudioType\VC\Tools\$MSVCVariant\$MSVCVersion\atlmfc\lib"
    "include" = "C:\Program Files\Microsoft Visual Studio\$VisualStudioVersion\$VisualStudioType\VC\Tools\$MSVCVariant\$MSVCVersion\include"
    "lib" = "C:\Program Files\Microsoft Visual Studio\$VisualStudioVersion\$VisualStudioType\VC\Tools\$MSVCVariant\$MSVCVersion\lib"
    "diasdk\include" = "C:\Program Files\Microsoft Visual Studio\$VisualStudioVersion\$VisualStudioType\DIA SDK\include"
    "diasdk\lib" = "C:\Program Files\Microsoft Visual Studio\$VisualStudioVersion\$VisualStudioType\DIA SDK\lib"
}

$winsdkPaths = @{
    "Include\$WindowsSDKVersion" = "C:\Program Files (x86)\Windows Kits\$WindowsVersion\Include\$WindowsSDKVersion"
    "Lib\$WindowsSDKVersion" = "C:\Program Files (x86)\Windows Kits\$WindowsVersion\Lib\$WindowsSDKVersion"
}

# Destination folder definition
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$destination = "$scriptRoot\cross_compile_package"
$msvcTarFile = "$scriptRoot\msvc$VisualStudioVersion`_$MSVCVersion.tgz"
$winsdkTarFile = "$scriptRoot\winsdk_$WindowsSDKVersion.tgz"

Write-Host "Initializing script..."
Write-Host "Destination folder: $destination"

# Clean up the previous folder if it exists
if (Test-Path $destination) {
	Write-Host "Removing existing destination folder..."
    Remove-Item -Recurse -Force $destination
}
New-Item -ItemType Directory -Path $destination | Out-Null

# Function to copy files while preserving directory structure and applying exclusions
function Copy-Files {
    param (
        [string]$source,
        [string]$relativePath,
        [string]$destinationRoot
    )

    if (Test-Path $source) {
        $targetPath = Join-Path $destinationRoot $relativePath
        New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        
		Write-Host "Copying: $relativePath"
		
        # Exclusions for file types
        $excludePatterns = @()
        if ($FilterPDB) { $excludePatterns += "*.pdb" }

        # Copy all files first, applying file exclusions only
        Copy-Item -Path $source\* -Destination $targetPath -Recurse -Exclude $excludePatterns -Force

        # Remove excluded directories after copying
        if ($FilterExtraLibs) {
            Get-ChildItem -Path $targetPath -Directory -Recurse | Where-Object { $_.Name -in $excludeDirs } | ForEach-Object { 
				Write-Host "Excluding folder: $($_.FullName)"
                Remove-Item -Recurse -Force $_.FullName
            }
        }
    } else {
        Write-Host "Skipping: $relativePath (Path not found)"
    }
}

# Copy MSVC files while preserving the directory structure
Write-Host "Copying MSVC files..."
foreach ($relativePath in $msvcPaths.Keys) {
    Copy-Files -source $msvcPaths[$relativePath] -relativePath $relativePath -destinationRoot "$destination\msvc"
}

# Copy WinSDK files while preserving the directory structure
Write-Host "Copying Windows SDK files..."
foreach ($relativePath in $winsdkPaths.Keys) {
    Copy-Files -source $winsdkPaths[$relativePath] -relativePath $relativePath -destinationRoot "$destination\winsdk"
}

# Create TAR archives using tar.exe
function Compress-Tar {
    param (
        [string]$sourcePath,
        [string]$outputFile
    )

    if (Test-Path $outputFile) {
		Write-Host "Removing existing archive: $outputFile"
        Remove-Item -Force $outputFile
    }

	Write-Host "Creating archive: $outputFile"
	$tarArgs = @("-czf", $outputFile, "-C", $sourcePath, "*")
    & tar.exe @tarArgs
}

# Compress MSVC and WinSDK directories
Write-Host "Compressing MSVC package..."
Compress-Tar -sourcePath "$destination\msvc" -outputFile $msvcTarFile

Write-Host "Compressing Windows SDK package..."
Compress-Tar -sourcePath "$destination\winsdk" -outputFile $winsdkTarFile

# Remove the temporary folder if the option is enabled
if ($RemoveTempFolder -and (Test-Path $destination)) {
	Write-Host "Removing temporary folder..."
    Remove-Item -Recurse -Force $destination
}

Write-Host "The packages have been generated:"
Write-Host "MSVC: $msvcTarFile"
Write-Host "WinSDK: $winsdkTarFile"