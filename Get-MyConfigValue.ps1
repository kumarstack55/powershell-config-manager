[CmdletBinding(SupportsShouldProcess)]
Param(
    [Parameter(Mandatory)]
    $Name,

    [Parameter()]
    [Switch]
    $Clipboard
)

Set-StrictMode -Version Latest

$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Module.ps1"

$Config = Import-Config

$Secret = $false
$NameSecret = Get-SecretKeyName -Name $Name
if (-not $Config.ContainsKey($Name)) {
    if (-not $Config.ContainsKey($NameSecret)) {
        throw "名前 $Name が存在しない"
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
