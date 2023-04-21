## Script to backup the current Mi8 auto start script and replace with our custom one from the current repo
#$ErrorActionPreference = "Stop" # this is a debug setting, will stop on any error so that we can figure out what went wrong
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

function Get-DCSInstallPath {
  # Check that we know where the ED install location is:
  ##$installPath = $env:DCS_INSTALL_PATH # the environment variables don't seem to persist, so let's use the registry instead
  $path = 'shell:games'
  if (!(Test-Path -Path $path)) {
    # for some reason, even though he's on the beta, Zebra's path is different, might have to handle more weird cases?
    # Hopefully the folder selection dialog should help here
    $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DCS World_is1'
  }
  
  if(Test-Path -Path $path)
  {
    $installPath = (Get-ItemProperty -Path $path -Name InstallLocation).InstallLocation
  }
  else {
    Write-Host "Where is your DCS install path?"
    $installPath = Get-Folder
    Write-Host "If this keeps happening, please reach out to FlamerNZ..."
  }
  return $installPath
}

function Get-BackupPath ($path, [int] $i = 0) {
  if(Test-Path $path)
  {
    #increment by 1
    $origPath = $path
    $path = $path + "_" + $i
    if(Test-Path $path)
    {
      $i++
      $path = Get-BackupPath $origPath $i
    }
  }
  return $path
}

function AutoStartSelection ($airframes, $installPath) {
  [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

  # Set the size of your form
  $Form = New-Object System.Windows.Forms.Form
  #$Form.width = 500
  # should expand this depending on how many lines we need, based on number of items in $aircraft list
  #$Form.height = (200 + (50 * ($airframes.Count - 1)))
 
  $Form.width = 295
  $Form.height = 580
  $Form.Text = "CustomDCS.com"
  $form.StartPosition = 'CenterScreen'
  $Form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#f2f2f2")

  # Set up the lables

  $label = New-Object System.Windows.Forms.Label
  $label.Location = '58,20'
  $label.Size = '200,20'
  $label.Text = '- CustomDCS.com -'
  $form.Controls.Add($label)

  $label1 = New-Object System.Windows.Forms.Label
  $label1.Location = '44,37'
  $label1.Size = '200,20'
  $label1.Text = 'Quick Auto Start Installer'
  $form.Controls.Add($label1)

  $label2 = New-Object System.Windows.Forms.Label
  $label2.Location = '40,65'
  $label2.Size = '220,20'
  $label2.Text = 'Please Select One Or More'
  $form.Controls.Add($label2)

  $label3 = New-Object System.Windows.Forms.Label
  $label3.Location = '67,400'
  $label3.Size = '146,17'
  $label3.Text = 'Uninstalling Will Revert'
  $form.Controls.Add($label3)

  $label4 = New-Object System.Windows.Forms.Label
  $label4.Location = '59,416'
  $label4.Size = '170,17'
  $label4.Text = 'To Original ED Auto Start'
  $form.Controls.Add($label4)

  # Set the font of the text to be used within the form

  $Font = New-Object System.Drawing.Font("Arial Black",12)
 
  $LabelFont = New-Object System.Drawing.Font("Arial Black",11)
  $LabelFont1 = New-Object System.Drawing.Font("Arial Black",10)
  $LabelFont2 = New-Object System.Drawing.Font("Arial Black",10)
  $LabelFont3 = New-Object System.Drawing.Font("Arial",10)
  $LabelFont4 = New-Object System.Drawing.Font("Arial",10)

  $Form.Font = $Font
  $Label.font = $LabelFont
  $Label1.font = $LabelFont1
  $Label2.font = $LabelFont2
  $Label3.font = $LabelFont3
  $Label4.font = $LabelFont4
  
  $checkedlistbox = New-Object System.Windows.Forms.CheckedListBox
  $checkedlistbox.Items.Add($checkedlistbox)
  $checkedlistbox.Location = '20,90'
  $checkedlistbox.Size = '235,185'
  $checkedlistbox.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")
  
  $Form.Controls.Add($checkedlistbox)
  
  $checkedListBox.DataSource = [collections.arraylist]$airframes

  $checkedListBox.DisplayMember = 'Name'
  $checkedlistbox.CheckOnClick = $true

  $UnselectallButton = New-Object System.Windows.Forms.Button
  $SelectAllButton = New-Object System.Windows.Forms.Button
  $UninstallButton = New-Object System.Windows.Forms.Button
  $InstallButton = New-Object System.Windows.Forms.Button
  $CancelButton = New-Object System.Windows.Forms.Button
  $ReadMeButton = New-Object System.Windows.Forms.Button

  $SelectAllButton.Text = 'Select All'
  $SelectAllButton.Location = '20,285'
  $SelectAllButton.Size = '115,30'
  $SelectAllButton.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#dedede")
  $SelectAllButton.Add_Click({
    For ($i=0; $i -lt $CheckedListBox.Items.count;$i++) {
      $CheckedListBox.SetItemchecked($i,$True)
    }
  })

  $UnselectAllButton.Text = 'Unselect All'
  $UnselectAllButton.Location = '140,285'
  $UnselectAllButton.Size = '115,30'
  $UnselectAllButton.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#dedede")
  $UnselectAllButton.Add_Click({
    For ($i=0; $i -lt $CheckedListBox.Items.count;$i++) {
      $CheckedListBox.SetItemchecked($i,$false) 
    }
  })

  $InstallButton.Text = 'Install Selected'
  $InstallButton.Location = '20,319'
  $InstallButton.Size = '235,37'
  $InstallButton.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#dedede")
  $InstallButton.Add_Click({
    $macroSequenciesRelPath = "Mods\aircraft\{0}\Cockpit\Scripts\Macro_sequencies.lua"
    # install each selected script
    $i = 0
    foreach($aircraftToInstall in $checkedlistbox.checkeditems) {
      # intstall logic goes here, name of aircraft (path) will be in $aircraftToInstall
      Write-Host $aircraftToInstall
      
      Write-Host "Taking a backup of your current auto start..."
      $installPath = Get-DCSInstallPath
      $relPath = ([string]::Format($macroSequenciesRelPath,$aircraftToInstall)) # $aircraft
      if (!(Test-Path $relPath)) {
        $relPath = "CustomDCS\" + $relPath
      }
      #Write-Host $installPath
      $destPath = ($installPath + $relPath.TrimStart('CustomDCS\'))
      #Write-Host $destPath
      $backupPath = $destPath + "." + (get-date -Format "yy-MM-dd") + ".bak"
      $backupPath = Get-BackupPath $backupPath
      #Write-Host $macroSequenciesPath
      Rename-Item $destPath -NewName $backupPath
      Write-Host "Backup saved to: " $backupPath

      Write-Host "Deploying new auto start..." -NoNewline
      Copy-Item $relPath -Destination $destPath

      Write-Host "success!"
      $i++
    }
    $wsh = New-Object -ComObject Wscript.Shell
    $wsh.Popup([string]::Format("                     CustomDCS.com`n              Auto Start Scripting For
    `n                           {0} Aircraft
    `n      Has Been Deployed Successfully
    `n                  - Happy Hunting -",$i))
  })

  $uninstallButton.Text = 'Uninstall Selected'
  $uninstallButton.Location = '20,360'
  $uninstallButton.Size = '235,37'
  $uninstallButton.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#dedede")
  $uninstallButton.Add_Click({
    # uninstall logic goes here
    $macroSequenciesRelPath = "Mods\aircraft\{0}\Cockpit\Scripts\Macro_sequencies.lua"
    $macroSequenciesOrigRelPath = "Mods\aircraft\{0}\Cockpit\Scripts\Macro_sequencies-orig.lua"
    # install each selected script
    $i = 0
    foreach($aircraftToInstall in $checkedlistbox.checkeditems) {
      # intstall logic goes here, name of aircraft (path) will be in $aircraftToInstall
      Write-Host $aircraftToInstall
      
      $installPath = Get-DCSInstallPath
      $relPath = ([string]::Format($macroSequenciesRelPath,$aircraftToInstall)) # $aircraft
      if (!(Test-Path $relPath)) {
        $relPath = "CustomDCS\" + $relPath
      }

      #Write-Host $installPath
      $destPath = ($installPath + $relPath)

      Remove-Item $destPath

      $origRelPath = ([string]::Format($macroSequenciesOrigRelPath,$aircraftToInstall)) # $aircraft
      #Write-Host $installPath
      if (!(Test-Path $origRelPath)) {
        $origRelPath = "CustomDCS\" + $origRelPath
      }

      Write-Host "Restoring ED auto start..." -NoNewline
      Copy-Item $origRelPath -Destination $destPath

      Write-Host "success!"
      $i++
    }
    $wsh = New-Object -ComObject Wscript.Shell
    $wsh.Popup([string]::Format("                  Custom Auto Start Scripting For
    `n                                      {0} Aircraft
    `n                              Has Been Removed`n           And Restored To ED Original Successfully
    `n                               - Happy Hunting -",$i))
  })

  $ReadMeButton.Text = 'View Readme'
  $ReadMeButton.Location = '20,435'
  $ReadMeButton.Size = '235,35'
  $ReadMeButton.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#dedede")

  $ReadMeButton.Add_Click({
    Invoke-Expression G:\Dev\DCS-LUAs-VoiceAttack\Deploy\ReadMe.txt
  })
  $CancelButton.Text = 'Close'
  $CancelButton.Location = '20,476'
  $CancelButton.Size = '235,45'
  $CancelButton.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#dedede")

  $ButtonFont = New-Object System.Drawing.Font("Arial",11)
  $ButtonFont1 = New-Object System.Drawing.Font("Arial",11)

  $InstallButton.Font = $ButtonFont1
  $CancelButton.Font = $ButtonFont
  $UninstallButton.font = $ButtonFont
  $SelectAllButton.Font = $ButtonFont
  $UnselectAllButton.Font = $ButtonFont
  $ReadMeButton.Font = $ButtonFont

  $Form.CancelButton = $CancelButton
  $Form.Controls.Add($UnselectAllButton)
  $Form.Controls.Add($SelectAllButton)
  $Form.Controls.Add($UninstallButton)
  $Form.Controls.Add($InstallButton)
  $Form.Controls.Add($CancelButton)
  $Form.Controls.Add($ReadMeButton)


  # Activate the form
  $Form.Add_Shown({$Form.Activate()})
  [void] $Form.ShowDialog()
}

function DownloadLatest {
  if (Test-Path -Path "CustomDCS.zip") {
    # Remove old zip
    Remove-Item "CustomDCS.zip"
  }

  if (Test-Path -Path "CustomDCS") {
    # Remove old Folder
    Remove-Item "CustomDCS" -Recurse -Force
  }

  # Download latest CustomDCS/DCS-LUAs-VoiceAttack release from github

  $repo = "CustomDCS/DCS-LUAs-VoiceAttack"
  $file = "CustomDCS.zip"

  $releases = "https://api.github.com/repos/$repo/releases"

  Write-Host Determining latest release
  $tag = (Invoke-WebRequest $releases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

  $download = "https://github.com/$repo/releases/download/$tag/$file"
  #$name = $file.Split(".")[0]
  #$zip = "$name-$tag.zip"
  # $dir = "$name-$tag"

  Write-Host Dowloading latest release
  Invoke-WebRequest $download -Out "CustomDCS.zip"

  Write-Host Extracting release files
  # unpack Zip
  Expand-Archive "CustomDCS.zip" #-DestinationPath "..\Mods\"

  # # Cleaning up target dir
  # Remove-Item $name -Recurse -Force -ErrorAction SilentlyContinue 

  # # Moving from temp dir to target dir
  # Move-Item $dir\$name -Destination $name -Force

  # # Removing temp files
  # Remove-Item $zip -Force
  # Remove-Item $dir -Recurse -Force
}

$installPath = Get-DCSInstallPath
Write-Host "Current DCS install path: " $installPath

Write-Host "Checking that we can find your install folder..." -NoNewline
if(!(Test-Path $installPath))
{
  Write-Error -Message "Folder doesn't seem to be at this path: $installPath" -ErrorAction Continue
  $response = Read-Host -Prompt "Would you like to select your DCS install folder manually? (Y/N)"
  if($response -eq "Y")
  {
    $installPath = Get-DCSInstallPath
  } else {
    Write-Host "Installer Exiting"
    exit 1
  }
}
else {
  Write-Host "success!"
  
}

DownloadLatest

# get list of airframes
$airframePath = "CustomDCS\Mods\aircraft"
if (!(Test-Path $airframePath)) {
  $airframePath = "Mods\aircraft"
}

$airframes = (Get-ChildItem -Path $airframePath -Directory).Name
#$airframes = @("Mi-8MTV2")
Write-Host $airframes
AutoStartSelection -airframes $airframes #, $installPath