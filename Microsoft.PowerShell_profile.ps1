Set-Alias np "C:\Program Files\Notepad++\notepad++.exe"
Set-Alias grep rg
Set-Alias cat bat
Set-Alias neofetch neofetch.exe
Set-Alias reboot Restart-computer
Set-Alias shutdown Stop-computer
Set-Alias ip ipconfig
oh-my-posh init pwsh --config 'C:\Users\lain\AppData\Local\Programs\oh-my-posh\themes\catppuccin_mocha.omp.json' | Invoke-Expression
function ipp { (Invoke-WebRequest http://ifconfig.me/ip).Content }


function uptime {
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        Get-WmiObject win32_operatingsystem | Select-Object @{Name='LastBootUpTime'; Expression={$_.ConverttoDateTime($_.lastbootuptime)}} | Format-Table -HideTableHeaders
    } else {
        net statistics workstation | Select-String "since" | ForEach-Object { $_.ToString().Replace('Statistics since ', '') }
    }
}

function df {
    get-volume
}

function sysinfo { Get-ComputerInfo }

function admin {
    if ($args.Count -gt 0) {
        $argList = "& '$args'"
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb runAs
    }
}

Set-Alias -Name su -Value admin

function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize }

function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function touch($file) { "" | Out-File $file -Encoding ASCII }
function ff($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output "$($_.FullName)"
    }
}

# Quick File Creation
function nf { param($name) New-Item -ItemType "file" -Path . -Name $name }

# Directory Management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }

function doc { Set-Location -Path $HOME\Documents }

function pic { Set-Location -Path $HOME\Pictures }

function desk { Set-Location -Path $HOME\Desktop }

function down { Set-Location -Path $HOME\Downloads }

function help {
    @"
PowerShell Profile Help
=======================
• ipp - Retrieves the public IP address of the machine.

• uptime - Displays the system uptime.

• unzip <file> - Extracts a zip file to the current directory.

• grep <regex> [dir] - Searches for a regex pattern in files within the specified directory or from the pipeline input.

• df - Displays information about volumes.

• touch <file> - Creates a new empty file.

• nf <name> - Creates a new file with the specified name.

• mkcd <dir> - Creates and changes to a new directory.

• docs - Changes the current directory to the user's Documents folder.

• desk - Changes the current directory to the user's Desktop folder.

• la - Lists all files in the current directory with detailed formatting.

• sysinfo - Displays detailed system information.

• ll - Lists all files, including hidden, in the current directory with detailed formatting.
"@
}

Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })