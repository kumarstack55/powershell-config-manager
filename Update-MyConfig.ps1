[CmdletBinding(SupportsShouldProcess)]
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

Set-StrictMode -Version Latest

$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Module.ps1"

$Config = Import-Config

if ($Secret -and $Config.ContainsKey($Name)) {
    throw "秘密でない名前 $Name が既に存在する"
}

$Name2 = $Name
$Value2 = $Value
if ($Secret) {
    $Name2 = Get-SecretKeyName -Name $Name
    $Value2 = Get-Base64EncodedString -DecodedString $Value
}

$Config[$Name2] = $Value2

Export-Config -Config $Config
