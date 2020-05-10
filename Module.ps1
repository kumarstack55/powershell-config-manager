Function Get-HashtableFromPSCustomObject {
    Param([Parameter(Mandatory)]$PSCustomObject)
    $Hashable = @{}
    $PSCustomObject.psobject.properties |
        ForEach-Object { $Hashable[$_.Name] = $_.Value }
    return $Hashable
}

Function Get-ConfigDirectory {
    Param([Parameter()][String]$HomeDirectory)
    if ($HomeDirectory -eq $null) {
        $HomeDirectory = $HOME
    }
    $Dir1 = Join-Path $HomeDirectory ".config"
    $Dir2 = Join-Path $Dir1 "config-manager"
    return $Dir2
}

Function Get-ConfigFullName {
    Param()
    $Directory = Get-ConfigDirectory
    return Join-Path $Directory "config.json"
}

Function Get-UnixEpoch {
    Param($DateTime = $null)
    if ($DateTime -eq $null) {
        $DateTime = Get-Date
    }
    $EpochZeroStr = "1970/1/1 0:0:0 GMT"
    $TimeSpan = ((Get-Date($DateTime)) - (Get-Date($EpochZeroStr)))
    return [int]$TimeSpan.TotalSeconds
}

Function Get-BackupPostfix {
    Param($DateTime = $null)
    if ($DateTime -eq $null) {
        $DateTime = Get-Date
    }
    $Ymd = Get-Date $DateTime -Format "yyyy-mm-dd"
    $UnixEpoch = Get-UnixEpoch $DateTime
    return "-${Ymd}-${UnixEpoch}"
}

Function Get-ConfigBackupPath {
    Param()
    $Path = Get-ConfigFullName
    $Item = Get-Item $Path
    $BaseName = $Item.BaseName + (Get-BackupPostfix)
    $Name = $BaseName + $Item.Extension
    return Join-Path $Item.Directory.FullName $Name
}

Function New-Config {
    Param()

    $Directory = Get-ConfigDirectory
    New-Item -ItemType Container $Directory

    $ConfigFullName = Get-ConfigFullName
    if ($PSCmdlet.ShouldProcess('Config', 'エクスポートする')) {
        if (Test-Path -PathType Leaf $ConfigFullName) {
            throw "すでにファイル $ConfigFullName が存在する"
        }
        "{}" | Out-File $ConfigFullName
    }
}

Function Import-Config {
    Param()
    $ConfigFullName = Get-ConfigFullName
    $ConfigPso = Get-Content $ConfigFullName |
        ConvertFrom-JSON
    $Hashable = Get-HashtableFromPSCustomObject -PSCustomObject $ConfigPso
    return $Hashable
}

Function Export-Config {
    Param([Parameter(Mandatory)]$Config)
    $ConfigFullName = Get-ConfigFullName
    if ($PSCmdlet.ShouldProcess('Config', 'エクスポートする')) {
        if (Test-Path -PathType Leaf $ConfigFullName) {
            $ConfigBackupPath = Get-ConfigBackupPath
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
