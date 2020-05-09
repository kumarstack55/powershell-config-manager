[CmdletBinding(SupportsShouldProcess)]
Param()

Set-StrictMode -Version Latest

$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Module.ps1"

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
