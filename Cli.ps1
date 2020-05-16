Set-StrictMode -Version Latest

$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Module.ps1"

Function Get-MyConfig {
    Param()

    $Config = Import-Config

    $Config2 = @{}
    $Config.GetEnumerator() |
        ForEach-Object {
            $Key = Get-KeyName($_.Key)
            $Value = $_.Value
            if ($Key -ne $_.Key) {
                $Value = "*"
            }
            $Config2[$Key] = $Value
        }

    $Config2
}

Function Get-MyConfigValue {
    Param(
        [Parameter(Mandatory)]
        $Name,

        [Parameter()]
        [Switch]
        $Clipboard
    )

    $Config = Import-Config

    $Secret = $false
    $NameSecret = Get-SecretKeyName -Name $Name
    if (-not $Config.ContainsKey($Name)) {
        if (-not $Config.ContainsKey($NameSecret)) {
            throw "Name $Name does not exist"
        } else  {
            $Secret = $true
        }
    }

    if ($Secret) {
        $Value = $Config[$NameSecret]
    } else {
        $Value = $Config[$Name]
    }

    if ($Clipboard) {
        if ($Secret) {
            $Value2 = Get-Base64DecodedString($Value)
        }
        Set-Clipboard $Value2
    } else {
        $Value
    }
}

Function Update-MyConfig {
    Param(
        [Parameter(mandatory)]
        [String]
        $Name,

        [Parameter(mandatory)]
        [String]
        $Value,

        [Parameter()]
        [Switch]
        $Secret
    )
    $Config = Import-Config

    if ($Secret -and $Config.ContainsKey($Name)) {
        throw "Not secret name $Name exists"
    }

    $Name2 = $Name
    $Value2 = $Value
    if ($Secret) {
        $Name2 = Get-SecretKeyName -Name $Name
        $Value2 = Get-Base64EncodedString -DecodedString $Value
    }

    $Config[$Name2] = $Value2

    Export-Config -Config $Config
}
