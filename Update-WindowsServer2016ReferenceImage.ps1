$ISOroot = "W:\ISOs"
$ISOname = "SW_DVD9_Win_Svr_STD_Core_and_DataCtr_Core_2016_64Bit_English_-3_MLF_X21-30350"
$originalISO = "$ISOroot\$ISOname\$ISOname.ISO"
$defaultServerEdition = "Windows Server 2016 SERVERSTANDARD"

$latestReferenceISO = "$ISOroot\$ISOname\_latest_update\WindowsServer2016-en-x64.iso"
$latestReferenceWIM = "$ISOroot\$ISOname\_latest_update\install.wim"
$latestCumulativeUpdate = "$ISOroot\$ISOname\2017-10_CU_(KB4041691)\windows10.0-kb4041691-x64_6b578432462f6bec9b4c903b3119d437ef32eb29.msu"

$MountFolder = "C:\Mount" # $env:Temp
$RefImage = "C:\Setup\REFWS2016-001.wim"
 
$VerbosePreference = 'Continue'
 
# Verify that the ISO and Cumulative Update files exist
if (Test-Path $latestReferenceISO) {
	$workingISO = $latestReferenceISO
} elseif (Test-Path -path $originalISO) {
	$workingISO = $originalISO
} else {
	Write-Warning "Could not find Windows Server 2016 ISO file. Aborting..."
	Break
}

Mount-DiskImage -imagePath $workingISO -Verbose
$ISOdrive = Get-DiskImage -imagePath $workingISO | Get-Volume | Select -expand DriveLetter
$ISOdrive += ':'

if (Test-Path $latestCumulativeUpdate) {
	if ( -Not(Test-Path $latestReferenceWIM) ) {
		Export-WindowsImage -sourceImagePath "$ISOdrive\sources\install.wim" `
				-sourceName $defaultServerEdition `
				-destinationImagePath $latestReferenceWIM -Verbose
	}
} else {
	Write-Warning "Could not find Cumulative Update for Windows Server 2016. Aborting..."
	Break
}
 
# Add the latest CU to the Windows Server 2016 image
New-Item -path $MountFolder -itemType Directory -ErrorAction SilentlyContinue
Mount-WindowsImage -imagePath $latestReferenceWIM -index 1 -path $MountFolder
Add-WindowsPackage -PackagePath $latestCumulativeUpdate -path $MountFolder
 
# Add .NET Framework 3.5.1 to the Windows Server 2016 Standard image
Add-WindowsPackage -PackagePath $ISOdrive\sources\sxs\microsoft-windows-netfx3-ondemand-package.cab -path $MountFolder
 
# Dismount the Windows Server 2016 Standard image
Dismount-WindowsImage -Path $MountFolder -Save
 
# Dismount the Windows Server 2016 ISO
Dismount-DiskImage -imagePath $ISO
