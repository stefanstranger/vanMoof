# VanMoof

Repository with PowerShell REST API call to the vanMoof REST API to get your user data saved locally.

Recently E-bike startup VanMoof has applied to a local court for an official suspension of payment provision after running out of money.

[Van-oof! E-bike startup VanMoof, unable to pay bills, files for payment deferment in Holland](https://techcrunch.com/2023/07/12/report-vanmoof-has-filed-for-bankruptcy-protection-in-holland/)

And now there are some projects that suggest you need to export your VanMoof encryption key before their servers would go offline.

One of these projects is called [vanmoof-encryption-key-exporter](https://github.com/grossartig/vanmoof-encryption-key-exporter)

Instead of using the tool you can do the same with some simple PowerShell REST API calls:

## PowerShell script

```PowerShell
<#
.DESCRIPTION
    Download the VanMoof data for the user and save it to a file.

.PARAMETER UserName [String]
    The username to use for authentication to the VanMoof API.

.PARAMETER Password [SecureString]
    The password to use for authentication to the VanMoof API.

.PARAMETER FilePath [String]
    The path to the folder where the data should be saved.

.EXAMPLE
    Get-VanMoofData -UserName 'john.doe@outlook.com' -Password ******** -FilePath 'C:\Temp'
#>

[CmdLetBinding()]
Param (
    [Parameter (Mandatory = $true)]
    [String] $UserName,

    [Parameter (Mandatory = $true)]
    [SecureString]$Password,

    [Parameter (Mandatory = $true)]
    [String] $FilePath
)

#region variables
$apiKey = 'fcb38d47-f14b-30cf-843b-26283f6a5819'
$uriPrefix = 'https://my.vanmoof.com/api/v8'

#endregion

#region Get Access Token
$headers = @{
    Authorization = ('Basic {0}' -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $UserName, $($Password | ConvertFrom-SecureString -AsPlainText))))  )
    'Api-Key' = $apiKey
}

$params = @{
    'Uri' = ('{0}/authenticate' -f $uriPrefix)
    'Headers' = $headers
    'Method' = 'POST'
}

$Token = (Invoke-RestMethod @params).token
#endregion

#region Get Customer Data
$headers = @{
    Authorization = ('Bearer {0}' -f $Token)
    'Api-Key' = $apiKey
}
$params = @{
    'Uri' = ('{0}/getCustomerData?includeBikeDetails' -f $uriPrefix)
    'Headers' = $headers
    'Method' = 'GET'
}

(Invoke-RestMethod @params).data | ConvertTo-Json -Depth 10 | Tee-Object -FilePath $('{0}\vanMoof.json' -f $FilePath)
#endregion
```

# How to use?

1. Copy and paste above PowerShell code and save it to file called Get-VanMoofData.ps1
2. Open PowerShell
3. Go to the folder where you save the Get-VanMoofData.ps1 file
4. Run the Get-VanMoofData.ps1 file in PowerShell


## Animated GIF

![Animated GIF](vanMoofDataExporter.gif)
