# server-config-scripts

# Server Configuration Collector

A PowerShell script for automated collection and reporting of Windows server configurations across your infrastructure.

## Description

This script automates the collection of critical server configuration data from multiple Windows servers in your environment. It reads server names from a text file and gathers detailed information about each server's hardware, operating system, memory, CPU, and storage configurations.

## Features

- Collects comprehensive server information including:
  - Operating System details
  - RAM usage and availability
  - CPU configuration (physical CPUs, cores, logical processors)
  - Drive space and utilization
  - System uptime (last boot time)
- Exports data to CSV files for further analysis
- Error handling for unreachable servers
- Real-time console output of collection progress
- Generates two separate reports:
  - Complete server inventory
  - Detailed drive space analysis

## Prerequisites

- Windows PowerShell 5.1 or later
- Administrative access to target servers
- WinRM enabled on target servers
- Appropriate network connectivity to target servers

## Setup

1. Create a text file named `DatabaseServerList.txt` in the same directory as the script
2. Add the server names to the text file, one per line:
   ```
   server1
   server2
   server3
   ```

## Usage

1. Open PowerShell with administrative privileges
2. Navigate to the script directory
3. Run the script:
   ```powershell
   .\get_server_config.ps1
   ```

## Output

The script generates two CSV files:

1. `ServerInventory_YYYYMMDD.csv`: Complete server configuration data
2. `DriveInventory_YYYYMMDD.csv`: Detailed drive space information

The date suffix in the filename is automatically generated based on the execution date.

## Output Fields

### Server Inventory
- ServerName
- OperatingSystem
- TotalRAMGB
- FreeRAMGB
- CPUCount
- CoreCount
- LogicalProcessors
- LastBootTime
- Timestamp

### Drive Inventory
- ServerName
- DriveLetter
- Label
- TotalSizeGB
- FreeSpaceGB
- PercentFree

## Error Handling

The script includes error handling for common issues:
- Unreachable servers
- Permission issues
- WinRM connectivity problems

Errors are displayed in red text in the console output and the script continues processing the remaining servers.
