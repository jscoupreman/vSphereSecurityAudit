function connectTovCenter([Array] $vCenters){
    # If not already connected to a vCenter server
    #if(!$global:DefaultVIServers){
        foreach($vCenter in $vCenters){
            Write-Host "Connection to vCenter [$vCenter]... " -NoNewline
	        $vc = connect-viserver $vcenter -WarningAction SilentlyContinue
	        if($vc.IsConnected){
		        Write-Host "Connected" -ForegroundColor Green
	        }else{
		        Write-Host "ERROR: Could not connect to vCenter server." -ForegroundColor Red
	        }
	        remove-variable vc
        }
    #}
}


function extractIPAddress($string){
    # https://chrisjwarwick.wordpress.com/2012/09/16/more-regular-expressions-regex-for-ip-v4-addresses/
    $IPregex = "(?<Address>((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))"
    if($string -match $IPregex){
        return $Matches.Address
    }
}

function extractAndResolveIP($string){
    $ip = extractIPAddress $string
    if($ip -ne $null){
        try{
            $val =  [System.Net.Dns]::gethostentry($ip).HostName
            return $val
        }catch{
            return $null
        }
    }
}