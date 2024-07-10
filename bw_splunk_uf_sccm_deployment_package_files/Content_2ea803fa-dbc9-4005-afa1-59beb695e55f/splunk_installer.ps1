<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShell Studio
	 Created on:   	06.07.2024 13:51
	 Created by:   	drohr@splunk
	 Organization: 	splunk
	 Filename:     	-

     Customer:      Bundeswehr IT Security & Audit
	===========================================================================
	.DESCRIPTION
       - install splunk forwarder with random complex password (32 char) 		
       - remove system/local files
       - e.g. copy deployment server configuration to app folder only
            * deploymentclient.conf
       - multiple apps to copy will be automatic detected

       - detection of system local files (deletion)
            * deploymentclient.conf
            * outputs.conf
#>


# Function to create a random password
Function Create-String([Int]$Size = 8, [Char[]]$CharSets = "ULNS", [Char[]]$Exclude) 
{
    $Chars = @(); $TokenSet = @()
    If (!$TokenSets) {$Global:TokenSets = @{
        U = [Char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZ'                                #Upper case
        L = [Char[]]'abcdefghijklmnopqrstuvwxyz'                                #Lower case
        N = [Char[]]'0123456789'                                                #Numerals
        S = [Char[]]'!"#$%&''()*+,-.'                                           #Symbols
    }}
    $CharSets | ForEach {
        $Tokens = $TokenSets."$_" | ForEach {If ($Exclude -cNotContains $_) {$_}}
        If ($Tokens) {
            $TokensSet += $Tokens
            If ($_ -cle [Char]"Z") {$Chars += $Tokens | Get-Random}             
        }
    }
    While ($Chars.Count -lt $Size) {$Chars += $TokensSet | Get-Random}
    ($Chars | Sort-Object {Get-Random}) -Join ""                               
}; Set-Alias Create-Password Create-String -Description "Generate a random string (password)"


$splunk_process_running_folder = (Get-Process -Name splunkd -FileVersionInfo).FileName
$splunk_root_directory         = $splunk_process_running_folder.Replace("\bin\splunkd.exe","")

Function Write-InstallerLog([string]$InstallerLog)
    {
    Write-Output "$InstallerLog" | Out-File -FilePath "$splunk_root_directory\var\log\splunk\splunk_migration.log" -Append
    }


$DateTimeNow = (get-date).tostring("yyyy.MM.dd hh:mm:ss.ffffff tt K", $enus)
Write-InstallerLog "$DateTimeNow INFO update process pre-check Splunk Universal Forwarder"
# check if splunkd is running
$splunk_file_version           = (Get-Process -Name splunkd -FileVersionInfo).FileVersion
$splunk_process_running        = Get-Process -Name splunkd -ErrorAction SilentlyContinue
$check_system_local_conf_files = Get-ChildItem -Path "$splunk_root_directory\etc\system\local"
$Splunk_Resource_Install_MSI   = (Get-ChildItem -Path $PSScriptRoot -Filter "*.msi").FullName
$Splunk_Resource_DeployApps    = (Get-ChildItem -Path $PSScriptRoot | ? {$_.Attributes -match "Directory"}).FullName
$randompwd                     = Create-String 20 ULNS


$DateTimeNow = (get-date).tostring("yyyy.MM.dd hh:mm:ss.ffffff tt K", $enus)
Write-InstallerLog "$DateTimeNow INFO update process pre-check Splunk Universal Forwarder installed version $splunk_file_version"
Write-InstallerLog "$DateTimeNow INFO update process pre-check Splunk Universal Forwarder installed in $splunk_root_directory"
Write-InstallerLog "$DateTimeNow INFO update process pre-check Splunk Universal Forwarder MSI --> $Splunk_Resource_Install_MSI"


if( ($check_system_local_conf_files.Name -cmatch "deployment") -or ($check_system_local_conf_files.Name -cmatch "output") )
        {
        $DateTimeNow = (get-date).tostring("yyyy.MM.dd hh:mm:ss.ffffff tt K", $enus)
        Write-InstallerLog "$DateTimeNow INFO update process pre-check Splunk Universal Forwarder error local system files are detected"
        Write-InstallerLog "$DateTimeNow INFO update process pre-check Splunk Universal Forwarder error local system conf for deploymentclient or outputs detected"
        $delete_deploymentclient = Get-ChildItem -Path "$splunk_root_directory\etc\system\local\deploymentclient.conf" | Remove-Item -Force -ErrorAction SilentlyContinue
        $delete_outputs          = Get-ChildItem -Path "$splunk_root_directory\etc\system\local\outputs.conf" | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-InstallerLog "$DateTimeNow INFO update process pre-check Splunk Universal Forwarder error local system conf for deploymentclient or outputs were deleted"
        }

$DateTimeNow = (get-date).tostring("yyyy.MM.dd hh:mm:ss.ffffff tt K", $enus)
Write-InstallerLog "$DateTimeNow INFO update process start upgrade splunk forwarder"

Start-Process -FilePath "C:\Windows\system32\msiexec.exe" -Wait -NoNewWindow -ArgumentList "/i $Splunk_Resource_Install_MSI AGREETOLICENSE=Yes SPLUNKUSERNAME=splunkd SPLUNKPASSWORD=$randompwd /q"

# copy all required apps to the splunk uf apps folder
if($Splunk_Resource_DeployApps.Count -gt "1")
    {

        foreach($App IN $Splunk_Resource_DeployApps)

        {
            $DateTimeNow = (get-date).tostring("yyyy.MM.dd hh:mm:ss.ffffff tt K", $enus)
            Write-InstallerLog "$DateTimeNow INFO update process copy $App to $splunk_root_directory\etc\apps"
            Copy-Item -Path $App -Destination "$splunk_root_directory\etc\apps" -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
else
    {
        $DateTimeNow = (get-date).tostring("yyyy.MM.dd hh:mm:ss.ffffff tt K", $enus)
        Write-InstallerLog "$DateTimeNow INFO update process copy $ApplicationTransfer to $splunk_root_directory\etc\apps"
        Copy-Item -Path $Splunk_Resource_DeployApps -Destination "$splunk_root_directory\etc\apps" -Recurse -Force -ErrorAction SilentlyContinue   
    }



$DateTimeNow = (get-date).tostring("yyyy.MM.dd hh:mm:ss.ffffff tt K", $enus)
Write-InstallerLog "$DateTimeNow INFO update process restart splunkd"
Start-Process -FilePath "$splunk_root_directory\bin\splunk.exe" -ArgumentList restart -NoNewWindow
