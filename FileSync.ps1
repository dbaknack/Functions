

param([hashtable]$GetItemsProperties)
$ErrorActionPreference = "Stop"

$GetItemsProperties = @{
    Sources = @(
        @{ Path = "$env:USERPROFILE\Documents\LocalRepo\stig-sql_server_2016" }
    )

    Destination = "R:\"
    Limit = @{
        ItemSize = @{
            Enable = $false
            Bytes = 1000000000
        }
        ItemType = @{
            Enable = $false
            ExtensionsList = @(
                ".exe"
            )
        }
        Exclude = @{
            Enable = $true
            ExclusionList = @(
                "$env:USERPROFILE\Documents\LocalRepo\FileSync\test_destination"
            )
        }
    }
    DeveloperOptions = @{
        FeedBack = @{
            Enable = $true
        }
    }
    Logging = @{
        Enable = $true
        LogPath = "C:\Temp\Logs"
    }
    Progress = @{
        Enable = $false
        updateInterval = 500
    }
}

function Get-Items {
    param([hashtable]$GetItemsProperties)
    begin{

        $globalDestination = $GetItemsProperties.Destination
        write-host $globalDestination -fo Magenta
        if($GetItemsProperties.DeveloperOptions.FeedBack.Enable){
            $feedBack = "| {0}" -f "Running check(s)"
            Write-Host $feedBack -ForegroundColor Yellow
        }
        

        # the destination should always be reachable
        $destinationReachable = $true
        if(-not(Test-Path -Path $globalDestination)){
            $msgError = ("[{0}]:: {1}" -f "Destination validation","Cannot find path '$($globalDestination)'")
            $destinationReachable = $false
            Write-Error $msgError -ErrorAction Stop
        }
        if(($destinationReachable) -and ($GetItemsProperties.DeveloperOptions.FeedBack.Enable)){
            $feedBack = "+- | {0}" -f "Destination validation"
            Write-Host $feedBack -ForegroundColor Yellow
            $feedBack = "|  +- '{0}' is reachable" -f ,$globalDestination
            Write-Host $feedBack -ForegroundColor Yellow
        }

        # all sources need to be resolved and filtered out of any leaf level wildcards
        if($GetItemsProperties.DeveloperOptions.FeedBack.Enable){
            $feedBack = "|"
            Write-Host $feedBack -ForegroundColor Yellow 
        }

        if($GetItemsProperties.DeveloperOptions.FeedBack.Enable){
            $feedBack = "+- | {0}" -f "Resolving source path"
            Write-Host $feedBack -ForegroundColor Yellow
        }
        foreach($source in $GetItemsProperties.Sources){
            if($source['Path']  -match '.*\*$'){
                $msgError = ("[{0}]:: {1}" -f "Source path structure","Leaf is not allowed to be a wildcard '$($sourcePath)'.")
                Write-Error $msgError -ErrorAction Stop
            }
            $source['Path'] = (Resolve-Path -path $source['Path']).Path

            if($GetItemsProperties.DeveloperOptions.FeedBack.Enable){
                $feedBack = "|  +- '{0}' resolved" -f ,$source['Path']
                Write-Host $feedBack -ForegroundColor Yellow
            }
        }

        # when the sources include the destination, the destination is removed from sources
        if($GetItemsProperties.DeveloperOptions.FeedBack.Enable){
            $feedBack = "|"
            Write-Host $feedBack -ForegroundColor Yellow 
        }
        $destinationFilteredOut = $false
        if($GetItemsProperties.Sources.path -contains $globalDestination){
            $destinationFilteredOut = $true
            $GetItemsProperties.Sources = $GetItemsProperties.Sources | Where-Object {$_.path -ne $globalDestination}
        }

        if($GetItemsProperties.DeveloperOptions.FeedBack.Enable){
            if($destinationFilteredOut){
                $feedBack = "+- | {0}" -f "Removing destination address from source path(s)"
            }

            if(-not($destinationFilteredOut)){
                $feedBack = "+- | {0}" -f "Destination address not in source path(s)"
            }
            Write-Host $feedBack -ForegroundColor Yellow
        }

        
        # all sources should be reachable
        if($GetItemsProperties.DeveloperOptions.FeedBack.Enable){
            $feedBack = "+- | {0}" -f "Testing Sources are reachable"
            Write-Host $feedBack -ForegroundColor Yellow
        }
        foreach($source in $GetItemsProperties.Sources){
            if(-not(Test-Path -Path ($source['Path']))){
                $msgError = ("[{0}]:: {1}" -f "Source validation","Cannot find path '$(($source['Path']).Path)'")
                Write-Error $msgError -ErrorAction Stop
            }

            if($GetItemsProperties.DeveloperOptions.FeedBack.Enable){
                $feedBack = "|  +- {0} {1}" -f $source['Path'], "is reachable"
                Write-Host $feedBack -ForegroundColor Yellow
            }
        }

        if($GetItemsProperties.DeveloperOptions.FeedBack.Enable){
            $feedBack = "|"
            Write-Host $feedBack -ForegroundColor Yellow
            $feedBack   = "+- COMPLETE"
            Write-Host $feedBack -ForegroundColor Yellow
        }


   }
   process{
        foreach ($source in $GetItemsProperties.Sources){
            
            $path = $source.Path
            $items = Get-ChildItem -Path $path
  
            # Filter out specific items by full path
            if ($GetItemsProperties.Limit.Exclude.Enable) {
                $excludedPaths = $GetItemsProperties.Limit.Exclude.ExclusionList
                $items = $items | Where-Object { $excludedPaths -notcontains $_.FullName }
            }
    
            # Filter out items by extension type
            if ($GetItemsProperties.Limit.ItemType.Enable) {
                $extensionsList = $GetItemsProperties.Limit.ItemType.ExtensionsList
                $items = $items | Where-Object { $extensionsList -notcontains $_.Extension }
            }
    
            # Filter out items by size
            if ($GetItemsProperties.Limit.ItemSize.Enable) {
                $maxSize = $GetItemsProperties.Limit.ItemSize.Bytes
                $items = $items | Where-Object { $_.Length -lt $maxSize }
            }

            
            $logFileName = "CopyItemsLog-{0}-{1}.log"
            if($GetItemsProperties.Logging){
                $logFileName = $logFileName -f (split-path -path $path -Leaf),(Get-Date).ToString('yyyyMMdd_HHmmss')
                # test if the folder exits
                if(-not(Test-Path -Path $GetItemsProperties.Logging.Logpath)){
                    New-Item -path $GetItemsProperties.Logging.LogPath -ItemType Directory | Out-Null
                }
                if(-not(test-path -path (Join-Path -Path $GetItemsProperties.Logging.Logpath -ChildPath $logFileName))){
                    New-Item -path (Join-Path -Path $GetItemsProperties.Logging.Logpath -ChildPath $logFileName)-ItemType File | Out-Null
                }
                $logFilePath = Join-Path -Path $GetItemsProperties.Logging.Logpath -ChildPath $logFileName
            }  

            $sourceData = @{
                Folders = @()
                Files   = @()
                Properties = @{
                    TotalSizeBytes  = 0
                    TotalFiles      = 0
                    TotalFolders    = 0
                    TotalItems      = 0
                }
            }
    
            foreach ($item in $items) {
                if ($item.PSIsContainer) {
                    $parentitem = ($item | Select-Object -Property DirectoryName)
                    $sourceData.Folders += [pscustomobject]@{
                        FullName = $item.FullName
                        BaseName = $item.BaseName
                        ParentFolder = ($parentitem).DirectoryName 
                    }
                    $sourceData.Properties.TotalFolders++
                } else {
                    $parentitem = ($item | Select-Object -Property DirectoryName)
                    $sourceData.Files += [pscustomobject]@{
                        FullName = $item.FullName
                        BaseName = $item.BaseName
                        Extension = $item.Extension
                        LastWriteTime = $item.LastWriteTime
                        SizeBytes = $item.Length
                        ParentFolder =  ($parentitem).DirectoryName 
                    }
                    $sourceData.Properties.TotalSizeBytes += $item.Length
                    $sourceData.Properties.TotalFiles++
                }
            }

            $sourceData.Properties.TotalItems = $sourceData.Properties.TotalFolders + $sourceData.Properties.TotalFiles
            $source[$path] = $sourceData
    
            $feedBack = @(
                "+- | {0} - {1}" -f "Directory", $path
                "|"
                "+- | {0}" -f "Properties"
                "|  +- {0}: {1}" -f "Total bytes at this location",$sourceData.Properties.TotalSizeBytes
                "|  +- {0}: {1}" -f "Total folders at this location",$sourceData.Properties.TotalFolders
                "|  +- {0}: {1}" -f "Total files at this location",$sourceData.Properties.TotalFiles
                "|  |"
                "|  +- COMPLETE"
                "+- COMPLETE"
            )

            if ($GetItemsProperties.DeveloperOptions.FeedBack.Enable) {
                write-host ($feedBack -join "`n") -ForegroundColor cyan
            }
            if($GetItemsProperties.Logging.Enable){Add-Content -Value $feedBack -Path $logFilePath}
            if($GetItemsProperties.Logging.Enable){Add-Content -Value "`n" -Path $logFilePath}

            $totalBytesMoved = 0
 
            $newDestination = join-path $globalDestination (Split-Path  $source.path -leaf)
            write-host $newDestination -ForegroundColor Magenta
    
            foreach($dir in $source){
                $feedBack = @("Source: $($dir.Path)")
                foreach($file in $source.($source.Path).files ){
                    $childDestination   = join-path -path $globalDestination -ChildPath (Split-path $file.ParentFolder -Leaf)  

                    # if the child destination does not exits create it
                    if(-not(Test-Path -Path $childDestination)){

                        new-item -Path $childDestination -ItemType Directory | Out-Null
                        $feedBack += "Destination: $($globalDestination)"
                        $feedBack += "Created child destination: $($childDestination)"
                    }else{
                        $feedBack += "Child destination already exists - $($childDestination)"
                    }
                    if($GetItemsProperties.Logging.Enable){Add-Content -Value $feedBack -Path $logFilePath}
                }
                
                $totalFolderCreated = 0
                if($GetItemsProperties.Logging.Enable){Add-Content -Value "`n" -Path $logFilePath}
                foreach($childFolder in $dir.($dir.Path).Folders){
                    if(-not(test-path -Path (Join-Path $newDestination  -ChildPath $childFolder.BaseName))){
                        $feedBack = "Created child directory - $((Join-Path $newDestination -ChildPath $childFolder.BaseName))"
                        if($GetItemsProperties.Logging.Enable){Add-Content -Value $feedBack -Path $logFilePath}
                        Write-host "here -  $((Join-Path $newDestination -ChildPath $childFolder.BaseName))"
                        New-Item (Join-Path $newDestination -ChildPath $childFolder.BaseName) -ItemType Directory | Out-Null
                        $totalFolderCreated = $totalFolderCreated + 1
                    }else{
                        $feedBack = "Child directory already exists - $((Join-Path $newDestination -ChildPath $childFolder.BaseName)) "
                        if($GetItemsProperties.Logging.Enable){Add-Content -Value $feedBack -Path $logFilePath}
                        $totalFolderCreated = $totalFolderCreated + 1
                    }
                }
                
                if($GetItemsProperties.Logging.Enable){Add-Content -Value "`n" -Path $logFilePath}

                $totalItemsCopied  = 0
                foreach($childFile in $source.($source.Path).files){
                    $childDestination   = join-path -path $newDestination -childpath (Split-Path -path ($childFile.fullName) -leaf)

                    
                    Copy-Item -path $childFile.FullName -Destination $childDestination -ErrorAction Stop -Force

                    $totalItemsCopied = $totalItemsCopied + 1
                    if($GetItemsProperties.Progress.Enable){
                        if(($dir.($dir.path).Properties.TotalSizeBytes) -ne 0){
                            $percentComplete =  (($totalBytesMoved / $source[$path].Properties.TotalSizeBytes) * 100)
                            Write-Progress -Activity "Copy in progress; $($childFile.FullName)" -Status "$($percentComplete)% complete" -PercentComplete $percentComplete
                            Start-Sleep -Milliseconds $GetItemsProperties.Progress.updateInterval
                        }
                    }
                    $totalBytesMoved  = $totalBytesMoved  + $childFile.SizeBytes
                }
                $feedBack  = @("Total bytes copied: $($totalBytesMoved)")
                $feedBack  += "Total folders created/existed: $($totalFolderCreated)"
                $feedBack  += "Total items copied: $totalItemsCopied "
                if($GetItemsProperties.Logging.Enable){Add-Content -Value $feedBack -Path $logFilePath}
            }
            # Recursive call to process subdirectories
            foreach ($subdirectory in $sourceData.Folders) {
                $GetItemsProperties.Destination  = $newDestination
                $GetItemsProperties.Sources = @(@{ Path = $subdirectory.FullName })
                Get-Items -GetItemsProperties $GetItemsProperties
            }
        }
    }
}
Get-Items $GetItemsProperties


$GetItemsProperties = @{
    Sources = @(
        @{ Path = "C:\Users\abraham.hernandez\Documents\LocalRepo\stig-iis" }
    )

    Destination = "R:\"
    Limit = @{
        ItemSize = @{
            Enable = $false
            Bytes = 1000000000
        }
        ItemType = @{
            Enable = $false
            ExtensionsList = @(
                ".exe"
            )
        }
        Exclude = @{
            Enable = $true
            ExclusionList = @(
                "$env:USERPROFILE\Documents\LocalRepo\FileSync\test_destination"
            )
        }
    }
    DeveloperOptions = @{
        FeedBack = @{
            Enable = $true
        }
    }
    Logging = @{
        Enable = $true
        LogPath = "C:\Temp\Logs"
    }
    Progress = @{
        Enable = $true
        updateInterval = 500
    }
}


Get-Items $GetItemsProperties


