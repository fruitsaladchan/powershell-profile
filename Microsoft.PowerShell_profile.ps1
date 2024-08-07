# Aliases
Set-Alias -Name cat -Value bat
Set-Alias -Name df -Value Get-Volume
Set-Alias -Name ff -Value Find-File
Set-Alias grep rg
Set-Alias -Name l -Value Get-ChildItemPretty
Set-Alias -Name la -Value Get-ChildItemPretty
Set-Alias -Name ll -Value Get-ChildItemPretty
Set-Alias -Name ls -Value Get-ChildItemPretty
Set-Alias -Name rm -Value Remove-ItemExtended
Set-Alias -Name su -Value sudo
Set-Alias -Name touch -Value New-File
Set-Alias -Name us -Value Update-Software
Set-Alias -Name v -Value nvim
Set-Alias -Name vim -Value nvim
Set-Alias -Name neofetch fastfetch
Set-Alias np "C:\Program Files\Notepad++\notepad++.exe"
Set-Alias drive Get-PSDrive
Set-Alias shutdown Stop-Computer
Set-Alias reboot Restart-Computer

#Functions
function Update-Software {
    Write-Verbose "Updating software installed via Winget & Chocolatey"
    sudo cache on
    sudo winget upgrade --all --include-unknown --silent --verbose
    sudo choco upgrade all -y
    sudo -k
    $ENV:SOFTWARE_UPDATE_AVAILABLE = ""
}

function Find-File {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        [string]$SearchTerm
    )

    Write-Verbose "Searching for '$SearchTerm' in current directory and subdirectories"
    $result = Get-ChildItem -Recurse -Filter "*$SearchTerm*" -ErrorAction SilentlyContinue

    Write-Verbose "Outputting results to table"
    $result | Format-Table -AutoSize
}

function New-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    Write-Verbose "Creating new file '$Name'"
    New-Item -ItemType File -Name $Name -Path $PWD | Out-Null
}

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function Get-ChildItemPretty {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Path = $PWD
    )

    Write-Host ""
    eza -l --header --icons --hyperlink --time-style relative $Path
    Write-Host ""
}

function ipp { (Invoke-WebRequest http://ifconfig.me/ip).Content }

function reload {
    & $profile
}

function sysinfo { Get-ComputerInfo }

Function os { systeminfo }

function debloat { 
& ([scriptblock]::Create((irm "https://win11debloat.raphi.re/")))
}

function repair {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $newProcess = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"& { sfc /scannow }`"" -Verb RunAs -PassThru

        $newProcess.WaitForExit()
    } else {
        Write-Output "Running sfc /scannow..."
        sfc /scannow
    }
}

function bios {
  Get-CimInstance -ClassName Win32_Bios 
}

function Remove-ItemExtended {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$rf,
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )

    Write-Verbose "Removing item '$Path' $($rf ? 'and all its children' : '')"
    Remove-Item $Path -Recurse:$rf -Force:$rf
}

function winutil {
	iwr -useb https://christitus.com/win | iex
}

function admin {
    if ($args.Count -gt 0) {
        $argList = "& '$args'"
        Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb runAs
    }
}


function uptime {
    $uptime = Get-Uptime
    $days = $uptime.Days
    $hours = $uptime.Hours
    $minutes = $uptime.Minutes

    if ($days -gt 0) {
        Write-Output "Uptime: $days days, $hours hours, and $minutes minutes"
    }
    elseif ($hours -gt 0) {
        Write-Output "Uptime: $hours hours and $minutes minutes"
    }
    else {
        Write-Output "Uptime: $minutes minutes"
    }
}



# Environment Variables
$ENV:BAT_CONFIG_DIR = "$ENV:WindotsLocalRepo\bat"
$ENV:FZF_DEFAULT_OPTS = '--color=fg:-1,fg+:#ffffff,bg:-1,bg+:#3c4048 --color=hl:#5ea1ff,hl+:#5ef1ff,info:#ffbd5e,marker:#5eff6c --color=prompt:#ff5ef1,spinner:#bd5eff,pointer:#ff5ea0,header:#5eff6c --color=gutter:-1,border:#3c4048,scrollbar:#7b8496,label:#7b8496 --color=query:#ffffff --border="rounded" --border-label="" --preview-window="border-rounded" --height 40% --preview="bat -n --color=always {}"'

# Prompt Setup
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\catppuccin_mocha.omp.json" | Invoke-Expression
#Enable-TransientPrompt
Invoke-Expression (& { ( zoxide init powershell --cmd cd | Out-String ) })


Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineKeyHandler -Function AcceptSuggestion -Key Alt+l
Import-Module -Name CompletionPredictor

if ([Environment]::GetCommandLineArgs().Contains("-NonInteractive") -or [Environment]::GetCommandLineArgs().Contains("-CustomPipeName")) {
    return
}
fastfetch
