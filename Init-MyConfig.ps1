[CmdletBinding(SupportsShouldProcess)]
Param()

Set-StrictMode -Version Latest

$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Client.ps1"

New-Config
