# powershell-config-manager

## Introduction

It is a simple tool to manage configuration information such as development environment.
The passwords are encoded so that it cannot be instantly recognized even if it is displayed on the display.
This tool is not suitable for the purpose of managing important confidential information.

## Installation

```ps1
cd $HOME
git clone https://github.com/kumarstack55/powershell-config-manager
```

## Usage

```ps1
cd $HOME/powershell-config-manager

# Initialize
.\Init-MyConfig.ps1

# List key-value pairs
.\Get-MyConfig.ps1

# Show value
.\Get-MyConfigValue.ps1 -Name env1_username

# Copy value to clipboard
.\Get-MyConfigValue.ps1 -Name env1_username -Clipboard

# Update value
.\Update-MyConfig.ps1 -Name env1_username -Value testuser1
.\Update-MyConfig.ps1 -Name env1_password -Value s3cret! -Secret
```