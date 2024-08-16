
Function New-UDFScrubbedFile {
    param([hashtable]$fromSender)

    if($fromSender.EnabledFeedBack){
        $msg = "Reading from sources..."
        Write-Host $msg -ForegroundColor Cyan
    }
    foreach($source in $fromSender.Sources){
        if($fromSender.EnabledFeedBack){
            $msg = "Reading from source '{0}'" -f $source.Path
            Write-Host $msg
        }
        $content = switch($source.Format){
            'evtx'{
                Get-WinEvent -Path $source.Path
            }
            default{
                $msg = "Source format '{0}' is not supported" -f $source.Format
                Write-Error $msg; return $Error[0]
            }
        }
        if($source.Format -eq 'evtx'){
            if($fromSender.EnabledFeedBack){
                $msg = "Source contained '{0}' entries" -f $content.count
                Write-Host $msg -ForegroundColor Cyan
            }
            $scrubbed   = @()
            $cntr       = 1
            foreach($item in $content){
                $myMsg = @()
                Foreach($line in $item.message){
                    $myLine = $line
                    foreach($pattern in $fromSender.Patterns.Keys){
                        if($myLine -match $fromSender.Patterns.$pattern.LookFor){
                            if($fromSender.EnabledFeedBack){
                                $msg = "Entry No.{0} matched '{1}' pattern, replacing with '{2}'" -f $cntr,$fromSender.Patterns.$pattern.Replace,$fromSender.Patterns.$pattern.with
                                Write-Host $msg -ForegroundColor Cyan
                            }
        
                            $myLine = $myLine -replace (
                                "$($fromSender.Patterns.$pattern.Replace)",
                                "$($fromSender.Patterns.$pattern.With)"
                            )
                        }
                    }
                    $myMsg += $myLine
                }
                $newMessage = $myMsg -join ' '
                $scrubbed += [pscustomobject]@{
                    TimeCreated     = $item.TimeCreated
                    LogName         = $item.LogName
                    ProviderName    = $item.ProviderName
                    ID              = $item.ID
                    Message         = $newMessage
                }
                $cntr = $cntr + 1
            }
        }

        $outputFilePath = switch($source.ExportAs){
            'csv'{
                if($fromSender.EnabledFeedBack){
                    $msg = "Converting to '{0}'" -f $source.ExportAs
                    Write-Host $msg -ForegroundColor Cyan
                }
                "{0}.{1}" -f $source.ExportFilePath,$source.ExportAs
            }
            default{
                $msg = "Export type '{0}' is not supported" -f $source.ExportAs
            }
        }


        if(Test-Path -Path $outputFilePath){
            if($fromSender.EnabledFeedBack){
                $msg = "Removing old parsed file located at '{0}'" -f $outputFilePath
                Write-Host $msg -ForegroundColor Cyan
            }
            Remove-Item -Path $outputFilePath
        }

        if($fromSender.EnabledFeedBack){
            $msg = "Creating new parsed file at '{0}'" -f $outputFilePath
            Write-Host $msg -ForegroundColor Cyan
        }

        New-Item -Path $outputFilePath -ItemType "File" | Out-Null
        
        $csv = ($scrubbed | ConvertTo-Csv -NoTypeInformation)

        if($fromSender.EnabledFeedBack){
            $msg = "Outputting content"
            Write-Host $msg -ForegroundColor Cyan
        }
        Set-Content -Path $outputFilePath -Value $csv
    }
}

# Description:  Function parses one or more .evtx file(s) for a list of provided patterns.
#               In the example a hashtable of 2 patterns are provide, IP and URL
#               LookFor value is the pattern to look for.
#               Replace value is the string to replace that matches the pattern provided.
#               With value is the string that will be used to replace the matched pattern.
#               EnabledFeedBack will provide output to console of what the function is doing at that moment.
#               Sources is where you specify the list of sources. One or more .evtx files can be supplied.
# Note:         You can provide your own patterns to look for in the .evtx file(s).
#               Can only output to csv and can only parse .evtx files.


# to generate an .evtx file, you can run the follwing
# wevtutil epl System %computername%_system.evtx
New-UDFScrubbedFile @{
    EnabledFeedBack = $true
    Patterns = @{
        IP = @{
            LookFor = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
            Replace = '10.1'
            With    = 'X.X'
        }
        URL = @{
            LookFor = 'devlab.com'
            Replace = 'devlab.com'
            With    = 'XXX'
        }
    }
    Sources = @(
        @{
            Path            = ".\DEV-SQL11_system.evtx"
            Format          = "evtx"
            ExportFilePath  = ".\DEV-SQL11_system"
            ExportAs        = "csv"
        }
        @{
            Path            = ".\DEV-SQL11_app.evtx"
            Format          = "evtx"
            ExportFilePath  = ".\DEV-SQL11_app"
            ExportAs        = "csv"
        }
    )
}
