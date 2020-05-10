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
Describe "New-Config" {
    It "creates directory if directory .config not exists" {
        $HomeDirectory = Join-Path $TestDrive "new-config1"
        New-Config -HomeDirectory $HomeDirectory
        Test-Path "$HomeDirectory\.config\config-manager\config.json" |
            Should Be $True
    }
    It "doesn't exit if directory exists" {
        $HomeDirectory = Join-Path $TestDrive "new-config2"
        New-Item -ItemType Container $HomeDirectory\.config\config-manager
        New-Config -HomeDirectory $HomeDirectory
        Test-Path "$HomeDirectory\.config\config-manager\config.json" |
            Should Be $True
    }
    It "creates config.json that contains empty object" {
        $HomeDirectory = Join-Path $TestDrive "new-config3"
        New-Item -ItemType Container $HomeDirectory\.config\config-manager
        New-Config -HomeDirectory $HomeDirectory
        Get-Content "$HomeDirectory\.config\config-manager\config.json" |
            Should Be "{}"
    }
    It "doesn't overwrite" {
        $HomeDirectory = Join-Path $TestDrive "new-config4"
        New-Item -ItemType Container $HomeDirectory\.config\config-manager
        New-Item $HomeDirectory\.config\config-manager\config.json
        try {
            New-Config -HomeDirectory $HomeDirectory
            $false | Should Be $true
        } catch {
            $true | Should Be $true
        }
    }
}
Describe "Import-Config" {
    It "returns hashtable" {
        $HomeDirectory = Join-Path $TestDrive "import-config1"
        New-Item -ItemType Container $HomeDirectory\.config\config-manager
        '{"k":"v"}' |
            Out-File $HomeDirectory\.config\config-manager\config.json
        $Config = Import-Config -HomeDirectory $HomeDirectory
        $Config.GetType().Name | Should Be "Hashtable"
    }
    It "returns key value pairs" {
        $HomeDirectory = Join-Path $TestDrive "import-config2"
        New-Item -ItemType Container $HomeDirectory\.config\config-manager
        '{"k":"v"}' |
            Out-File $HomeDirectory\.config\config-manager\config.json
        $Config = Import-Config -HomeDirectory $HomeDirectory
        $Config["k"] | Should Be "v"
    }
}
Describe "Export-Config" {
    It "copies old config.json to backup file" {
        $HomeDirectory = Join-Path $TestDrive "export-config1"

        New-Item -ItemType Container $HomeDirectory\.config\config-manager
        '{"k1":"v1"}' |
            Out-File $HomeDirectory\.config\config-manager\config.json

        $Config = @{"k1"="v2"}

        $EpochZeroStr = "1970/1/1 0:0:0 GMT"
        $DateTime = Get-Date $EpochZeroStr

        Export-Config -Config $Config -HomeDirectory $HomeDirectory -DateTime $DateTime

        $BackupPath = Get-ConfigBackupPath `
            -HomeDirectory $HomeDirectory -DateTime $DateTime

        $o = Get-Content $BackupPath |
            ConvertFrom-JSON
        $ConfigOld = Get-HashtableFromPSCustomObject $o
        $ConfigOld["k1"] | Should Be "v1"
    }
    It "writes config.json" {
        $HomeDirectory = Join-Path $TestDrive "export-config2"

        New-Item -ItemType Container $HomeDirectory\.config\config-manager
        '{"k1":"v1"}' |
            Out-File $HomeDirectory\.config\config-manager\config.json

        $Config = @{"k1"="v2"}

        Export-Config -Config $Config -HomeDirectory $HomeDirectory

        $Config2 = Import-Config $HomeDirectory

        $Config2["k1"] | Should Be "v2"
    }
}
Describe "Get-Base64EncodedString" {
    It "returns base64 encoded string" {
        Get-Base64EncodedString "a" | Should Be "YQ=="
    }
}
Describe "Get-Base64DecodedString" {
    It "does something useful" {
        Get-Base64DecodedString "YQ==" | Should Be "a"
    }
}
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
