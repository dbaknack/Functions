
$Interfaces = Get-NetIPInterface
$Interfaces = $Interfaces | Where-Object {$_.InterfaceAlias -notlike "LoopBack*"}
$Interfaces = $Interfaces | Where-Object {$_.InterfaceAlias -notlike "Teredo Tunneling Pseudo-Interface*"}
$Interfaces = $Interfaces | Where-Object {$_.InterfaceAlias -notlike "Local Area Connection*"}
$Interfaces = $Interfaces | Where-Object {$_.AddressFamily -notlike "IPv6"}

$domain = $env:USERDOMAIN
$hostname = $env:COMPUTERNAME
$counterInterface = 1
$adapterResults = @()
foreach($interface in $Interfaces){

    if(($interface.InterfaceAlias).count -ne 0){
         $adapterProperties = [ordered]@{
            RecID           = $counterInterface++
            DomainName      = $domain
            HostName        = $hostname
            DHCP            = [string]
            InterfaceAlias  = [string]
            IPAddress       = [string]
            MacAddress      = [string]
            OctetIndex0     = [int]
            OctetIndex1     = [int]
            OctetIndex2     = [int]
            OctetIndex3     = [int]
        }


    $adapterProperties.InterfaceAlias   = $interface.InterfaceAlias
    $adapterProperties.MacAddress       = (Get-NetAdapter -name  $adapterProperties.InterfaceAlias).MacAddress
    $adapterProperties.IPAddress        = ((Get-NetIPAddress -InterfaceAlias $interface.InterfaceAlias) | Where-Object {$_.AddressFamily -eq 'IPv4'}).IPV4Address
    $adapterProperties.OctetIndex0      = ($adapterProperties.IPAddress -split '\.')[0]
    $adapterProperties.OctetIndex1      = ($adapterProperties.IPAddress -split '\.')[1]
    $adapterProperties.OctetIndex2      = ($adapterProperties.IPAddress -split '\.')[2]
    $adapterProperties.OctetIndex3      = ($adapterProperties.IPAddress -split '\.')[3]
    $adapterProperties.DHCP = $interface.DHCP
    $adapterResults += New-Object -TypeName psobject -Property $adapterProperties
    }
}

return $adapterResults
