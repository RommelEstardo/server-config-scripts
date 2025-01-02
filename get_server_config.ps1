# Read server list
$servers = Get-Content "DatabaseServerList.txt"
$results = @()

foreach ($server in $servers) {
    try {
        Write-Host "Processing server: $server"

        # Get server information using CIM
        $computerSystem = Get-CimInstance -ComputerName $server -ClassName Win32_ComputerSystem
        $operatingSystem = Get-CimInstance -ComputerName $server -ClassName Win32_OperatingSystem
        $processors = Get-CimInstance -ComputerName $server -ClassName Win32_Processor
        $drives = Get-CimInstance -ComputerName $server -ClassName Win32_LogicalDisk -Filter "DriveType = 3"

        # Calculate total and free memory
        $totalRAMGB = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
        $freeRAMGB = [math]::Round($operatingSystem.FreePhysicalMemory / 1MB, 2)

        # Get CPU information
        $cpuCount = $processors.Count
        $coreCount = ($processors | Measure-Object -Property NumberOfCores -Sum).Sum
        $logicalProcessors = ($processors | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum

        # Format drive information
        $driveInfo = $drives | ForEach-Object {
            [PSCustomObject]@{
                DriveLetter = $_.DeviceID
                Label = $_.VolumeName
                TotalSizeGB = [math]::Round($_.Size / 1GB, 2)
                FreeSpaceGB = [math]::Round($_.FreeSpace / 1GB, 2)
                PercentFree = [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
            }
        }

        # Create result object
        $serverInfo = [PSCustomObject]@{
            ServerName = $server
            OperatingSystem = $operatingSystem.Caption
            TotalRAMGB = $totalRAMGB
            FreeRAMGB = $freeRAMGB
            CPUCount = $cpuCount
            CoreCount = $coreCount
            LogicalProcessors = $logicalProcessors
            Drives = $driveInfo
            LastBootTime = $operatingSystem.LastBootUpTime
            Timestamp = Get-Date
        }

        $results += $serverInfo

        # Output to console
        Write-Host "Server: $server"
        Write-Host "OS: $($serverInfo.OperatingSystem)"
        Write-Host "RAM: $($serverInfo.TotalRAMGB)GB (Free: $($serverInfo.FreeRAMGB)GB)"
        Write-Host "CPU: $($serverInfo.CPUCount) CPU(s), $($serverInfo.CoreCount) Cores, $($serverInfo.LogicalProcessors) Logical Processors"
        Write-Host "Drives:"
        $serverInfo.Drives | Format-Table -AutoSize
        Write-Host "Last Boot Time: $($serverInfo.LastBootTime)"
        Write-Host "-----------------------------------------"
    
    } catch {
        Write-Host "Error processing server $server : $_" -ForegroundColor Red
    }
}

# Export results to CSV
$results | Export-Csv -Path "ServerInventory_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation

# Export detailed drive information
$driveDetails = $results | ForEach_Object {
    $_.Drives | Select-Object @{N='ServerName';E={$_.ServerName}}, *
}
$driveDetails | Export-Csv -Path "DriveInventory_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation