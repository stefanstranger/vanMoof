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