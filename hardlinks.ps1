# Configuration:
$OFS = ', '

function ReadHostTillValidValue {
    param (
        [string]$text,
        [string]$inputType,
        [scriptblock]$extraWriteHosts
    )

    $result = ""
    $valid = $false

    while (!$valid) {
        if ($extraWriteHosts) {
            $extraWriteHosts.Invoke()
        }
        $result = Read-Host $text

        if ($inputType -eq "path") {
            if (Test-Path $result) {
                $valid = $true
            }
            else {
                Write-Host $result -NoNewline -ForegroundColor Magenta
                Write-Host " does not exist or is no directory!" -ForegroundColor Red
            }
        }
        elseif ($inputType -eq "boolean") {
            $valid = $true

            if (@("y", "yes", "1") -contains $result) {
                return $true
            }
            elseif (@("n", "no", "0") -contains $result) {
                return $false
            }
            else {
                $valid = $false
            }
        }
        else {
            Write-Error "InputType not valid"
        }
    }

    return $result
}

Clear-Variable -Name minecraftInstancePath, symlinkTargetsPath, ignorePowershellDirectory, createCopyOfDirectorys, deleteOldDirectorys, directoryNameBlacklist -ErrorAction Ignore

$minecraftInstancePath = ReadHostTillValidValue -text "Please paste minecraft instance directory here" -inputType path
$symlinkTargetsPath = ReadHostTillValidValue -text "Please paste the directory containing the symlink target directorys" -inputType path
$ignorePowershellDirectory = ReadHostTillValidValue -text "Should the powershell directory be ignored? (y/n)" -inputType boolean
$createCopyOfDirectorys = ReadHostTillValidValue -text "Create copys of old Directorys? (y/n)" -inputType boolean
$deleteOldDirectorys = ReadHostTillValidValue -text "Automatically delete the old directorys? (Otherwise you have to delete them yourself.) (y/n)" -inputType boolean

$confirm = ReadHostTillValidValue -text "(y/n)" -inputType boolean -extraWriteHosts { 
    Write-Host "--------------------------------------------------"
    Write-Host "Please confirm your configuration: "
    Write-Host "Minecraft instance directory: " -NoNewline
    Write-Host $minecraftInstancePath -ForegroundColor Cyan
    Write-Host "Symlink targets directory: " -NoNewline
    Write-Host $symlinkTargetsPath -ForegroundColor Cyan
    Write-Host "Ignore powershell directory: " -NoNewline
    Write-Host $ignorePowershellDirectory -ForegroundColor Cyan
    Write-Host "Create directory copy: " -NoNewline
    Write-Host $createCopyOfDirectorys -ForegroundColor Cyan
    Write-Host "Automatically delete old directorys: " -NoNewline
    Write-Host $deleteOldDirectorys -ForegroundColor Cyan
}

if (!$confirm) {
    Write-Host "Please restart the script and enter the correct values"

    Pause
    return
}

#Directorynames:
$directoryNameBlacklist += Get-ChildItem -Path $minecraftInstancePath -Directory  | Where-Object LinkType -ne $null | ForEach-Object { "$($_.Name)" }

if ($ignorePowershellDirectory) {
    $splitDirectoryPath = $PSScriptRoot.Split("\")
    $currentDirectoryName = $splitDirectoryPath[$splitDirectoryPath.Length - 1]

    $directoryNameBlacklist += $currentDirectoryName
}

$symlinkTargetNames = Get-ChildItem -Path $symlinkTargetsPath -Directory | Where-Object { $directoryNameBlacklist -notcontains $_ }

if (!$symlinkTargetNames) {
    Write-Host "No symlinks to create!"
    Pause
    return
}

#Check for user approval
$continue = ReadHostTillValidValue -text "? (y/n)" -inputType boolean -extraWriteHosts {
    Write-Host  "Do you want to create these symlinks: " -NoNewline
    Write-Host $symlinkTargetNames -Separator ", " -ForegroundColor Magenta -NoNewline
    Write-Host " at " -NoNewline
    Write-Host $minecraftInstancePath -ForegroundColor Blue -NoNewline
}

if (!$continue) {
    Write-Host "No symlinks created"

    CustomReturn
    return
}

#Create copys
$missingFiles = @()

if ($createCopyOfDirectorys) {
    $symlinkTargetNames | ForEach-Object {
        $directoryPath = "$($minecraftInstancePath)\$($_)"

        if (!(Test-Path $directoryPath)) {
            $missingFiles += $_

            return
        }

        [Void]$(New-Item "$($directoryPath)_OLD" -Type Directory -Force)

        Write-Host "Creating copy of directory: $($_)"

        $creationTime = Measure-Command { Copy-Item -Recurse -Force -Path "$($directoryPath)\*" -Destination "$($directoryPath)_OLD" }

        Write-Host "Creation completed in: " -NoNewline
        Write-Host $creationTime -ForegroundColor Yellow
    }
}


if ($missingFiles.Length -gt 0) {
    Write-Host "Directorys " -NoNewline
    Write-Host "$missingFiles" -NoNewline -ForegroundColor Magenta
    Write-Host " can not be copied because they don't exist"
}

#Confirm with user to delete directorys without copy creation
if ($deleteOldDirectorys -and !$createCopyOfDirectorys) {
    $deleteOldDirectorys = ReadHostTillValidValue -text "No copys where created. Are you sure you want to delete the old directorys and lose all the content? (y/n)" -inputType boolean
}

Clear-Variable -Name missingFiles
$missingFiles = @()

#Delete old directorys
if ($deleteOldDirectorys) {
    $symlinkTargetNames | ForEach-Object {
        $directoryPath = "$($minecraftInstancePath)\$($_)"

        if (!(Test-Path $directoryPath)) {       
            $missingFiles += $_

            return
        }

        Write-Host "Deleting directory: " -NoNewline
        Write-Host $_ -ForegroundColor Magenta

        $creationTime = Measure-Command { Remove-Item -Path $directoryPath -Recurse }

        Write-Host "Deletion completed in: " -NoNewline
        Write-Host $creationTime -ForegroundColor Yellow
    }    
}

if ($missingFiles.Length -gt 0) {
    Write-Host "Directorys " -NoNewline
    Write-Host "$missingFiles" -NoNewline -ForegroundColor Magenta
    Write-Host " can not be deleted because they don't exist"
}

#Create symlinks
$symlinkTargetNames | ForEach-Object {
    $directoryPathWithName = "$($minecraftInstancePath)\$($_)"
    $symlinkTargetsPathWithName = "$($symlinkTargetsPath)\$($_)"

    if (Test-Path $directoryPathWithName) {
        Write-Host "Error! Could not create symlink " -NoNewline -ForegroundColor Red
        Write-Host $_ -NoNewline -ForegroundColor Magenta
        Write-Host " because there is a directory/file with the same name" -ForegroundColor Red
        Write-Host "Please delete it yourself or re-run the script with active file-deletion!" -ForegroundColor Red
    
        return
    }

    Write-Host "Create symlink: " -NoNewline
    Write-Host $_ -ForegroundColor Magenta

    [Void]$(cmd /c mklink /J $directoryPathWithName $symlinkTargetsPathWithName)
}    

CustomReturn