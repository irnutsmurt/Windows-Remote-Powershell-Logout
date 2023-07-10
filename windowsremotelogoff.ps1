# Set the path of the list.txt file
$listFile = Join-Path -Path $PSScriptRoot -ChildPath "list.txt"
$logFile = Join-Path -Path $PSScriptRoot -ChildPath "RemoteLogoutLog.txt"

Start-Transcript -Path $logFile -Append -NoClobber

function MainMenu {
    Clear-Host
    Write-Host "Main Menu:"
    Write-Host "1. Check active logins on a Windows server."
    Write-Host "2. Use `list.txt` to remotely logout a specific user."
    Write-Host "0. Exit script."
    $option = Read-Host "Select an option (Enter the number)"

    switch ($option) {
        "1" { CheckActiveLogins }
        "2" { LogoutWithList }
        "0" { return }
        default { Write-Host "Invalid option. Try again."; MainMenu }
    }
}

function CheckActiveLogins {
    $server = Read-Host "Enter the server name"
    $activeUsers = query user /server:$server 2>&1
    if($activeUsers -is [System.Management.Automation.ErrorRecord]) {
        Write-Host "Cannot reach server $server"
        MainMenu
    } elseif ($activeUsers -eq $null) {
        Write-Host "No active users found."
        MainMenu
    }

    Write-Host "Active Users:"
    $activeUsers | ForEach-Object { Write-Host $_ }

    Write-Host "`n1. Remotely logout a specific user."
    Write-Host "2. Return to main menu."
    Write-Host "0. Exit the script."
    $option = Read-Host "Select an option (Enter the number)"

    switch ($option) {
        "1" { LogoutUser -Server $server -ActiveUsers $activeUsers }
        "2" { MainMenu }
        "0" { return }
        default { Write-Host "Invalid option. Try again."; CheckActiveLogins }
    }
}

function LogoutUser {
    param (
        [Parameter(Mandatory=$true)] $Server,
        [Parameter(Mandatory=$true)] $ActiveUsers
    )

    # Creating the user list for selection
    $users = $ActiveUsers | Select-Object -Skip 1
    $i = 1
    $userList = @()
    foreach ($user in $users) {
        $userName = ($user -split "\s+")[1]
        $userList += "{0}. {1}" -f $i++, $userName
    }

    $userList += "{0}. Logout all users" -f $i++
    $userList += "{0}. Return to main menu" -f $i++

    Write-Host "`nUser list:"
    $userList | ForEach-Object { Write-Host $_ }

    $selected = Read-Host "Select a user to log out (Enter the number)"

    if ($selected -eq ($i - 2)) {
        $confirm = Read-Host "Are you sure you want to log out all users? (yes/no)"
        if ($confirm -eq "yes") {
            $users | ForEach-Object {
                $id = ($_ -split "\s+")[2]
                logoff $id /server:$Server
            }
        }
    } elseif ($selected -eq ($i - 1)) {
        MainMenu
    } else {
        $username = ($userList[$selected - 1] -split "\s+")[1]
        $selectedUserLine = $users | Where-Object { $_ -match $username }
        $id = ($selectedUserLine -split "\s+")[2]
        logoff $id /server:$Server
        Write-Host "Logged out $username"
    }

    MainMenu
}

function LogoutWithList {
    $username = Read-Host "Enter the username"

    $servers = Get-Content -Path $listFile
    $foundServers = @()

    foreach ($server in $servers) {
        if(-not (Test-Connection -ComputerName $server -Count 1 -Quiet)) {
            Write-Host "Cannot reach server $server"
            continue
        }

        try {
            $activeUsers = query user /server:$server 2>$null
            if ($activeUsers -match $username) {
                $foundServers += $server
            } else {
                Write-Host "The user $username is not currently logged in on $server."
            }
        } catch {
            Write-Host "Failed to retrieve the list of active users on ${server}: $_"
        }
    }

    if ($foundServers) {
        Write-Host "The user $username is logged in on the following servers:"
        $foundServers | ForEach-Object { Write-Host $_ }

        $confirm = Read-Host "Do you want to log out the user from these servers? (yes/no)"
        if ($confirm -eq "yes") {
            foreach ($server in $foundServers) {
                try {
                    $userLine = (query user /server:$server 2>$null) | Where-Object { $_ -match $username }
                    $id = ($userLine -split "\s+")[2]
                    logoff $id /server:$server
                    Write-Host "Logged out $username from $server"
                } catch {
                    Write-Host "Failed to log out ${username} from ${server}: $_"
                }
            }
        }
    } else {
        Write-Host "The user $username was not found on any server in the list."
    }

    MainMenu
}

# Call the main function
MainMenu

Stop-Transcript
