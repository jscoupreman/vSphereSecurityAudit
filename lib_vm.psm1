<#
This function is provided from this blog post :
http://blogs.vmware.com/PowerCLI/2012/05/working-with-vm-devices-in-powercli.html
#>
Function Get-SerialPort { 
    Param ( 
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        $VM 
    ) 
    Process { 
        Foreach ($VMachine in $VM) { 
            Foreach ($Device in $VMachine.ExtensionData.Config.Hardware.Device) { 
                If ($Device.gettype().Name -eq "VirtualSerialPort"){ 
                    $Details = New-Object PsObject 
                    $Details | Add-Member Noteproperty VM -Value $VMachine 
                    $Details | Add-Member Noteproperty Name -Value $Device.DeviceInfo.Label 
                    If ($Device.Backing.FileName) { $Details | Add-Member Noteproperty Filename -Value $Device.Backing.FileName } 
                    If ($Device.Backing.Datastore) { $Details | Add-Member Noteproperty Datastore -Value $Device.Backing.Datastore } 
                    If ($Device.Backing.DeviceName) { $Details | Add-Member Noteproperty DeviceName -Value $Device.Backing.DeviceName } 
                    $Details | Add-Member Noteproperty Connected -Value $Device.Connectable.Connected 
                    $Details | Add-Member Noteproperty StartConnected -Value $Device.Connectable.StartConnected 
                    $Details 
                } 
            } 
        } 
    } 
}

<#
This function is provided from this blog post :
http://blogs.vmware.com/PowerCLI/2012/05/working-with-vm-devices-in-powercli.html
#>
Function Get-ParallelPort { 
    Param ( 
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        $VM 
    ) 
    Process { 
        Foreach ($VMachine in $VM) { 
            Foreach ($Device in $VMachine.ExtensionData.Config.Hardware.Device) { 
                If ($Device.gettype().Name -eq "VirtualParallelPort"){ 
                    $Details = New-Object PsObject 
                    $Details | Add-Member Noteproperty VM -Value $VMachine 
                    $Details | Add-Member Noteproperty Name -Value $Device.DeviceInfo.Label 
                    If ($Device.Backing.FileName) { $Details | Add-Member Noteproperty Filename -Value $Device.Backing.FileName } 
                    If ($Device.Backing.Datastore) { $Details | Add-Member Noteproperty Datastore -Value $Device.Backing.Datastore } 
                    If ($Device.Backing.DeviceName) { $Details | Add-Member Noteproperty DeviceName -Value $Device.Backing.DeviceName } 
                    $Details | Add-Member Noteproperty Connected -Value $Device.Connectable.Connected 
                    $Details | Add-Member Noteproperty StartConnected -Value $Device.Connectable.StartConnected 
                    $Details 
                } 
            } 
        } 
    } 
}



<#
########################
# Unprivileged User Accounts : Disk shrinking feature
########################
# https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vmtools.install.doc%2FGUID-685722FA-9009-439C-9142-18A9E7C592EA.html
# Shrinking a virtual disk reclaims unused disk space. Users and processes
# without root or administrator privileges can invoke this procedure.
# Because the disk-shrinking process can take considerable time to complete,
# invoking the disk-shrinking procedure repeatedly can cause a denial of service.
# The virtual disk is unavailable during the shrinking process. Use the following
# .vmx settings to disable disk shrinking:
########################
#>
function checkDiskShrinkingFeature($advancedSettings){
    Write-Host "Disk shrinking feature... " -NoNewline
	$diskWiper = $advancedSettings | where {$_.Name -eq "isolation.tools.diskWiper.disable"}
	$diskShrink = $advancedSettings | where {$_.Name -eq "isolation.tools.diskShrink.disable"}

    if($diskWiper -and $diskShrink){
        Write-Host "OK" -ForegroundColor Green
        return $true
    }else{
        Write-Host "Not compliant !" -ForegroundColor Red
        return $false
    }
}


<#
########################
# Unprivileged User Accounts : Copy and paste feature
########################
# https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vmtools.install.doc%2FGUID-685722FA-9009-439C-9142-18A9E7C592EA.html
# By default, the ability to copy and paste text, graphics, and files is disabled,
# as is the ability to drag and drop files. When this feature is enabled, you can
# copy and paste rich text and, depending on the VMware product, graphics and files
# from your clipboard to the guest operating system in a virtual machine. That is,
# as soon as the console window of a virtual machine gains focus, nonprivileged
# users and processes running in the virtual machine can access the clipboard on
# the computer where the console window is running. To avoid risks associated with
# this feature, retain the following .vmx settings, which disable copying and pasting:
########################
#>
function checkCopyAndPasteFeature($advancedSettings){
    Write-Host "Copy and paste feature... " -NoNewline
	$copy = $advancedSettings | where {$_.Name -eq "isolation.tools.copy.disable"}
    $paste = $advancedSettings | where {$_.Name -eq "isolation.tools.paste.disable"}
    $dnd = $advancedSettings | where {$_.Name -eq "isolation.tools.dnd.disable"}
    $gui = $advancedSettings | where {$_.Name -eq "isolation.tools.setGUIOptions.enable"}
    if($copy -and $paste -and $dnd -and !$gui){
        Write-Host "OK" -ForegroundColor Green
        return $true
    }else{
        Write-Host "Not compliant !" -ForegroundColor Red
        return $false
    }
}

<#
########################
# Virtual Devices : Connecting and modifying devices
########################
# https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vmtools.install.doc%2FGUID-685722FA-9009-439C-9142-18A9E7C592EA.html
# By default, the ability to connect and disconnect devices is disabled.
# When this feature is enabled, users and processes without root or administrator
# privileges can connect devices such as network adapters and CD-ROM drives,
# and they can modify device settings. That is, a user can connect a disconnected
# CD-ROM drive and access sensitive information on the media left in the drive.
# A user can also disconnect a network adapter to isolate the virtual machine from
# its network, which is a denial of service. To avoid risks associated with this
# feature, retain the following .vmx settings, which disable the ability to connect
# and disconnect devices or to modify device settings:
########################
#>
function checkConnectingAndModifyingDevices($advancedSettings){
    Write-Host "Connecting and modifying devices... " -NoNewline
	$connectable = $advancedSettings | where {$_.Name -eq "isolation.device.connectable.disable"}
    $edit = $advancedSettings | where {$_.Name -eq "isolation.device.edit.disable"}
    if($connectable -and $edit){
        Write-Host "OK" -ForegroundColor Green
        return $true
    }else{
        Write-Host "Not compliant !" -ForegroundColor Red
        return $false
    }
}

<#
########################
# Virtual Devices : Virtual Machine Communication Interface (VMCI)
########################
# https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vmtools.install.doc%2FGUID-685722FA-9009-439C-9142-18A9E7C592EA.html
# If VMCI is not restricted, a virtual machine can detect and be detected by all
# others with the same option enabled within the same host. Custom-built software
# that uses this interface might have unexpected vulnerabilities that lead to an
# exploit. Also, a virtual machine could detect how many other virtual machines
# are within the same ESX/ESXi system by registering the virtual machine.
# This information could be used for a malicious objective. The virtual machine
# can be exposed to others within the system as long as at least one program is
# connected to the VMCI socket interface. Use the following .vmx setting to
# restrict VMCI:
########################
#>
function checkVMCI($advancedSettings){
    Write-Host "Virtual Machine Communication Interface... " -NoNewline
	$vmci = $advancedSettings | where {$_.Name -eq "vmci0.unrestricted"}
    if(!$vmci){
        Write-Host "OK" -ForegroundColor Green
        return $true
    }else{
        Write-Host "Not compliant !" -ForegroundColor Red
        return $false
    }
}


<#
########################
# Virtual Machine Information Flow : Configuring virtual machine log size
########################
# https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vmtools.install.doc%2FGUID-685722FA-9009-439C-9142-18A9E7C592EA.html
# If VMCI is not restricted, a virtual machine can detect and be detected by all
# others with the same option enabled within the same host. Custom-built software
# that uses this interface might have unexpected vulnerabilities that lead to an
# exploit. Also, a virtual machine could detect how many other virtual machines
# are within the same ESX/ESXi system by registering the virtual machine.
# This information could be used for a malicious objective. The virtual machine
# can be exposed to others within the system as long as at least one program is
# connected to the VMCI socket interface. Use the following .vmx setting to
# restrict VMCI:
########################
#>
function checkLogSize($advancedSettings){
    Write-Host "Logging size... " -NoNewline
	$rotationSize = $advancedSettings | where {$_.Name -eq "log.rotateSize"}
    $keepOld = $advancedSettings | where {$_.Name -eq "log.keepOld"}
    $logging = $advancedSettings | where {$_.Name -eq "logging"}
    if($rotationSize -eq 10000 -and $keepOld -eq 10 -and !$logging){
        Write-Host "OK" -ForegroundColor Green
        return $true
    }else{
        Write-Host "Not compliant !" -ForegroundColor Red
        return $false
    }
}


<#
########################
# Virtual Machine Information Flow : VMX file size
########################
# https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vmtools.install.doc%2FGUID-685722FA-9009-439C-9142-18A9E7C592EA.html
# By default the configuration file is limited to a size of 1MB because
# uncontrolled size for the file can lead to a denial of service if the
# datastore runs out of disk space. Informational messages are sometimes sent
# from the virtual machine to the .vmx file. These setinfo messages define
# virtual machine characteristics or identifiers by writing name-value pairs
# to the file. You might need to increase the size of the file if large amounts
# of custom information must be stored in the file. The property name is
# tools.setInfo.sizeLimit, and you specify the value in kilobytes.
# Retain the following .vmx setting:
########################
#>
function checkVMXFileSize($advancedSettings){
    Write-Host "VMX file size... " -NoNewline
	$filesize = $advancedSettings | where {$_.Name -eq "tools.setInfo.sizeLimit"}
    if($filesize -eq 1048576){
        Write-Host "OK" -ForegroundColor Green
        return $true
    }else{
        Write-Host "Not compliant !" -ForegroundColor Red
        return $false
    }
}

<#
########################
# Virtual Machine Information Flow : Features not exposed in vSphere that could cause vulnerabilities
########################
# https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vmtools.install.doc%2FGUID-685722FA-9009-439C-9142-18A9E7C592EA.html
# Because VMware virtual machines run in many VMware products in addition
# to vSphere, some virtual machine parameters do not apply in a vSphere
# environment. Although these features do not appear in vSphere user interfaces,
# disabling them reduces the number of vectors through which a guest operating
# system could access a host. Use the following .vmx setting to disable these features:
########################
#>
function checFeatures($advancedSettings){
    Write-Host "VM Features... " -NoNewline
	$unity = $advancedSettings | where {$_.Name -eq "isolation.tools.unity.push.update.disable"}
    $hgfsServerSet = $advancedSettings | where {$_.Name -eq "isolation.tools.hgfsServerSet.disable"}
    $memSchedFakeSampleStats = $advancedSettings | where {$_.Name -eq "isolation.tools.memSchedFakeSampleStats.disable"}
    $getCreds = $advancedSettings | where {$_.Name -eq "isolation.tools.getCreds.disable"}
    if($unity -and $hgfsServerSet -and $memSchedFakeSampleStats -and $getCreds){
        Write-Host "OK" -ForegroundColor Green
        return $true
    }else{
        Write-Host "Not compliant !" -ForegroundColor Red
        return $false
    }
}

<#
########################
# VM.disable-independent-nonpersistent
########################
# The security issue with nonpersistent disk mode is that successful attackers,
# with a simple shutdown or reboot, might undo or remove any traces that they
# were ever on the machine. To safeguard against this risk, production virtual
# machines should be set to use persistent disk mode; additionally, make sure
# that activity within the VM is logged remotely on a separate server, such as
# a syslog server or equivalent Windows-based event collector. Without a
# persistent record of activity on a VM, administrators might never know whether
# they have been attacked or hacked.
########################
#>
function checkNonPersistentDisks($VM){
    Write-Host "Checking non-persistent disks... " -NoNewline
    $nonPersistentDisks = $VM | Get-HardDisk | where {$_.Persistence -like "*nonpersistent*"}
    if($nonPersistentDisks.count -gt 0){
        Write-Host "Not compliant !" -ForegroundColor Red
        foreach($disk in $nonPersistentDisks){
            $disk |select *
            Write-Host "`t-$($disk.FileName) ($($disk.Persistence))"
        }
        return $false
    }else{
        Write-Host "OK" -ForegroundColor Green
        return $true
    }
}

<#
########################
# VM.disable-unexposed-features-autologon
########################
# Some VMX parameters don't apply on vSphere because VMware virtual machines
# work on both vSphere and hosted virtualization platforms such as Workstation
# and Fusion. Explicitly disabling these features reduces the potential for
# vulnerabilities because it reduces the number of ways in which a guest
# can affect the host.
########################
#>
function checkAutologin($advancedSettings){
    Write-Host "Autologon... " -NoNewline
	$autologon = $advancedSettings | where {$_.Name -eq "isolation.tools.ghi.autologon.disable"}
    if($autologon){
        Write-Host "OK" -ForegroundColor Green
        return $true
    }else{
        Write-Host "Not compliant !" -ForegroundColor Red
        return $false
    }
}

<#
########################
# VM.disable-unexposed-features
########################
# Some VMX parameters don't apply on vSphere because VMware virtual machines work
# on vSphere and hosted virtualization platforms such as Workstation and Fusion.
# Explicitly disabling these features reduces the potential for vulnerabilities
# because it reduces the number of ways in which a guest can affect the host.
########################
#>
function checkUnexposedFeatures($advancedSettings){
    Write-Host "Unexposed features... " -NoNewline

    $biosbbs = $advancedSettings | where {$_.Name -eq "isolation.bios.bbs.disable"}
    $getCreds = $advancedSettings | where {$_.Name -eq "isolation.tools.getCreds.disable"}
    $launchmenu = $advancedSettings | where {$_.Name -eq "isolation.tools.ghi.launchmenu.change"}
    $memSchedFakeSampleStats = $advancedSettings | where {$_.Name -eq "isolation.tools.memSchedFakeSampleStats.disable"}
    $protocolhandler = $advancedSettings | where {$_.Name -eq "isolation.tools.ghi.protocolhandler.info.disable"}
    $shellAction = $advancedSettings | where {$_.Name -eq "isolation.ghi.host.shellAction.disable"}
    $dispTopoRequest = $advancedSettings | where {$_.Name -eq "isolation.tools.dispTopoRequest.disable"}
    $trashFolderState = $advancedSettings | where {$_.Name -eq "isolation.tools.trashFolderState.disable"}
    $trayicon = $advancedSettings | where {$_.Name -eq "isolation.tools.ghi.trayicon.disable"}
    $unity = $advancedSettings | where {$_.Name -eq "isolation.tools.unity.disable"}
    $unityInterlockOperation = $advancedSettings | where {$_.Name -eq "isolation.tools.unityInterlockOperation.disable"}
    $update = $advancedSettings | where {$_.Name -eq "isolation.tools.unity.push.update.disable"}
    $taskbar = $advancedSettings | where {$_.Name -eq "isolation.tools.unity.taskbar.disable"}
    $unityActive = $advancedSettings | where {$_.Name -eq "isolation.tools.unityActive.disable"}
    $windowContents = $advancedSettings | where {$_.Name -eq "isolation.tools.unity.windowContents.disable"}
    $vmxDnDVersionGet = $advancedSettings | where {$_.Name -eq "isolation.tools.vmxDnDVersionGet.disable"}
    $guestDnDVersionSet = $advancedSettings | where {$_.Name -eq "isolation.tools.guestDnDVersionSet.disable"}
    $vixMessage = $advancedSettings | where {$_.Name -eq "isolation.tools.vixMessage.disable"}
    $autoInstall = $advancedSettings | where {$_.Name -eq "isolation.tools.autoInstall.disable"}

    if($biosbbs -and $getCreds -and $launchmenu -and $memSchedFakeSampleStats `        -and $protocolhandler -and $shellAction -and $dispTopoRequest `        -and $trashFolderState -and $trayicon -and $unity `        -and $unityInterlockOperation -and $update -and $taskbar `        -and $unityActive -and $windowContents -and $vmxDnDVersionGet `
        -and $guestDnDVersionSet -and $vixMessage -and $autoInstall){
        Write-Host "OK" -ForegroundColor Green
        return $true
    }else{
        Write-Host "Not compliant !" -ForegroundColor Red
        return $false
    }
}

<#
########################
# VM.disconnect-devices-floppy
########################
# Ensure that no device is connected to a virtual machine if it is not required.
# For example, serial and parallel ports are rarely used for virtual machines
# in a datacenter environment, and CD/DVD drives are usually connected only
# temporarily during software installation. For less commonly used devices that
# are not required, either the parameter should not be present or its value must
# be FALSE.  NOTE: The parameters listed are not sufficient to ensure that a
# device is usable; other required parameters specify how each device is instantiated.
# Any enabled or connected device represents a potential attack channel.
#
# When setting is set to FALSE, functionality is disabled, however the device may
# still show up withing the guest operation system.
########################
#>
function checkFloppyDrive($VM){
    Write-Host "Floppy drive " -NoNewline

    $floppy = $VM | Get-FloppyDrive
    if($floppy){
        Write-Host "detected" -ForegroundColor Red
        return $false
    }else{
        Write-Host "undetected" -ForegroundColor Green
        return $true
    }
}

<#
########################
# VM.disconnect-devices-parallel
########################
# Ensure that no device is connected to a virtual machine if it is not required.
# For example, serial and parallel ports are rarely used for virtual machines
# in a datacenter environment, and CD/DVD drives are usually connected only
# temporarily during software installation. For less commonly used devices that
# are not required, either the parameter should not be present or its value must
# be FALSE.  NOTE: The parameters listed are not sufficient to ensure that a
# device is usable; other required parameters specify how each device is instantiated.
# Any enabled or connected device represents a potential attack channel.
#
# When setting is set to FALSE, functionality is disabled, however the device may
# still show up withing the guest operation system.
########################
#>
function checkParallelPort($VM){
    Write-Host "Parallel port " -NoNewline

    $parallel = $VM | Get-ParallelPort
    if($parallel){
        Write-Host "detected" -ForegroundColor Red
        return $false
    }else{
        Write-Host "undetected" -ForegroundColor Green
        return $true
    }
}

<#
########################
# VM.disconnect-devices-serial
########################
# Ensure that no device is connected to a virtual machine if it is not required.
# For example, serial and parallel ports are rarely used for virtual machines
# in a datacenter environment, and CD/DVD drives are usually connected only
# temporarily during software installation. For less commonly used devices that
# are not required, either the parameter should not be present or its value must
# be FALSE.  NOTE: The parameters listed are not sufficient to ensure that a
# device is usable; other required parameters specify how each device is instantiated.
# Any enabled or connected device represents a potential attack channel.
#
# When setting is set to FALSE, functionality is disabled, however the device may
# still show up withing the guest operation system.
########################
#>
function checkSerialPort($VM){
    Write-Host "Serial port " -NoNewline

    $serial = $VM | Get-SerialPort
    if($serial){
        Write-Host "detected" -ForegroundColor Red
        return $false
    }else{
        Write-Host "undetected" -ForegroundColor Green
        return $true
    }
}

<#
########################
# VM.disconnect-devices-CD
########################
# Ensure that no device is connected to a virtual machine if it is not required.
# For example, serial and parallel ports are rarely used for virtual machines
# in a datacenter environment, and CD/DVD drives are usually connected only
# temporarily during software installation. For less commonly used devices that
# are not required, either the parameter should not be present or its value must
# be FALSE.  NOTE: The parameters listed are not sufficient to ensure that a
# device is usable; other required parameters specify how each device is instantiated.
# Any enabled or connected device represents a potential attack channel.
#
# When setting is set to FALSE, functionality is disabled, however the device may
# still show up withing the guest operation system.
########################
#>
function checkCDDrive($VM){
    Write-Host "CD Drive " -NoNewline

    $cd = $VM | Get-CDDrive
    if($cd){
        Write-Host "detected, checking inserted media... " -NoNewline
        if($cd.IsoPath){
            Write-Host "ISO path undetected" -ForegroundColor Green
            return $true
        }else{
            Write-Host "ISO path detected" -ForegroundColor Red
            return $false
        }
    }else{
        Write-Host "undetected" -ForegroundColor Yellow
        return $true
    }
}


<#
########################
# VM.disconnect-devices-USB
########################
# Ensure that no device is connected to a virtual machine if it is not required.
# For example, serial and parallel ports are rarely used for virtual machines
# in a datacenter environment, and CD/DVD drives are usually connected only
# temporarily during software installation. For less commonly used devices that
# are not required, either the parameter should not be present or its value must
# be FALSE.  NOTE: The parameters listed are not sufficient to ensure that a
# device is usable; other required parameters specify how each device is instantiated.
# Any enabled or connected device represents a potential attack channel.
#
# When setting is set to FALSE, functionality is disabled, however the device may
# still show up withing the guest operation system.
########################
#>
function checkUSBDevice($VM){
     Write-Host "USB Device " -NoNewline
    $usb = $VM | Get-USBDevice
    if($usb){
        Write-Host "detected" -ForegroundColor Red
        return $false
    }else{
        Write-Host "undetected" -ForegroundColor Green
        return $true
    }
}