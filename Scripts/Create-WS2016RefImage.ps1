$ISO = "C:\Setup\ISO\Windows Server 2016.iso"
$CU = "C:\Setup\CU\windows10.0-kb4041691-x64_6b578432462f6bec9b4c903b3119d437ef32eb29.msu"   
                   
$MountFolder = "C:\Mount"
$RefImage = "C:\Setup\REFWS2016-001.wim"
 
# Verify that the ISO and CU files exist
if (!(Test-Path -path $ISO)) {Write-Warning "Could not find Windows Server 2016 ISO file. Aborting...";Break}
if (!(Test-Path -path $CU)) {Write-Warning "Could not find Cumulative Update for Windows Server 2016. Aborting...";Break}
 
# Mount the Windows Server 2016 ISO
Mount-DiskImage -ImagePath $ISO
$ISOImage = Get-DiskImage -ImagePath $ISO | Get-Volume
$ISODrive = [string] $ISOImage.DriveLetter + ":"
 
# Extract the Windows Server 2016 Standard index to a new WIM
Export-WindowsImage `
    -SourceImagePath "$ISODrive\sources\install.wim" `
    -SourceName "Windows Server 2016 SERVERSTANDARD" `
    -DestinationImagePath $RefImage
 
# Add the latest CU to the Windows Server 2016 image
if (!(Test-Path -path $MountFolder)) { 
  New-Item -path $MountFolder -ItemType Directory
}
Mount-WindowsImage -ImagePath $RefImage -Index 1 -Path $MountFolder
Add-WindowsPackage -PackagePath $CU -Path $MountFolder
 
# Add .NET Framework 3.5.1 to the Windows Server 2016 Standard image
Add-WindowsPackage -PackagePath $ISODrive\sources\sxs\microsoft-windows-netfx3-ondemand-package.cab -Path $MountFolder
 
# Dismount the Windows Server 2016 Standard image
DisMount-WindowsImage -Path $MountFolder -Save
 
# Dismount the Windows Server 2016 ISO
Dismount-DiskImage -ImagePath $ISO
