Function Get-HashtableFromPSCustomObject {
    Param([Parameter(Mandatory)]$PSCustomObject)
    $Hashable = @{}
    $PSCustomObject.psobject.properties |
        ForEach-Object { $Hashable[$_.Name] = $_.Value }
    return $Hashable
}

Function Get-ConfigDirectory {
    Param([Parameter()][String]$HomeDirectory = $HOME)
    $Dir1 = Join-Path $HomeDirectory ".config"
    $Dir2 = Join-Path $Dir1 "config-manager"
    return $Dir2
}

Function Get-ConfigFullName {
    Param([Parameter()][String]$HomeDirectory = $HOME)
    $Directory = Get-ConfigDirectory -HomeDirectory $HomeDirectory
    return Join-Path $Directory "config.json"
}

Function Get-NowIfDatetimeNull {
    Param($DateTime = $null)
    if ($DateTime -eq $null) {
        $DateTime = Get-Date
    }
    return $DateTime
}

Function Get-UnixEpoch {
    Param($DateTime = $null)
    $DateTime = Get-NowIfDatetimeNull -DateTime $DateTime
    $EpochZeroStr = "1970/1/1 0:0:0 GMT"
    $TimeSpan = ((Get-Date($DateTime)) - (Get-Date($EpochZeroStr)))
    return [int]$TimeSpan.TotalSeconds
}

Function Get-BackupPostfix {
    Param($DateTime = $null)
    $DateTime = Get-NowIfDatetimeNull -DateTime $DateTime
    $Ymd = Get-Date $DateTime -Format "yyyy-MM-dd"
    $UnixEpoch = Get-UnixEpoch $DateTime
    return "-${Ymd}.${UnixEpoch}"
}

Function Get-ConfigBackupPath {
    Param(
        [Parameter()]
        [String]
        $HomeDirectory = $HOME,

        [Parameter()]
        $DateTime = $null
    )
    $DateTime = Get-NowIfDatetimeNull -DateTime $DateTime
    $Path = Get-ConfigFullName -HomeDirectory $HomeDirectory
    $Directory = Split-Path -Parent $Path
    $BaseName = [io.path]::GetFileNameWithoutExtension($Path) + `
        (Get-BackupPostfix -DateTime $DateTime)
    $Extension = [io.path]::GetExtension($Path)
    $Name = $BaseName + $Extension
    return Join-Path $Directory $Name
}

Function New-Config {
    Param([Parameter()][String]$HomeDirectory = $HOME)

    $Directory = Get-ConfigDirectory -HomeDirectory $HomeDirectory
    New-Item -Force -ItemType Container $Directory

    $ConfigFullName = Get-ConfigFullName -HomeDirectory $HomeDirectory
    if ($PSCmdlet.ShouldProcess('Config', 'エクスポートする')) {
        if (Test-Path -PathType Leaf $ConfigFullName) {
            throw "すでにファイル $ConfigFullName が存在する"
        }
        "{}" | Out-File $ConfigFullName
    }
}

Function Import-Config {
    Param([Parameter()][String]$HomeDirectory = $HOME)
    $ConfigFullName = Get-ConfigFullName -HomeDirectory $HomeDirectory
    $ConfigPso = Get-Content $ConfigFullName |
        ConvertFrom-JSON
    $Hashable = Get-HashtableFromPSCustomObject -PSCustomObject $ConfigPso
    return $Hashable
}

Function Export-Config {
    Param(
        [Parameter(Mandatory)]
        $Config,

        [Parameter()]
        [String]
        $HomeDirectory = $HOME,

        [Parameter()]
        $DateTime = $null
    )
    $DateTime = Get-NowIfDatetimeNull -DateTime $DateTime

    $ConfigFullName = Get-ConfigFullName -HomeDirectory $HomeDirectory
    if ($PSCmdlet.ShouldProcess('Config', 'エクスポートする')) {
        if (Test-Path -PathType Leaf $ConfigFullName) {
            $ConfigBackupPath = Get-ConfigBackupPath `
                -HomeDirectory $HomeDirectory -DateTime $DateTime
            Copy-Item -Force $ConfigFullName $ConfigBackupPath
        }
        $Config |
            Sort-Object -Property Key |
            ConvertTo-JSON -Depth 100 |
            Out-File $ConfigFullName
    }
}

Function Get-Base64EncodedString {
    Param(
        [Parameter(mandatory)]
        [String]
        $DecodedString
    )
    return [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($DecodedString))
}

Function Get-Base64DecodedString {
    Param(
        [Parameter(mandatory)]
        [String]
        $EncodedString
    )
    return [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($EncodedString))
}

Function Get-SecretKeyName {
    Param(
        [Parameter(mandatory)]
        [String]
        $Name
    )
    return "${Name}_base64"
}

Function Get-KeyName {
    Param(
        [Parameter(mandatory)]
        [String]
        $Name
    )
    if ($Name -cmatch "^(.+)_base64$") {
        return $Matches[1]
    }
    return $Name
}

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
