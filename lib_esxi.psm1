<#
########################
# Display Overall Status
########################
#>
function displayOverallStatus($view){

    Write-Host "Overall Status : " -NoNewline
    switch($view.OverallStatus){
        "green" {
            Write-Host "healthy" -ForegroundColor Green
            return $true
            }
        "yellow" {
            Write-Host "warning" -ForegroundColor yellow
            return $false
        }
        "red" {
            Write-Host "critical" -ForegroundColor red
            return $false
        }
        default {Write-Host $view.OverallStatus}
    }
}


<#
########################
# Display Config Status
########################
#>
function displayConfigStatus($view){
    Write-Host "Config Status : " -NoNewline
    switch($view.ConfigStatus){
        "green" {
            Write-Host "healthy" -ForegroundColor Green
            return $true
            }
        "yellow" {
            Write-Host "warning" -ForegroundColor yellow
            return $false
            }
        "red" {
            Write-Host "critical" -ForegroundColor red
            return $fale
            }
        default {Write-Host $view.ConfigStatus}
    }
}


<#
########################
# ESXi.apply-patches
########################
# By staying up to date on ESXi patches, vulnerabilities in the hypervisor can
# be mitigated. An educated attacker can exploit known vulnerabilities when
# attempting to attain access or elevate privileges on an ESXi host.
########################
#>
function getAppliedPatches($VMHost){
    # TBD
    <# 
    $esxcli = Get-EsxCli -VMHost $VMHost.Name
    $patchList = $esxcli.software.vib.list()
    $patchList | sort ReleaseDate | select ID, ReleaseDate, InstallDate | ft -AutoSize
    #>
}


<#
########################
# ESXi.audit-exception-users
########################
# In vSphere 6.0 and later, you can add users to the Exception Users list from
# the vSphere Web Client. These users do not lose their permissions when the
# host enters lockdown mode. Usually you may want to add service accounts such
# as a backup agent to the Exception Users list. Verify that the list of users
# who are exempted from losing permissions is legitimate and as needed per your
# enviornment. Users who do not require special permissions should not be
# exempted from lockdown mode.
########################
#>
function getExceptionUses($VMHost){
    #$lockdown = Get-View $VMHost.ConfigManager.HostAccessManager
    #$LDusers = $lockdown.QueryLockdownExcetions()
    #
    # TO BE COMPLETED WITH ESXi 6 ENV
    #
}


<#
########################
# ESXi.config-ntp
########################
# By ensuring that all systems use the same relative time source (including
# the relevant localization offset), and that the relative time source can
# be correlated to an agreed-upon time standard (such as Coordinated Universal
# Time—UTC), you can make it simpler to track and correlate an intruder’s
# actions when reviewing the relevant log files. Incorrect time settings
# can make it difficult to inspect and correlate log files to detect attacks,
# and can make auditing inaccurate.
########################
#>
function getNTPConfig($VMHost){
    Write-Host "Checking NTP Servers ... " -NoNewline
    $ntpServers = $VMHost | Get-VMHostNtpServer
    <#if($ntpServers.Count -lt 2){
        Write-Host "No NTP failover found !" -ForegroundColor Red
    }else{#>
    if($ntpServers -like "*ntp1*"){
        Write-Host "ntp1 found " -ForegroundColor Green -NoNewline
        $status1 = $true
    }else{
        Write-Host "ntp1 not found " -ForegroundColor Red -NoNewline
        $status1 = $false
    }
    if($ntpServers -like "*ntp2*"){
        Write-Host "ntp2 found " -ForegroundColor Green #-NoNewline
        $status2 = $true
    }else{
        Write-Host "ntp2 not found " -ForegroundColor Red #-NoNewline
        $status2 = $false
    }
    return $status1 -and $status2
}


<#
########################
# ESXi.config-persistent-logs
########################
# ESXi can be configured to store log files on an in-memory file system.
# This occurs when the host's "/scratch" directory is linked to "/tmp/scratch".
# When this is done only a single day's worth of logs are stored at any time.
# In addition log files will be reinitialized upon each reboot.
# This presents a security risk as user activity logged on the host is only
# stored temporarily and will not persistent across reboots.  This can also
# complicate auditing and make it harder to monitor events and diagnose issues.
# ESXi host logging should always be configured to a persistent datastore.
########################
#>
function getPersistentLogsConfig($VMHost){
    $logPath = $VMHost | Get-AdvancedSetting Syslog.global.logDir | Select -ExpandProperty Value
    Write-Host "Local log storage : " -NoNewline
    if($logPath -eq "[] /scratch/log"){
        Write-Host "not compliant" -ForegroundColor Red
        return $false
    }else{
        Write-Host "compliant" -ForegroundColor Green
        return $true
    }
}


<#
########################
# ESXi.config-snmp
########################
# If SNMP is not being used, it should remain disabled. If it is being used,
# the proper trap destination should be configured. If SNMP is not properly
# configured, monitoring information can be sent to a malicious host that
# can then use this information to plan an attack.  Note:  ESXi 5.1 and later
# supports SNMPv3 which provides stronger security than SNMPv1 or SNMPv2,
# including key authentication and encryption.
########################
#>
function getSNMPConfig($VMHost){
    #Connect-VIServer $VMHost.Name -
    #Get-VMHostSnmp
    # TBD : credentials issues
}


<#
########################
# ESXi.disable-mob
########################
# The managed object browser (MOB) provides a way to explore the object model
# used by the VMkernel to manage the host; it enables configurations to be
# changed as well. This interface is meant to be used primarily for debugging
# the vSphere SDK. In Sphere 6.0 this is disabled by default
########################
#>
function getDisabledMob($VMHost){
    #Get-AdvancedSetting Config -Server $VMHost | select * #-Name Config.HostAgent.plugins.solo.enableMob
    # TBD : credentials issues which I need to connect to VIServer
}


<#
########################
# ESXi.enable-ad-auth
########################
# Join ESXi hosts to an Active Directory (AD) domain to eliminate the need to
# create and maintain multiple local user accounts. Using AD for user
# authentication simplifies the ESXi host configuration, ensures password
# complexity and reuse policies are enforced and reduces the risk of security
# breaches and unauthorized access.  Note: if the AD group "ESX Admins"
# (default) exists then all users and groups that are assigned as members
# to this group will have full administrative access to all ESXi hosts the domain.
########################
#>
function getADAuthStatus($VMHost){
    $VMHostDomain = ($VMHost | Get-VMHostAuthentication).Domain
    Write-Host "Joined domain ? " -NoNewline
    if($VMHostDomain -eq $null){
        Write-Host "no" -ForegroundColor Red
        return $false
    }else{
        Write-Host "yes ($VMHostDomain)" -ForegroundColor Green
        return $true
    }
}


<#
########################
# ESXi.enable-auth-proxy
########################
# If you configure your host to join an Active Directory domain using Host
# Profiles the Active Directory credentials are saved in the host profile and
# are transmitted over the network.  To avoid having to save Active Directory
# credentials in the Host Profile and to avoid transmitting Active Directory
# credentials over the network  use the vSphere Authentication Proxy.
########################
#>
function getAuthProxyStatus($VMHost){
    $VMHostFile = $VMHost | Get-VMHostProfile
    if($VMHostFile -eq $null){
        Write-Host "No Host File found, continuing..." -ForegroundColor Yellow
    }else{
        Write-Host "Host File found, displaying information..." -ForegroundColor Green
        Write-Host "`tJoin AD Enabled : $( `$VMHostFile.ExtensionData.Config.ApplyProfile.Authentication.ActiveDirectory.Enabled)"
        Write-Host "`tJoin Domain Method : $(($VMHostFile.ExtensionData.Config.ApplyProfile.Authentication.ActiveDirectory | Select -ExpandProperty Policy | Where {$_.Id -eq "JoinDomainMethodPolicy"}).Policyoption.Id)"
    }
}


<#
########################
# ESXi.enable-chap-auth
########################
# vSphere allows for the use of bidirectional authentication of both the iSCSI
# target and host. Choosing not to enforce more stringent authentication can
# make sense if you create a dedicated network or VLAN to service all your
# iSCSI devices. By not authenticating both the iSCSI target and host, there
# is a potential for a MiTM attack in which an attacker might impersonate
# either side of the connection to steal data. Bidirectional authentication
# can mitigate this risk. If the iSCSI facility is isolated from general
# network traffic, it is less vulnerable to exploitation.
########################
#>
function getCHAPAuthStatus($VMHost){
    $VMHostHBA_ISCSI = $VMHost | Get-VMHostHba | Where {$_.Type -eq "Iscsi"}
    if($VMHostHBA_ISCSI -eq $null){
        Write-Host "No iSCSI device found, continuing..."
    }else{
        Write-Host "iSCSI device found, displaying information..."
        foreach($iSCSI in $VMHostHBA_ISCSI){
            Write-Host "`tDevice [$($iSCSI.Device)]"
            Write-Host "`t`tCHAP Type : $($iSCSI.ChapType)"
            Write-Host "`t`tCHAP Name : $($iSCSI.AuthenticationProperties.ChapName)"
        }
    }
}


<#
########################
# ESXi.enable-normal-lockdown-mode
########################
# Enabling lockdown mode disables direct access to an ESXi host requiring the
# host be managed remotely from vCenter Server.  This is done to ensure the
# roles and access controls implemented in vCenter are always enforced and
# users cannot bypass them by logging into a host directly.   By forcing all
# interaction to occur through vCenter Server, the risk of someone
# inadvertently attaining elevated privileges or performing tasks that are
# not properly audited is greatly reduced.  Note:  Lockdown mode does not
# apply to  users who log in using authorized keys. When you use an authorized
# key file for root user authentication, root users are not prevented from
# accessing a host with SSH even when the host is in lockdown mode. 
########################
#>
function getNormalLockdownStatus($VMHost){
    $VMHostNormalLockdown = $VMHost.Extensiondata.Config.adminDisabled
    Write-Host "Normal lockdown is " -NoNewline
    if($VMHostNormalLockdown){
        Write-Host "enabled" -ForegroundColor Green
        return $true
    }else{
        Write-Host "disabled" -ForegroundColor Red
        return $false
    }
}


<#
########################
# ESXi.enable-strict-lockdown-mode
########################
# Enabling lockdown mode disables direct access to an ESXi host requiring the
# host be managed remotely from vCenter Server.  
# This is done to ensure the roles and access controls implemented in vCenter
# are always enforced and users cannot bypass them by logging into a host
# directly.   By forcing all interaction to occur through vCenter Server, the
# risk of someone inadvertently attaining elevated privileges or performing
# tasks that are not properly audited is greatly reduced.  
# Strict lockdown mode stops the DCUI service. However, the ESXi Shell and SSH
# services are independent of lockdown mode. For lockdown mode to be an
# effective security measure, ensure that the ESXi Shell and SSH services are
# also disabled. Those services are disabled by default.
# When a host is in lockdown mode, users on the Exception Users list can access
# the host from the ESXi Shell and through SSH if they have the Administrator
# role on the host and if these services are enabled. This access is possible
# even in strict lockdown mode. Leaving the ESXi Shell service and the SSH
# service disabled is the most secure option. 
########################
#>
function getStrictLockdownStatus($VMHost, $view){
	#To display the mode 
	<#
    $lockdown = Get-View $view.ConfigManager.HostAccessManager
	$lockdown.UpdateViewData()
	$lockdownstatus = $lockdown.LockdownMode
	Write-Host "Lockdown mode on $esxihost is set to $lockdownstatus"
	Write-Host "——————————–"
    #>
    <#
    	# To check if Lockdown mode is enabled
	    Get-VMHost | Select Name,@{N="Lockdown";E={$_.Extensiondata.Config.adminDisabled}}
	
	    #To display the mode 
	    $esxihosts = get-vmhost
	    foreach ($esxihost in $esxihosts)
	      {
	    $myhost = Get-VMHost $esxihost | Get-View
	    $lockdown = Get-View $myhost.ConfigManager.HostAccessManager
	    Write-Host "——————————–"
	    $lockdown.UpdateViewData()
	    $lockdownstatus = $lockdown.LockdownMode
	    Write-Host "Lockdown mode on $esxihost is set to $lockdownstatus"
	    Write-Host "——————————–"
	    }

    #>
}


<#
########################
# ESXi.enable-remote-syslog
########################
# Remote logging to a central log host provides a secure, centralized store
# for ESXi logs. By gathering host log files onto a central host you can more
# easily monitor all hosts with a single tool. You can also do aggregate
# analysis and searching to look for such things as coordinated attacks on
# multiple hosts. Logging to a secure, centralized log server helps prevent
# log tampering and also provides a long-term audit record. To facilitate
# remote logging VMware provides the vSphere Syslog Collector.
########################
#>
function getRemoteSyslogStatus($VMHost){
    $globalLogHost = $VMHost | Get-AdvancedSetting Syslog.global.logHost
    Write-Host "Remote log storage : " -NoNewline
    if($globalLogHost.value.length -eq 0){
        Write-Host "not found" -ForegroundColor Red
        return $false
    }else{
        Write-Host "OK " -ForegroundColor Green -NoNewline
        Write-Host "[" -NoNewline
        foreach($logHost in $globalLogHost.value){
            $DNS = extractAndResolveIP $logHost
            Write-Host "$logHost (" -NoNewline
            if($DNS){
                Write-Host "$DNS" -NoNewline
            }else{
                Write-Host "Unknown DNS" -ForegroundColor Red -NoNewline
            }
            Write-Host ")" -NoNewline
        }
        Write-Host "]"
        return $true
    }
}


<#
########################
# ESXi.firewall-enabled
########################
# Unrestricted access to services running on an ESXi host can expose a host
# to outside attacks and unauthorized access. Reduce the risk by configuring
# the ESXi firewall to only allow access from authorized networks.
########################
#>
function getServiceStatus($VMHost, $services){
    Write-Host "Service status : " -NoNewline
    $notworking = $false
    foreach($service in $services){
        $notworking = $notworking -or ($service.Policy -eq "on" -and !$service.Running) -or ($service.Policy -eq "off" -and $service.Running)
    }
    if($notworking){
        Write-Host "NOT OK" -ForegroundColor Red
        return $false
    }else{
        Write-Host "OK" -ForegroundColor Green
        return $true
    }
}
function getFirewallStatus($VMHost){
	# List all services for a host
    Write-Host "Firewall stats :"
    #$VMHost | Get-VMHostFirewallException | where {$_.Enabled} | select Name, IncomingPorts, OutgoingPorts, Protocols, Enabled, ServiceRunning, ExtensionData.AllowedHosts.AllIP | ft
    #exit(0)
    #return
    # List the services which are enabled and have rules defined for specific IP ranges to access the service
	Write-Host "not allowed hosts"
    $VMHost  | Get-VMHostFirewallException | Where {$_.Enabled -and (-not $_.ExtensionData.AllowedHosts.AllIP)}
	# List the services which are enabled and do not have rules defined for specific IP ranges to access the service
    Write-Host "allowed hosts"
	$VMHost  | Get-VMHostFirewallException | Where {$_.Enabled -and ($_.ExtensionData.AllowedHosts.AllIP)}
}


<#
########################
# ESXi.set-password-policies
########################
# ESXi uses the pam_passwdqc.so plug-in to set password strength and complexity.
# It is important to use passwords that are not easily guessed and that are
# difficult for password generators to determine. Password strength and complexity
# rules apply to all ESXi users, including root. They do not apply to Active
# Directory users when the ESX host is joined to a domain. Those password policies
# are enforced by AD. 
########################
#>
function getPasswordPolicies($VMHost){
    # To be manage with vSphere 6
    Write-Host "Password policies : "
    	$VMHost | Select Name, @{N="Security.PasswordQualityControl";E={$_ | Get-VMHostAdvancedConfiguration Security.PasswordQualityControl | Select -ExpandProperty Values}}

    # | Get-VMHostAdvancedConfiguration Security.PasswordQualityControl | select id, Name |ft
}


<#
########################
# ESXi.set-shell-interactive-timeout
########################
# If a user forgets to log out of their SSH session, the idle connection will
# remains open indefinitely, increasing the potential for someone to gain
# privileged access to the host.  The ESXiShellInteractiveTimeOut allows you
# to automatically terminate idle shell sessions.
########################
#>
function getShellInteractiveTimeoutStatus($VMHost){
    $VMHost | Get-AdvancedSetting UserVars.ESXiShellInteractiveTimeOut
}


<#
########################
# ESXi.set-shell-timeout
########################
# When the ESXi Shell or SSH services are enabled on a host they will run
# indefinitely.  To avoid having these services left running set the
# ESXiShellTimeOut.  The ESXiShellTimeOut defines a window of time after which
# the ESXi Shell and SSH services will automatically be terminated.
########################
#>
function getShellTimeoutStatus($VMHost, $services){
    $shell = $VMHost | Get-VMHostService | where{$_.Key -eq "TSM"}
    $ssh = $VMHost | Get-VMHostService | where{$_.Key -eq "TSM-SSH"}
    if($shell.Running){
        Write-Host "Shell is running, " -NoNewline
    }
    if($ssh.Running){
        Write-Host "SSH is running, " -NoNewline
    }
    Write-Host "checking timeout... " -NoNewline
    $timeout = ($VMHost | Get-AdvancedSetting UserVars.ESXiShellTimeOut).Value
    if(!$timeout){
        Write-Host "there is no timeout !" -ForegroundColor Red
        return $false
    }else{
        Write-Host "timeout is defined to : $timeout" -ForegroundColor Green
        return $true
    }
}


<#
########################
# ESXi.TransparentPageSharing-intra-enabled
########################
# Acknowledgement of the recent academic research that leverages Transparent
# Page Sharing (TPS) to gain unauthorized access to data under certain highly
# controlled conditions and documents VMware’s precautionary measure of
# restricting TPS to individual virtual machines by default in upcoming ESXi
# releases. At this time, VMware believes that the published information
# disclosure due to TPS between virtual machines is impractical in a real
# world deployment. VMs that do not have the sched.mem.pshare.salt option
# set cannot share memory with any other VMs.
########################
#>
function getTSPIntraStatus($VMHost){
    $TPSDefaultValue = 2
    try{
	    $TPSSetting = $VMHost | Get-AdvancedSetting Mem.ShareForceSalting
        if($TPSSetting.Value -eq $TPSDefaultValue){
            Write-Host "Transparent Page Sharing is rightly set" -ForegroundColor Green
            return $true
        }else{
            Write-Host "Transparent Page Sharing should be set to $TPSDefaultValue" -ForegroundColor Yellow
            return $false
        }
    }catch{
        Write-Host "Transparent Page Sharing patch must be applied on this host !" -ForegroundColor Red
        return $false
    }
}


