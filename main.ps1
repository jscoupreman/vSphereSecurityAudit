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

function setObjectValue($title, $value, $obj){
    if($value -eq $true){
        $obj | Add-Member -NotePropertyName $title -NotePropertyValue "O"
    }elseif($value -eq $false){
        $obj | Add-Member -NotePropertyName $title -NotePropertyValue "X"
    }else{
        $obj | Add-Member -NotePropertyName $title -NotePropertyValue $value
    }
    return $obj
}



function checkESXi(){
    ########################
    # ESXi Status
    ########################
    Write-Host "Retrieving hosts list... " -NoNewline
    $hosts = Get-VMHost | sort Name
    Write-Host "done"

    $esxiObjects = @()

    foreach($VMHost in $hosts){
        $obj = New-Object System.Object
        Write-Host "`n"
        "Checking Host " + $VMHost.Name
        $view = $VMHost | Get-View
        "Member of Cluster : " + $($VMHost | Get-Cluster)
        $services = $VMHost | Get-VMHostService
    
        $obj = setObjectValue "Host" $VMHost.Name $obj
        $obj = setObjectValue "Overall Status" $(displayOverallStatus $view) $obj
        $obj = setObjectValue "Overall Configuration" $(displayConfigStatus $view) $obj
        #getAppliedPatches $VMHost
        #getExceptionUses $VMHost
        $obj = setObjectValue "NTP Configuration" $(getNTPConfig $VMHost) $obj
        $obj = setObjectValue "Persistent Logs Config" $(getPersistentLogsConfig $VMHost) $obj
        #getSNMPConfig $VMHost
        #getDisabledMob $VMHost
        $obj = setObjectValue "AD Authentication" $(getADAuthStatus $VMHost) $obj
        getAuthProxyStatus $VMHost
        getCHAPAuthStatus $VMHost
        $obj = setObjectValue "Normal Lockdown" $(getNormalLockdownStatus $VMHost) $obj
        #getStrictLockdownStatus $VMHost $view
        $obj = setObjectValue "Remote Syslog Storage" $(getRemoteSyslogStatus $VMHost) $obj
        $obj = setObjectValue "Services status" $(getServiceStatus $VMHost $services) $obj
        #getFirewallStatus $VMHost
        #getPasswordPolicies $VMHost
        #getShellInteractiveTimeoutStatus $VMHost
        $obj = setObjectValue "Shell/SSH Timeout" $(getShellTimeoutStatus $VMHost $services) $obj
        $obj = setObjectValue "Transparent Page Sharing" $(getTSPIntraStatus $VMHost) $obj
        #exit(0)
        $esxiObjects += $obj
    }
    $esxiObjects | Export-Csv "$scriptPath\report_esxi.csv" -NoTypeInformation -Delimiter ";"
}

function checkvCenter(){
    ########################
    # vCenter Status
    ########################
    foreach($vCenter in $vCenters){
        # return TBD
        checkNFC_SSLStatus $vCenter
    }
}

function checkVM(){
    ########################
    # VMs Status
    ########################
    Write-Host "Retrieving VMs... " -NoNewline
    $VMs = Get-VM
    Write-Host "done"

    $vmobjects = @()

    foreach($VM in $VMs){
        $obj = New-Object System.Object
        Write-Host "`n"
        Write-Host "Checking VM $($VM.Name)"
        $advancedSettings = $VM | Get-AdvancedSetting
        $obj = setObjectValue "VM" $VM.Name $obj
        $obj = setObjectValue "Disk shrinking" $(checkDiskShrinkingFeature $advancedSettings) $obj
        $obj = setObjectValue "Copy and paste" $(checkCopyAndPasteFeature $advancedSettings) $obj
        $obj = setObjectValue "Connecting and Modifying" $(checkConnectingAndModifyingDevices $advancedSettings) $obj
        $obj = setObjectValue "VM Communication Interface" $(checkVMCI $advancedSettings) $obj
        $obj = setObjectValue "Logging size" $(checkLogSize $advancedSettings) $obj
        $obj = setObjectValue "VMX file size" $(checkVMXFileSize $advancedSettings) $obj
        $obj = setObjectValue "VM features" $(checFeatures $advancedSettings) $obj
        $obj = setObjectValue "Disks persistence" $(checkNonPersistentDisks $VM) $obj
        $obj = setObjectValue "Unexposed features" $(checkUnexposedFeatures $advancedSettings) $obj
        $obj = setObjectValue "Floppy drive" $(checkFloppyDrive $VM) $obj
        $obj = setObjectValue "Parallel port" $(checkParallelPort $VM) $obj
        $obj = setObjectValue "Serial port" $(checkSerialPort $VM) $obj
        $obj = setObjectValue "CD drive" $(checkCDDrive $VM) $obj
        $obj = setObjectValue "USB device" $(checkUSBDevice $VM) $obj
        $vmobjects += $obj
    }
    $vmobjects | Export-Csv "$scriptPath\report_vms.csv" -NoTypeInformation -Delimiter ";"
}

clear

$ErrorActionPreference = "Stop"

$VMWareSnapin = "VMware.VimAutomation.Core"
loadPSSnapin $VMWareSnapin

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
Import-Module "$scriptPath\lib.psm1" -Force
Import-Module "$scriptPath\lib_esxi.psm1" -Force
Import-Module "$scriptPath\lib_vcenter.psm1" -Force
Import-Module "$scriptPath\lib_vm.psm1" -Force


$vCenters = "you_vcenter_ip"
connectTovCenter $vCenters



checkESXi
#checkvCenter
#checkVM