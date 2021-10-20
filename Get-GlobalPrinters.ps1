function Get-GlobalPrinters {
    <#
    .SYNOPSIS
        Get user and globally installed printers from a remote computer
    .DESCRIPTION
        Get user and globally installed printers from a remote computer
    .EXAMPLE
        PS C:\> Get-PrinterInformation -ComputerName 999TSTPC999
        Gets printer information
    .INPUTS
        [string] for ComputerName
    .OUTPUTS
        [PSCustomObject] as results
    .NOTES
        Requires remote registry permissions
    #>
    [CmdletBinding()]
	param (
		# Name of computer to retrieve information from
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true)]
		[string]$ComputerName
	)

    begin{
        # Set object to collect printer info
        $Global:PrinterInformation = [System.Collections.Generic.List[System.Object]]::New()
    }
    
    process {
        if (!(Test-Connection -Count 1 -ComputerName $ComputerName -Quiet))
		{
			throw "Unable to connect to $ComputerName"
		}

        try{
            # Open remote registry
            $RemoteRegistry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ComputerName)

            # Set Global installed printers path
            $GlobalInstalledPrintersPath = 'Software\Microsoft\Windows NT\CurrentVersion\Print\Connections\'
            
            # Open global printer installed path
            $GlobalKey = $RemoteRegistry.OpenSubKey($GlobalInstalledPrintersPath)
            
            # Get the connection names for each printer
            $GlobalInstalledPrinters = $GlobalKey.GetSubKeyNames() | ForEach-Object { $GlobalKey.OpenSubKey($_).GetValue('Printer').ToUpper() }
        }
        catch{
            throw $_
        }
        
        return $GlobalInstalledPrinters
    }
}
