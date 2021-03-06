﻿[CmdletBinding(SupportsShouldProcess)]
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
. "$here\Cli.ps1"

if ($Clipboard) {
    Get-MyConfigValue -Name $Name -Clipboard
} else {
    Get-MyConfigValue -Name $Name
}
