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
Describe "Get-ConfigDirectory" {
    It "returns config directory" {
        $Dir = Join-Path $TestDrive "Container"
        Get-ConfigDirectory -HomeDirectory $Dir |
            Should Be "$Dir\.config\config-manager"
    }
}
Describe "Get-ConfigFullName" {
    It "returns config full name" {
        $Dir = Join-Path $TestDrive "Container"
        Get-ConfigFullName -HomeDirectory $Dir |
            Should Be "$Dir\.config\config-manager\config.json"
    }
}
Describe "Get-UnixEpoch" {
    It "returns zero when unix epoch is given" {
        $EpochZeroStr = "1970/1/1 0:0:0 GMT"
        $DateTime = Get-Date $EpochZeroStr
        Get-UnixEpoch -DateTime $DateTime |
            Should Be 0
    }
    It "returns positive number when time larger than unix epoch is given" {
        $Str = "1970/1/1 0:0:1 GMT"
        $DateTime = Get-Date $Str
        Get-UnixEpoch -DateTime $DateTime |
            Should Be 1
    }
}
Describe "Get-BackupPostfix" {
    It "returns backup postfix" {
        $EpochZeroStr = "1970/1/1 0:0:0 GMT"
        $DateTime = Get-Date $EpochZeroStr
        Get-BackupPostfix -DateTime $DateTime |
            Should Be "-1970-01-01.0"
    }
}
Describe "Get-ConfigBackupPath" {
    It "returns config backup path" {
        $EpochZeroStr = "1970/1/1 0:0:0 GMT"
        $DateTime = Get-Date $EpochZeroStr
        $HomeDirectory = Join-Path $TestDrive "home"
        Get-ConfigBackupPath -HomeDirectory $HomeDirectory -DateTime $DateTime |
            Should Be "$TestDrive\home\.config\config-manager\config-1970-01-01.0.json"
    }
}
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
