## Script to backup the current Mi8 auto start script and replace with our custom one from the current repo
$ErrorActionPreference = "Stop" # this is a debug setting, will stop on any error so that we can figure out what went wrong
#$macroSequenciesRelPath = "Mods\aircraft\{0}\Cockpit\Scripts\Macro_sequencies.lua"
#$Mi8MTV2 = "Mi-8MTV2"

Write-Host "`n** Custom DCS deployment script **`n"
function Get-Folder()
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "DCS Saved Games Location (not install directory)"
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

function Get-DCSSavedGamesPath {
  # Check that we know where the ED install location is:
  ##$savedGamesPath = $env:DCS_INSTALL_PATH # the environment variables don't seem to persist, so let's use the registry instead
  $path = "$env:USERPROFILE\Saved Games\DCS.openbeta"
  if (!(Test-Path -Path $path)) {
    # for some reason, even though he's on the beta, Zebra's path is different, might have to handle more weird cases?
    # Hopefully the folder selection dialog should help here
    $path = "$env:USERPROFILE\Saved Games\DCS"
  }
  
  if(!(Test-Path -Path $path)) {
    Write-Host "Where is your Saved Games path?"
    $path = Get-Folder
    Write-Host "If this keeps happening, please reach out to FlamerNZ..."
  }
  return $path
}
function DownloadLatest {
  Write-Host "Removing old Liveries files..."
  if (Test-Path -Path "CustomDCS-Liveries.zip") {
    # Remove old zip
    Remove-Item "CustomDCS-Liveries.zip"
  }

  if (Test-Path -Path "CustomDCS-Liveries") {
    # Remove old Folder
    Remove-Item "CustomDCS-Liveries" -Recurse -Force
  }

  Write-Host "Beginning BITS transfer of Liveries..."
  Write-Host "This will take a min (3.9GB)"
  Write-Host "Go do some flying or make a coffee or sumin"
  Start-Sleep -Seconds 3
  #$download = "http://customdcs.ddns.net:10205/CustomDCS-Liveries.zip"
  $download = "https://customdcs.com/Liveries.zip"
  Start-BitsTransfer -Source $download -Destination .\CustomDCS-Liveries.zip
  Write-Host "Background Transfer Complete!"
}

$savedGamesPath = Get-DCSSavedGamesPath
Write-Host "Current DCS saved games path: " $savedGamesPath

Write-Host "Checking that we can find your saved games folder..." -NoNewline
if(!(Test-Path $savedGamesPath))
{
  Write-Error -Message "Folder doesn't seem to be at this path: $savedGamesPath" -ErrorAction Continue
  $response = Read-Host -Prompt "Would you like to select your DCS saved games folder manually? (Y/N)"
  if($response.ToUpper() -eq "Y")
  {
    $savedGamesPath = Get-DCSSavedGamesPath
  } else {
    Write-Host "Installer Exiting"
    exit 1
  }
}
else {
  Write-Host "success!"
  
}

DownloadLatest
Write-Host "=== How to use these Liveries =="
Write-Host "Drop the contents of the DCS Folder inside your DCS install directory"
Write-Host "Drop the contents of the Saved Games[DCS] Folder inside your Saved Games directory"
Write-Host "Yushin's Optional Stuff to be explained in future updates - maybe"
#Write-Host "Expand-Archive -Path .\CustomDCS-Liveries.zip -Destination $savedGamesPath"
#Expand-Archive -Path .\CustomDCS-Liveries.zip -Destination $savedGamesPath
#Write-Host "All done!"
Read-Host "all done?"

# get list of airframes
#$airframePath = "CustomDCS-Liveries"
# if (!(Test-Path $airframePath)) {
#   $airframePath = "CustomDCS-Liveries"
# }

#Copy-Item $airframePath -Destination $savedGamesPath -

#$airframes = (Get-ChildItem -Path $airframePath -Directory).Name
#$airframes = @("Mi-8MTV2")
#Write-Host $airframes
#AutoStartSelection -airframes $airframes #, $savedGamesPath
