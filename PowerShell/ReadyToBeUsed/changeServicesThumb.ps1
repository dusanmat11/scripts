function Save-SSLCERT ($ver) {
    Start-Transcript -path "C:\ProgramData\IPS GmbH\logs\$ver`_SSLCERT.txt" -append
    netsh http show sslcert
    Stop-Transcript
    }
    
function Get-SSLCERT {
    param(
#      [parameter(position=0,mandatory=$true)]
#      [ValidateSet('ips-energy','ips-cloud')]
        [string] $hostname
    ) 
$usedssl = netsh http show sslcert | findstr $hostname 
    if ($hostname -ne $null -and $hostname.Contains('ips-energy')){
            foreach ($ssl in $usedssl) {
                 if ($ssl -ne $null -and $ssl.Contains(': ')){
                 $fqdn = $ssl.Split(':')[2]
                 $port = $ssl.Split(':')[3]
                        if ($port -ne 443){    
                            Write-Host $ssl                               
                        }
                    }
            }
    }elseif ($hostname -ne $null){
            foreach ($ssl in $usedssl) {
                 if ($ssl -ne $null -and $ssl.Contains(': ')){
                 $fqdn = $ssl.Split(':')[2]
                 $port = $ssl.Split(':')[3]
                        if ($port -ne 443){  
                            Write-Host $ssl
                        }           
                    }    
            } 
    }
}

function Change-SSLCERT {
    param(
        [parameter(position=0,mandatory=$true)]
        [ValidateSet('ips-energy','ips-cloud')]
        [string] $hostname
    ) 
$logfile = "C:\ProgramData\IPS GmbH\logs\SSLCERT.log"
$kada = Get-Date
if (!(Test-Path $logfile -PathType leaf))
{ Write-Host "$logfile doesn't exist!"
   Add-Content $logfile $kada
   Add-Content $logfile "prvi put pokrenut..."
}      
$usedssl = netsh http show sslcert | findstr $hostname 
    if ($hostname -ne $null -and $hostname.Contains('ips-energy')){
    $thumbprint = "cc54d149205866eb0816a375b774de11d756a5cd"
    $stampaj = "$kada $hostname"
    Add-Content  $logfile $stampaj
            foreach ($ssl in $usedssl) {
                 if ($ssl -ne $null -and $ssl.Contains(': ')){
                 $fqdn = $ssl.Split(':')[2]
                 $port = $ssl.Split(':')[3]
                 $hostport =  $fqdn + ":" + $port
                        if ($port -ne 443){
                        $brisem = "Delete:" + $fqdn + ":" + $port
                        $hostport =  $fqdn + ":" + $port
                        $thumbprint = "cc54d149205866eb0816a375b774de11d756a5cd"
                        $appid 
                        Add-Content $logfile $brisem
                        Write-Host Brisem: netsh http delete sslcert hostnameport=$fqdn":"$port
                        Invoke-Expression "netsh http delete sslcert hostnameport=$hostport"
                        $dodajem = "netsh.exe http add sslcert hostnameport=" + $fqdn + ":" + $port + " certhash= " + $thumbprint + " appid=`"{00000000-0000-0000-0000-000000000000}`" certstorename=MY"
                        Write-Host Dodajem: netsh.exe http add sslcert hostnameport=$fqdn":"$port certhash= $thumbprint appid="{00000000-0000-0000-0000-000000000000}" certstorename=MY
                        Invoke-Expression "netsh http add sslcert hostnameport=$hostport certhash=$thumbprint appid=`"`{00000000-0000-0000-0000-000000000000`}`" certstorename=MY"
                        Add-Content $logfile $dodajem                                         
                        }
                  }
            }
    }elseif ($hostname -ne $null -and $hostname.Contains('ips-cloud')){
    $thumbprint = "b083914619ffc31141b419dac4a60ec369e3a170"
    $stampaj = "$kada $hostname"
    Add-Content  $logfile $stampaj
            foreach ($ssl in $usedssl) {
                 if ($ssl -ne $null -and $ssl.Contains(': ')){
                 $fqdn = $ssl.Split(':')[2]
                 $port = $ssl.Split(':')[3]
                 $hostport =  $fqdn + ":" + $port
                        if ($port -ne 443){
                        $brisem = "Brisem: " + $hostport
                        Add-Content $logfile $brisem
                        Write-Host Brisem: netsh http delete sslcert hostnameport=$fqdn":"$port
                        Invoke-Expression "netsh http delete sslcert hostnameport=$hostport"
                        $dodajem = "netsh.exe http add sslcert hostnameport=" + $fqdn + ":" + $port + " certhash= " + $thumbprint + " appid=`"{00000000-0000-0000-0000-000000000000}`" certstorename=MY"
                        Write-Host Dodajem: netsh.exe http add sslcert hostnameport=$fqdn":"$port certhash= $thumbprint appid="{00000000-0000-0000-0000-000000000000}" certstorename=MY
                        Invoke-Expression "netsh http add sslcert hostnameport=$hostport certhash=$thumbprint appid=`"`{00000000-0000-0000-0000-000000000000`}`" certstorename=MY"
                        Add-Content $logfile $dodajem      
                        }
                 }    
            } 
    }
}