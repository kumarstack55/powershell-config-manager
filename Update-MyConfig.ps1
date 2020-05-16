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
. "$here\Client.ps1"

if ($Secret) {
    Update-MyConfig -Name $Name -Value $Value -Secret
} else {
    Update-MyConfig -Name $Name -Value $Value
}
