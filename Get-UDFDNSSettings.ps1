$Interfaces = Get-NetIPInterface
$Interfaces = $Interfaces | Where-Object {$_.InterfaceAlias -notlike "LoopBack*"}
$Interfaces = $Interfaces | Where-Object {$_.InterfaceAlias -notlike "Teredo Tunneling Pseudo-Interface*"}
$Interfaces = $Interfaces | Where-Object {$_.AddressFamily -notlike "IPv6"}
$counterDNS = 1
$DNSResults = @()
$domain = $env:USERDOMAIN
$hostname = $env:COMPUTERNAME
foreach($interface in $Interfaces){

    if(($interface.InterfaceAlias).count -ne 0){
        foreach($DNSAddress in (Get-DnsClientServerAddress -InterfaceAlias ($interface.InterfaceAlias)).ServerAddresses){
        $DNS = [ordered]@{
            RecID           = $counterDNS++
            DomainName      = $domain
            HostName        = $hostname
            InterfaceAlias  = $interface.InterfaceAlias
            Address         = $DNSAddress
        }
        $DNSResults += New-Object -TypeName psobject -Property $DNS
    }
    }
}

return $DNSResults
