<#
########################
# vCenter.verify-nfc-ssl
########################
# NFC (Network File Copy) is the name of the mechanism used to migrate or clone
# a VM between two ESXi hosts over the network.  
# By default, NFC over SSL is enabled (ie: "True") within a vSphere cluster but
# the value of the setting is null.
# Clients check the value of the setting and default to not using SSL for
# performance reasons if the value is null. This behavior can be changed by
# ensuring the setting has been explicitly created and set to "True". This will
# force clients to use SSL.
########################
#>
function checkNFC_SSLStatus($vcenterFQDN){
    # Check Network File Copy NFC uses SSL. OS Administrator Privileges will
    # be needed on your server for this to complete
    Write-Host "Checking Network File Copy using SSL on [$vcenterFQDN]... " -NoNewline
    $result = get-advancedsetting -entity $vcenterFQDN -name config.nfc.useSSL
    # it looks not available for vCenter 5
    if($result){
        # do some stuffs
    }else{
        Write-Host "this configuration looks unavailable for this version of vCenter" -ForegroundColor Red
    }
}