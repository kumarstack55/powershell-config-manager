$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-HashtableFromPSCustomObject" {
    It "returns hashtable" {
        $o = New-Object PSCustomObject
        $h = Get-HashtableFromPSCustomObject -PSCustomObject $o
        $h.GetType().Name | Should Be 'Hashtable'
    }
    It "returns key-value pairs" {
        $o = New-Object PSCustomObject
        $o | Add-Member -MemberType NoteProperty -Name "key1" -Value "value1"
        $o | Add-Member -MemberType NoteProperty -Name "key2" -Value "value2"
        $h = Get-HashtableFromPSCustomObject -PSCustomObject $o
        $h['key1'] | Should Be 'value1'
        $h['key2'] | Should Be 'value2'
    }
}
# Describe "Get-ConfigDirectory" {
#     It "does something useful" {
#         $true | Should Be $false
#     }
# }
# Describe "Get-ConfigFullName" {
#     It "does something useful" {
#         $true | Should Be $false
#     }
# }
# Describe "Get-UnixEpoch" {
#     It "does something useful" {
#         $true | Should Be $false
#     }
# }
# Describe "Get-BackupPostfix" {
#     It "does something useful" {
#         $true | Should Be $false
#     }
# }
# Describe "Get-ConfigBackupPath" {
#     It "does something useful" {
#         $true | Should Be $false
#     }
# }
# Describe "New-Config" {
#     It "does something useful" {
#         $true | Should Be $false
#     }
# }
# Describe "Import-Config" {
#     It "does something useful" {
#         $true | Should Be $false
#     }
# }
# Describe "Export-Config" {
#     It "does something useful" {
#         $true | Should Be $false
#     }
# }
# Describe "Get-Base64EncodedString" {
#     It "does something useful" {
#         $true | Should Be $false
#     }
# }
# Describe "Get-Base64DecodedString" {
#     It "does something useful" {
#         $true | Should Be $false
#     }
# }
# Describe "Get-SecretKeyName" {
#     It "does something useful" {
#         $true | Should Be $false
#     }
# }
# Describe "Get-KeyName" {
#     It "does something useful" {
#         $true | Should Be $false
#     }
# }
