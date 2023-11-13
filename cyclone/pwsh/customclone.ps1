param(
[String] $LabName,
[String] $Username,
[String[]] $VMsToClone,
[Boolean] $Natted,
[int] $PortGroup,
[String] $Target,
[String] $Domain,
[String] $WanPortGroup
)

$pg = [int] $PortGroup

$cred = Import-CliXML -Path $env:ProgramFiles\Kamino\lib\creds\vsphere_cred.xml
Connect-VIServer elsa.sdc.cpp -Credential $cred

Invoke-CustomPod -LabName $LabName -Username $Username -Natted $Natted -Target $Target -Portgroup $pg -Domain $domain -WanPortGroup $WanPortGroup -VMsToClone $VMsToClone 