$VMWareSnapin = "VMware.VimAutomation.Core"
Add-PSSnapin $VMWareSnapin -ErrorAction SilentlyContinue

if(!(Get-PSSnapin $VMWareSnapin -ErrorAction SilentlyContinue)){
	Write-Warning "VMWare snapin not found"
	exit(1)
}


$vCenterStatus = @()
$vCenters = "vcenter1_ip","vcenter2_ip"

if(!$credentials){
	$credentials = Get-Credential
}

foreach($vcenter in $vCenters){
	$vc = connect-viserver $vcenter -Credential $credentials
	if($vc.IsConnected){
		$status = "vCenter running on " + $vc.Name + " is up"
	}else{
		$status = "********** " + $vc.Name + " is down **********"
	}
	$vCenterStatus += $status
	Disconnect-VIServer $vCenter -force -Confirm:$false -WarningAction SilentlyContinue -ErrorAction SilentlyContinue | Out-Null
	remove-variable vc, status
}
$vCenterStatus