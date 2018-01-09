function loadPSSnapin($snapinName){
    # Snapin already loaded ?
    if(!(Get-PSSnapin $VMWareSnapin -ErrorAction SilentlyContinue)){
        # Check if PS Snapin is available
        $snapinExists = Get-PSSnapin -Registered | where {$_.Name -eq $snapinName}
        # If snapin exists but not loaded
        if($snapinExists){
            #then load the snapin
            Write-Host "Importing snapin [$snapinName]..."
            Add-PSSnapin $snapinName | Out-Null
        }else{
            Write-Warning "Snapin [$snapinName] does not exists. Exiting..."
            exit(1)
        }
    }else{
        #Write-Warning "Snapin [$snapinName] has already been imported."
    }
}

function import($module){
    Remove-Module $module -ErrorAction SilentlyContinue
    if(!(Get-Module -Name $module)){
	    
        $str = "$scriptPath\$module.psm1"
        Write-Host $str
	    Import-Module -name $str
    }
}

clear

$ErrorActionPreference = "Stop"

$VMWareSnapin = "VMware.VimAutomation.Core"
loadPSSnapin $VMWareSnapin

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
Import-Module "$scriptPath\lib.psm1" -Force


$vCenters = "vcenter1_ip","vcenter2_ip"
connectTovCenter $vCenters


Write-Host "Retrieving hosts list... " -NoNewline
$hosts = Get-VMHost | sort Name
Write-Host "done"

Write-Host "Number of Hosts : $($hosts.count)"
Write-Host "Number of VMs : $((Get-VM).count)"
Write-Host "Number of Datastores : $($(Get-Datastore).count)"
Write-Host "Number of Clusters : $((Get-Cluster).count)"
Write-Host "Number of Resource Pools : $((Get-ResourcePool).count)"