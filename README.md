# VanMoof

Repository with PowerShell REST API call to the vanMoof REST API to get your user data saved locally.

Recently E-bike startup VanMoof has applied to a local court for an official suspension of payment provision after running out of money.

[Van-oof! E-bike startup VanMoof, unable to pay bills, files for payment deferment in Holland](https://techcrunch.com/2023/07/12/report-vanmoof-has-filed-for-bankruptcy-protection-in-holland/)

And now there are some projects and people that suggest you need to export your VanMoof encryption key before their servers would go offline.

One of these projects is called [vanmoof-encryption-key-exporter](https://github.com/grossartig/vanmoof-encryption-key-exporter)

Instead of using that tool you can do the same with some simple PowerShell REST API calls:

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
3. Go to the folder where you saved the Get-VanMoofData.ps1 file
4. Run the Get-VanMoofData.ps1 file in PowerShell

# Not wanting to use PowerShell?

If you want to use just curl in your bash shell you can use the following commands:

```bash
username="john.doe@outlook.com"
password="<enter your password>"
accesstoken=$(printf '%s:%s' "$username" "$password" | base64)
bearertoken=$(curl  -X POST 'https://my.vanmoof.com/api/v8/authenticate' --header 'Accept: */*' --header "Authorization: Basic $accesstoken" --header 'Api-Key: fcb38d47-f14b-30cf-843b-26283f6a5819' | jq -r .token)
curl -X GET 'https://my.vanmoof.com/api/v8/getCustomerData?includeBikeDetails=' --header 'Accept: */*' --header 'Api-Key: fcb38d47-f14b-30cf-843b-26283f6a5819' --header "Authorization: Bearer $bearertoken" | jq -r .data > vanMoof.json
```

## Animated GIF

![Animated GIF](vanMoofDataExporter.gif)

Here are the vanMoof's rides endpoints for those can wait to test them out.

### Authenticate

Authenticate with vanMoof's REST API, with your username and password.

***Endpoint:***

```bash
Method: POST
URL: https://my.vanmoof.com/api/v8/authenticate
```

***Headers:***

| Key | Value | Description |
| --- | ------|-------------|
| api-key | fcb38d47-f14b-30cf-843b-26283f6a5819 | This is the default api key found in the decompiler apk package |
| Authorization | Basic \<base64 encoded username and password\> | See example PowerShell code below |

With the following PowerShell code you can create the Authorization header for the Authentication REST API call.

```PowerShell
$UserName = 'john.doe@outlook.com'
$Password = 'superSecretPassword'
('Basic {0}' -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $UserName, $Password)))  )
```

***Output example***

```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9hcGkudmFubW9vZi1hcGkuY29tIiwiaWF0IjoxNjk1dfjsakfjuYmYiOjE2OTU3MTY2NjgsImV4cCI6MTcyNzI1MjY2OCwidXNlciI6MjM5NzEwLCJhcGlfa23413jfdKJHZpY2UiOm51bGwsInJlZnJlc2hfdG9rZW4iOiJkMzgyMzQxZi1mZmQ4LTQzZDEtOTdmYy01NzRhOTMwYjg0MTgifQ._ezeldEn56kjfkldsaiClUtIaSNqcxLW0cn80Y",
  "refreshToken": "44e60821-1ff4-494f-9bb6-bced77b6e362"
}
```

### Get Customer Data (include Bike Details)

Get Customer Data.

***Endpoint:***

```bash
Method: GET
URL: https://my.vanmoof.com/api/v8/v1/getCustomerData?IncludeBikeDetails
```

***Headers:***

| Key | Value | Description |
| --- | ------|-------------|
| api-key | fcb38d47-f14b-30cf-843b-26283f6a5819 | This is the default api key found in the decompiler apk package and in the[ pymoof module](https://github.com/quantsini/pymoof/blob/b77518cd4dc813905802f14364c461b31ac88356/pymoof/tools/retrieve_encryption_key.py#L2)|
| Authorization | Bearer \<JWT token>  | retrieved from call to https://my.vanmoof.com/api/v8/authenticate endpoint. |

***Output example***

```json
{
  "data": {
    "uuid": "b3f75db5-487f-4651-b6b2-93bfc347aa26",
    "name": "John Doe",
    "email": "john.doe@outlook.com",
    "confirmed": true,
    "privacyPolicyAccepted": true,
    "phone": "+31 61 1234567",
    "country": "NL",
    "bikes": [
      {
        "id": 12345,
        "name": "VanMoof S3",
        "frameNumber": "ASY1234567",
        "bikeId": "ASY1234567",
        "frameSerial": null,
        "pendingSmartmoduleMacAddress": null,
        "macAddress": "F8:8A:5E:4F:E7:12",
        "mainEcuSerial": null,
        "bleProfile": "ELECTRIFIED_2020",
        "controller": "2020 S",
        "eLock": true,
        "speaker": true,
        "smartmoduleCurrentVersion": "1.9.1",
        "smartmoduleDesiredVersion": "1.9.3",
        "highestAvailableSpeedLimit": null,
        "tripDistance": 24045,
        "modelName": "VM01-200-2G EU",
        "modelColor": {
          "name": "Dark",
          "primary": "#25282a",
          "secondary": "#25282a"
        },
        "frameShape": "S",
        "customerRole": "owner",
        "permissions": [
          "ADD_USER",
          "FIRMWARE_UPDATES",
          "REMOVE_USER",
          "REPORT_FOUND",
          "REPORT_STOLEN",
          "SEND_STATISTICS",
          "BACKUP_CODE",
          "BIKE_NAME",
          "VIEW_THEFT_CASES",
          "ALARM_SETTINGS",
          "COUNTRY_SETTINGS",
          "LIGHTS",
          "MOTOR_SUPPORT_LEVEL",
          "UNLOCK",
          "READ_VALUES",
          "STOLEN_MODE",
          "SWAP_SMARTMODULE"
        ],
        "isTracking": false,
        "stolen": {
          "isStolen": false,
          "dateStolen": null,
          "status": "not_stolen",
          "latestLocation": null
        },
        "links": {
          "thumbnail": "https://my.vanmoof.com/image/model/67",
          "show": "http://my.vanmoof.com/v8/getBikeData/12345"
        }
      }
    ],
    "hasPendingBikeSharingInvitations": false,
    "links": {
      "hash": "http://my.vanmoof.com/v8/getCustomerDataHash",
      "devices": "http://my.vanmoof.com/v8/getDevices",
      "resendConfirmation": null,
      "update": "http://my.vanmoof.com/v8/updateCustomer",
      "addBike": "http://my.vanmoof.com/v8/registerBikeToCurrentUser",
      "addFcmToken": "http://my.vanmoof.com/v8/registrationToken"
    },
    "bikeDetails": [
      {
        "id": 12345,
        "name": "VanMoof S3",
        "frameNumber": "ASY1234567",
        "bikeId": "ASY1234567",
        "frameSerial": null,
        "ownerName": "John Doe",
        "tripDistance": 24045,
        "pendingSmartmoduleMacAddress": null,
        "macAddress": "F8:8A:5E:4F:E7:12",
        "mainEcuSerial": null,
        "smartmoduleCurrentVersion": "1.9.1",
        "smartmoduleDesiredVersion": "1.9.3",
        "changeBackupCode": false,
        "isTracking": false,
        "highestAvailableSpeedLimit": null,
        "messageAvailable": false,
        "modelName": "VM01-200-2G EU",
        "modelDetails": {
          "Gears": "Automatic 4 speed shifting gears",
          "Motor": "250 - 500 W front-wheel hub motor",
          "Top Speed": "25 km/h (EU speed)",
          "Range": "60 km (full power) ~ 150 km (economy mode)",
          "Edition": "ES-3 2G"
        },
        "modelColor": {
          "name": "Dark",
          "primary": "#25282a",
          "secondary": "#25282a"
        },
        "frameShape": "S",
        "manufacturer": "muco",
        "controller": "2020 S",
        "updateMethod": "OAD (encrypted)",
        "eLock": true,
        "gsmModule": "2G",
        "speaker": true,
        "bleProfile": "ELECTRIFIED_2020",
        "bleVersion": null,
        "messagesViaBLE": "BLEv2",
        "customerRoleFamily": "Responsible",
        "customerRole": "owner",
        "permissions": [
          "ADD_USER",
          "FIRMWARE_UPDATES",
          "REMOVE_USER",
          "REPORT_FOUND",
          "REPORT_STOLEN",
          "SEND_STATISTICS",
          "BACKUP_CODE",
          "BIKE_NAME",
          "VIEW_THEFT_CASES",
          "ALARM_SETTINGS",
          "COUNTRY_SETTINGS",
          "LIGHTS",
          "MOTOR_SUPPORT_LEVEL",
          "UNLOCK",
          "READ_VALUES",
          "STOLEN_MODE",
          "SWAP_SMARTMODULE"
        ],
        "key": {
          "encryptionKey": "<secret>",
          "passcode": "<secret>",
          "userKeyId": 1
        },
        "isFactoryKey": false,
        "customerCount": 2,
        "invitationCount": 0,
        "stolen": {
          "isStolen": false,
          "dateStolen": null,
          "status": "not_stolen",
          "latestLocation": null
        },
        "hasPeaceOfMind": false,
        "peaceOfMind": null,
        "links": {
          "hash": "http://my.vanmoof.com/v8/getBikeDataHash/12345",
          "thumbnail": "https://my.vanmoof.com/image/model/67"
        }
      }
    ]
  },
  "hash": "<secret>"
}
```

### Get Application Token

Get Application Token to use in Authorization Header to get Rides information.

***Endpoint:***

```bash
Method: GET
URL: https://api.vanmoof-api.com/v8/getApplicationToken
```

***Headers:***

| Key | Value | Description |
| --- | ------|-------------|
| api-key | fcb38d47-f14b-30cf-843b-26283f6a5819 | This is the default api key found in the decompiler apk package and in the[ pymoof module](https://github.com/quantsini/pymoof/blob/b77518cd4dc813905802f14364c461b31ac88356/pymoof/tools/retrieve_encryption_key.py#L2)|
| Authorization | Bearer \<JWT token>  | retrieved from call to https://my.vanmoof.com/api/v8/authenticate endpoint. |

***Output example***

```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9hcGkudmFjfkladsjf889tIiwiaWF0IjoxNjk1NzE3NzUwLCJuYmYiOjE2OTU3MTc3NTAsImV4cCI6MTY5NTcyNDk1MCwidXNlciI6InN0ZWZhbi5zdHJhbmdlckBvdXRsb29rLmNvbSIsInV1aWQiOiI3NzI1NjUxMS0zZjBkLTMzMzQtOTU3Yi0xYjU3Y2Y3MzAxOWEiLCJiaWtlcyI6WzY4NzEzXX0.dGmgy09qGSOgMNbiu3uab10W2giQzvVMs6sWryvYsyDkfdsjlksajf-OcTXCobP9tAfkXKu0bbPHQHHU3hCQmA092wKF5ZHfE_ADJ1YVEN6jXX-8eWZylKR3oCcsbAFGKriz6nD9rdbsdiWMMhPfllWwBTraH7h9h7UoMzEseCYWA3iAQYk9RYrYubNfImfIsJb65W6cGugM_wFQM9XRqdXE-q4a9aFEry-tycKF6a0ptuDlFTmBORImlCJUv2O-E4h10l3VDuqBF40bP0G5wEC3IA8AFoA1HZwGc2fuyMnVd97ukZ1JwW6_rQfAwmMT0jwjieMmLdqdVjto31pQ4Ajoq51721ha-LbKF-hNPOwFheqWyXmkDXV6zsFTd5p2IFKp_4j4gpRIfaGjqrceMQd50we46AXdDP573QKswIMld81fHjyyXkCKS0PkMBmOXSSYSzL10vMukTe8vmpyX7SZ-u6VKO3r44HKJFkdjf8saft5haxlddahGJqyfoQH1L0WVOhWQz2u72oUxwxiFZPeBtakE-tQlbHzk_QT5J75DiMMt93W9uFQ42wAdw1PXvYE87Oj7kK5qkrGRXJoidb5bOMJf1FEhX4Iwoc58Duz3T71cPlROxSTBwltXiAJb7nl0wFUSQfEU"
}
```


### Get Rider preferences

Get the vanMoof's Rider preferences.

***Endpoint:***

```bash
Method: GET
URL: https://tenjin.vanmoof.com/api/v1/riders/{riderId}/preferences
```

***Headers:***

| Key | Value | Description |
| --- | ------|-------------|
| api-key | fcb38d47-f14b-30cf-843b-26283f6a5819 | This is the default api key found in the decompiler apk package and in the[ pymoof module](https://github.com/quantsini/pymoof/blob/b77518cd4dc813905802f14364c461b31ac88356/pymoof/tools/retrieve_encryption_key.py#L2)|
| Authorization | Bearer \<JWT token>  | retrieved from call to https://api.vanmoof-api.com/v8/getApplicationToken endpoint|

***Query Parameters:***

| Query Parameter | Value | Description |
| --- | ------|-------------|
| riderId | b3f75db5-487f-4651-b6b2-93bfc347aa26 | This is the uuid property retrieved using the Get Customer Data REST API call |


***Output example***

```json
{
  "recordRides": true,
  "recordCountry": false,
  "city": "NL AMS",
  "optedOutOfCity": false
}
```

### Get Cities

Get all the vanMoof's Cities that track the rides.

***Endpoint:***

```bash
Method: GET
URL: https://tenjin.vanmoof.com/api/v1/cities
```

***Headers:***

| Key | Value | Description |
| --- | ------|-------------|
| api-key | fcb38d47-f14b-30cf-843b-26283f6a5819 | This is the default api key found in the decompiler apk package and in the[ pymoof module](https://github.com/quantsini/pymoof/blob/b77518cd4dc813905802f14364c461b31ac88356/pymoof/tools/retrieve_encryption_key.py#L2)|
| Authorization | Bearer \<JWT token>  | retrieved from call to https://api.vanmoof-api.com/v8/getApplicationToken endpoint|

***Output example***

```json
[
  {
    "country": "NL",
    "code": "NL AMS",
    "name": "Amsterdam",
    "location": {
      "lat": 52.350000,
      "long": 4.916600
    }
  },
  {
    "country": "BE",
    "code": "BE ANR",
    "name": "Antwerpen",
    "location": {
      "lat": 51.221100,
      "long": 4.399700
    }
  },
  {
    "country": "NL",
    "code": "NL ARN",
    "name": "Arnhem",
    "location": {
      "lat": 51.988000,
      "long": 5.923000
    }
  },
  {
    "country": "DE",
    "code": "DE BER",
    "name": "Berlin",
    "location": {
      "lat": 52.516700,
      "long": 13.383300
    }
  },
  {
    "country": "DE",
    "code": "DE BON",
    "name": "Bonn",
    "location": {
      "lat": 50.733900,
      "long": 7.099700
    }
  },
  {
    "country": "FR",
    "code": "FR BOD",
    "name": "Bordeaux",
    "location": {
      "lat": 44.840000,
      "long": -0.580000
    }
  },
  {
    "country": "DE",
    "code": "DE BRE",
    "name": "Bremen",
    "location": {
      "lat": 53.115300,
      "long": 8.797500
    }
  },
  {
    "country": "GB",
    "code": "GB BRS",
    "name": "Bristol",
    "location": {
      "lat": 51.450000,
      "long": -2.583300
    }
  },
  {
    "country": "BE",
    "code": "BE BRU",
    "name": "Brussel (Bruxelles)",
    "location": {
      "lat": 50.846700,
      "long": 4.351700
    }
  },
  {
    "country": "DE",
    "code": "DE DTM",
    "name": "Dortmund",
    "location": {
      "lat": 51.513900,
      "long": 7.465300
    }
  },
  {
    "country": "DE",
    "code": "DE DRS",
    "name": "Dresden",
    "location": {
      "lat": 51.049300,
      "long": 13.738400
    }
  },
  {
    "country": "IE",
    "code": "IE DUB",
    "name": "Dublin",
    "location": {
      "lat": 53.342500,
      "long": -6.265800
    }
  },
  {
    "country": "DE",
    "code": "DE DUS",
    "name": "Düsseldorf",
    "location": {
      "lat": 51.231100,
      "long": 6.772400
    }
  },
  {
    "country": "GB",
    "code": "GB EDI",
    "name": "Edinburgh",
    "location": {
      "lat": 55.953000,
      "long": -3.189000
    }
  },
  {
    "country": "NL",
    "code": "NL EIN",
    "name": "Eindhoven",
    "location": {
      "lat": 51.430000,
      "long": 5.500000
    }
  },
  {
    "country": "BE",
    "code": "BE ESS",
    "name": "Essen",
    "location": {
      "lat": 51.450800,
      "long": 7.013100
    }
  },
  {
    "country": "DE",
    "code": "DE FRA",
    "name": "Frankfurt am Main",
    "location": {
      "lat": 50.113600,
      "long": 8.679700
    }
  },
  {
    "country": "NL",
    "code": "NL GRQ",
    "name": "Groningen",
    "location": {
      "lat": 53.220400,
      "long": 6.580000
    }
  },
  {
    "country": "SE",
    "code": "SE GOT",
    "name": "Göteborg",
    "location": {
      "lat": 57.671700,
      "long": 11.981000
    }
  },
  {
    "country": "NL",
    "code": "NL HAA",
    "name": "Haarlem",
    "location": {
      "lat": 52.380400,
      "long": 4.630000
    }
  },
  {
    "country": "DE",
    "code": "DE HAM",
    "name": "Hamburg",
    "location": {
      "lat": 53.550000,
      "long": 10.000000
    }
  },
  {
    "country": "DE",
    "code": "DE HAJ",
    "name": "Hannover",
    "location": {
      "lat": 52.374400,
      "long": 9.738600
    }
  },
  {
    "country": "FI",
    "code": "FI HEL",
    "name": "Helsinki (Helsingfors)",
    "location": {
      "lat": 60.175600,
      "long": 24.934200
    }
  },
  {
    "country": "DE",
    "code": "DE KAE",
    "name": "Karlsruhe",
    "location": {
      "lat": 49.016700,
      "long": 8.400000
    }
  },
  {
    "country": "DE",
    "code": "DE CGN",
    "name": "Köln",
    "location": {
      "lat": 50.942200,
      "long": 6.957800
    }
  },
  {
    "country": "DK",
    "code": "DK CPH",
    "name": "København",
    "location": {
      "lat": 55.678600,
      "long": 12.563500
    }
  },
  {
    "country": "NL",
    "code": "NL LID",
    "name": "Leiden",
    "location": {
      "lat": 52.160100,
      "long": 4.497000
    }
  },
  {
    "country": "DE",
    "code": "DE LEJ",
    "name": "Leipzig",
    "location": {
      "lat": 51.350000,
      "long": 12.383300
    }
  },
  {
    "country": "GB",
    "code": "GB LON",
    "name": "London",
    "location": {
      "lat": 51.507200,
      "long": -0.127500
    }
  },
  {
    "country": "US",
    "code": "US LAX",
    "name": "Los Angeles",
    "location": {
      "lat": 34.113900,
      "long": -118.406800
    }
  },
  {
    "country": "FR",
    "code": "FR LIO",
    "name": "Lyon",
    "location": {
      "lat": 45.760000,
      "long": 4.840000
    }
  },
  {
    "country": "NL",
    "code": "NL MST",
    "name": "Maastricht",
    "location": {
      "lat": 50.853000,
      "long": 5.677000
    }
  },
  {
    "country": "GB",
    "code": "GB MNC",
    "name": "Manchester",
    "location": {
      "lat": 53.479400,
      "long": -2.245300
    }
  },
  {
    "country": "DE",
    "code": "DE MUC",
    "name": "München",
    "location": {
      "lat": 48.137200,
      "long": 11.575500
    }
  },
  {
    "country": "DE",
    "code": "DE MSR",
    "name": "Münster",
    "location": {
      "lat": 51.962500,
      "long": 7.625600
    }
  },
  {
    "country": "US",
    "code": "US NYC",
    "name": "New York City",
    "location": {
      "lat": 40.694300,
      "long": -73.924900
    }
  },
  {
    "country": "NL",
    "code": "NL NIJ",
    "name": "Nijmegen",
    "location": {
      "lat": 51.833300,
      "long": 5.866700
    }
  },
  {
    "country": "DE",
    "code": "DE RGM",
    "name": "Nuremberg",
    "location": {
      "lat": 49.452800,
      "long": 11.077800
    }
  },
  {
    "country": "JP",
    "code": "JP OSA",
    "name": "Osaka",
    "location": {
      "lat": 34.693600,
      "long": 135.501900
    }
  },
  {
    "country": "FR",
    "code": "FR PAR",
    "name": "Paris",
    "location": {
      "lat": 48.856600,
      "long": 2.352200
    }
  },
  {
    "country": "US",
    "code": "US DTP",
    "name": "Portland",
    "location": {
      "lat": 45.537200,
      "long": -122.650000
    }
  },
  {
    "country": "NL",
    "code": "NL RTM",
    "name": "Rotterdam",
    "location": {
      "lat": 51.920000,
      "long": 4.480000
    }
  },
  {
    "country": "US",
    "code": "US SFO",
    "name": "San Francisco",
    "location": {
      "lat": 37.756200,
      "long": -122.443000
    }
  },
  {
    "country": "US",
    "code": "US SEA",
    "name": "Seattle",
    "location": {
      "lat": 47.621100,
      "long": -122.324400
    }
  },
  {
    "country": "SE",
    "code": "SE STO",
    "name": "Stockholm",
    "location": {
      "lat": 59.329400,
      "long": 18.068600
    }
  },
  {
    "country": "FR",
    "code": "FR SXB",
    "name": "Strasbourg",
    "location": {
      "lat": 48.583300,
      "long": 7.745800
    }
  },
  {
    "country": "DE",
    "code": "DE STR",
    "name": "Stuttgart",
    "location": {
      "lat": 48.776100,
      "long": 9.177500
    }
  },
  {
    "country": "NL",
    "code": "NL HAG",
    "name": "The Hague",
    "location": {
      "lat": 52.080000,
      "long": 4.270000
    }
  },
  {
    "country": "JP",
    "code": "JP TYO",
    "name": "Tokyo",
    "location": {
      "lat": 35.689700,
      "long": 139.692200
    }
  },
  {
    "country": "NL",
    "code": "NL UTC",
    "name": "Utrecht",
    "location": {
      "lat": 52.100300,
      "long": 5.120000
    }
  },
  {
    "country": "US",
    "code": "US WAS",
    "name": "Washington D.C.",
    "location": {
      "lat": 39.747000,
      "long": -75.072400
    }
  },
  {
    "country": "AT",
    "code": "AT VIE",
    "name": "Wien",
    "location": {
      "lat": 38.899600,
      "long": -77.259700
    }
  },
  {
    "country": "NL",
    "code": "NL ZWO",
    "name": "Zwolle",
    "location": {
      "lat": 52.524000,
      "long": 6.097000
    }
  }
]
```

### Get weekly Rides

Get the vanMoof's weekly rides per Rider.

***Endpoint:***

```bash
Method: GET
URL: https://tenjin.vanmoof.com/api/v1/rides/{riderId}/{bikeId}/weekly?lastSeenWeek=2023-08-20&limit=5
```

***Headers:***

| Key | Value | Description |
| --- | ------|-------------|
| api-key | fcb38d47-f14b-30cf-843b-26283f6a5819 | This is the default api key found in the decompiler apk package and in the[ pymoof module](https://github.com/quantsini/pymoof/blob/b77518cd4dc813905802f14364c461b31ac88356/pymoof/tools/retrieve_encryption_key.py#L2)|
| Authorization | Bearer \<JWT token>  | retrieved from call to https://api.vanmoof-api.com/v8/getApplicationToken endpoint|
| cache-control | no-cache, private | HTTP header field holds directives (instructions) — in both requests and responses — that control caching in browsers and shared caches | 
| accept-language | en_US | Indicates the natural language and locale that the client prefers | 
| accept-encoding | gzip | Indicates the content encoding (usually a compression algorithm) that the client can understand | 
| timezone | Europe/Amsterdam | Timezone of rider. Has an impact on the lastSeenWeek query parameter. Check [wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for a list of timezones. | 

***Query Parameters:***

| Query Parameter | Value | Description |
| --- | ------|-------------|
| riderId | b3f75db5-487f-4651-b6b2-93bfc347aa26 | This is the uuid property retrieved using the Get Customer Data REST API call |
| bikeId | 12345 |This is the bikeId from the Get Customer Date rest api call |
| lastSeenWeek | 2023-08-20 | Last day of thew week for which you want to retrieve your rides data in format yyyy-mm-dd. The provided date needs to be a Sunday |
| limit | 1..15 | This set the number of previous startdates for the rides to retrieve. Maximum value is 15 |



***Output example***

```json
{
    "carousel": {
      "summary": {
        "averageDistance": 10.230088108828005,
        "totalRides": 146,
        "averageDuration": 1500652.2534246575,
        "averageSpeed": 24.34394418130039,
        "totalDistance": 1493.5928638888888
      },
      "world": {
        "averageDistance": 3.93207964678266,
        "totalRides": 226469,
        "averageDuration": 855250.1459714134
      },
      "city": {
        "name": "Amsterdam",
        "averageDistance": 3.6543007353849726,
        "totalRides": 52695,
        "averageDuration": 776877.2192048582
      },
      "week": {
        "averageDistance": 0,
        "totalRides": 0,
        "averageDuration": 0,
        "startDate": "2023-09-24",
        "totalDistance": 0,
        "weekData": [
          {
            "dayName": "S",
            "dayDistance": 0
          },
          {
            "dayName": "M",
            "dayDistance": 0
          },
          {
            "dayName": "T",
            "dayDistance": 0
          },
          {
            "dayName": "W",
            "dayDistance": 0
          },
          {
            "dayName": "T",
            "dayDistance": 0
          },
          {
            "dayName": "F",
            "dayDistance": 0
          },
          {
            "dayName": "S",
            "dayDistance": 0
          }
        ]
      }
    },
    "section": [
      {
        "startDate": "2023-09-10",
        "weeklyRecap": {
          "startDate": "2023-09-10",
          "totalRides": 3,
          "totalDistance": 24.459629444444456,
          "averageDistance": 8.153209814814819,
          "averageDuration": 1116562,
          "longestRide": 1698064,
          "furthestRide": 12.244573611111118,
          "assistanceLevel": null,
          "busiestRide": 7,
          "totalDayRides": 2,
          "totalNightRides": 1,
          "totalRidesLastWeek": 0,
          "weekdays": [
            {
              "date": "2023-09-10",
              "weekday": "S",
              "totalRides": 0,
              "totalDistance": 0,
              "totalDayRides": 0,
              "totalNightRides": 0
            }
          ]
        },
        "rides": [
          {
            "id": "bede8651-e9fa-4a77-b92e-4050a7c906d9",
            "speeds": [
              {
                "speed": 28,
                "date": "2023-09-11T17:46:12.875+02:00"
              },
              {
                "speed": 28,
                "date": "2023-09-11T17:46:17.45+02:00"
              },
              {
                "speed": 25,
                "date": "2023-09-11T17:46:23.406+02:00"
              },  
              {
                "speed": 0,
                "date": "2023-09-11T08:13:38.3+02:00"
              }
            ],
            "startDate": "2023-09-11T05:45:20+00:00",
            "distance": 12.244573611111118,
            "durationMilli": 1698064
          }
        ]
      }
    ]
  }
```
