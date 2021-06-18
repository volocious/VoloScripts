function Get-SoftwareList
{
	# This shit is disgusting, what was I thinking?
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[string]$ComputerName
	)
	
	$colSoftwareReport = [System.Collections.Generic.List[System.Object]]::new()
	$strStatus = ''
	if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet)
	{
		try
		{
			$RemoteSoftware32Registry = ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', "$ComputerName")).OpenSubKey('Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\')
			$RemoteSoftware64Registry = ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', "$ComputerName")).OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\')
		}
		catch
		{
			$SoftwareReturnObj = [pscustomobject]@{
				Status = "Unable to access remote registry"
				Results = $null
			}
			return $SoftwareReturnObj
		}
		$colSoftwareRaw = [System.Collections.Generic.List[System.Object]]::new()
		foreach ($KeyName in ($RemoteSoftware32Registry).GetSubKeyNames())
		{
			$TempObject = [pscustomobject]@{
				'DistinguishedName' = $null
				'DisplayName'	    = $null
				'DisplayVersion'    = $null
				'Publisher'		    = $null
				'InstallLocation'   = $null
				'InstallDate'	    = $null
				'UninstallString'   = $null
			}
			$Reg32Key = $RemoteSoftware32Registry.OpenSubKey("$KeyName")
			$TempObject.DistinguishedName = $KeyName
			$TempObject.DisplayName = $Reg32Key.GetValue('DisplayName')
			$TempObject.DisplayVersion = $Reg32Key.GetValue('DisplayVersion')
			$TempObject.Publisher = $Reg32Key.GetValue('Publisher')
			$TempObject.InstallLocation = $Reg32Key.GetValue('InstallLocation')
			$TempObject.UninstallString = $Reg32Key.GetValue('UninstallString')
			$TempObject.InstallDate = $Reg32Key.GetValue('InstallDate').Insert(6,'-').Insert(4,'-')
			if ($TempObject.DisplayName -eq $null -or $TempObject.DisplayName -eq '')
			{
				continue
			}
			$colSoftwareRaw.Add($TempObject)
		}
		foreach ($KeyName in ($RemoteSoftware64Registry).GetSubKeyNames())
		{
			$TempObject = [pscustomobject]@{
				'DistinguishedName' = $null
				'DisplayName'	    = $null
				'DisplayVersion'    = $null
				'Publisher'		    = $null
				'InstallLocation'   = $null
				'InstallDate'	    = $null
				'UninstallString'   = $null
			}
			$Reg32Key = $RemoteSoftware64Registry.OpenSubKey("$KeyName")
			$TempObject.DistinguishedName = $KeyName
			$TempObject.DisplayName = $Reg32Key.GetValue('DisplayName')
			$TempObject.DisplayVersion = $Reg32Key.GetValue('DisplayVersion')
			$TempObject.Publisher = $Reg32Key.GetValue('Publisher')
			$TempObject.InstallLocation = $Reg32Key.GetValue('InstallLocation')
			$TempObject.UninstallString = $Reg32Key.GetValue('UninstallString')
			$TempObject.InstallDate = $Reg32Key.GetValue('InstallDate').Insert(6, '-').Insert(4, '-')
			if ($null -eq $TempObject.DisplayName -or $TempObject.DisplayName -eq '')
			{
				continue
			}
			$colSoftwareRaw.Add($TempObject)
		}
		$SoftwareReturnObj = [pscustomobject]@{
			Status = 'Complete'
			Results = $colSoftwareRaw | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation, UninstallString | Sort-Object DisplayName
		}
		return $SoftwareReturnObj
	}
	else
	{
		Write-Error "Unable to connect to computer [$computername]"
	}
}
