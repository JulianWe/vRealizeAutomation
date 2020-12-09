##########################################################################################################
######################## REST CALL to Execute vRo Workflow with input Parameters #########################
##########################################################################################################
# PS Version: 5.1.18362.1171 - Orchestrator v8.2
# Julian Wendland - Söldner Consult GmbH (09.12.2020)
# Parameters:
Param(
    [string]$usr = 'vdi\julian',
    [string]$pwd = 'Sc.?123!',
    [string]$vroServer = 'vro8.vdi.sclabs.net', # in format FQDN:PORT
    [string]$wfid = 'b3549a47-25ac-462e-991a-6935f0aa6e12',
    [string]$apiFormat = 'json', # either xml or json
    [string]$inputFile = 'c:\InputParameterBody.json'# path to input file (either json or xml)
)

# About endpoint
$about = Invoke-RestMethod -Method GET -Uri https://vro8.vdi.sclabs.net:443/vco/api/about
# $about
# API Docs
$apidocs = Invoke-RestMethod -Method GET -Uri https://vro8.vdi.sclabs.net/vco/api/api-docs
# $apidocs.paths
# API Docs
$endpoints = Invoke-RestMethod -Method GET -Uri https://vro8.vdi.sclabs.net/vco/api/
# $endpoints.service


#---------------Disable Certificate checking (easier in Powershell 6.0) ----------------
# If necessary we can add a certificate to make this section redundant.
Write-Host -ForegroundColor Red "#---------------Disable Certificate checking (easier in Powershell 6.0) ----------------"

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
 
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#-------------------------Get a session token ------------------------------------
# The development version of this:

Write-Host -ForegroundColor Red "#-------------------------Get a session token ------------------------------------"

function ConvertTo-Base64($string) {
   $bytes  = [System.Text.Encoding]::UTF8.GetBytes($string);
   $encoded = [System.Convert]::ToBase64String($bytes);
 
   return $encoded;
}
 
$token = ConvertTo-Base64("$($usr):$($pwd)")
Write-Host -ForegroundColor Green "Using Token: $token"

$auth = "Basic $($token)"
Write-Host -ForegroundColor Green "Using Auth: $auth"
 
$headers = @{"Authorization"=$auth;"Content-Type"="application/$($apiFormat)";"Accept"="application/$($apiFormat)"}
Write-Host -ForegroundColor Green "Using Headers: $headers"


#----------------------Get input Parameters from json Path ----------------------
# JSON Body -> Workflow Input Parameters:

Write-Host -ForegroundColor Red "#----------------------Get input Parameters from json Path ----------------------"

$jsonBody = Get-Content $inputFile -Raw
Write-Host -ForegroundColor Green "Using body: " + $jsonBody

$URL = "https://$($vroServer)/vco/api/workflows/$($wfid)/executions"
Write-Host -ForegroundColor Green $URL

try{
    $result = Invoke-WebRequest -Method Post -uri $URL -Headers $headers -body $jsonBody
    $headers = $result.Headers
}catch{
    
    Write-Host -ForegroundColor Red ("ERROR: `t Executing Workflow with ID: $($wfid) ("+$_.Exception+")")
}


#---------------------- Result Headers: ----------------------
# Write result headers

Write-Host -ForegroundColor Red "#---------------------- Result Headers: ----------------------"
ForEach ($header in $headers){
    Write-Host -ForegroundColor Yellow $header
}


#---------------------- Function to call vRo Get Request ----------------------
# Function to request Get vRo Rest API 

function Get-vRoRestCall([string]$username, [string]$password, [string]$url) {
 
  # Create a username:password pair
  $credPair = "$($username):$($password)"
 
  # Encode the pair to Base64 string
  $encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))
 
  # Form the header and add the Authorization attribute to it
  $headers = @{ Authorization = "Basic $encodedCredentials" }
 
  # Make the GET request
  $responseData = Invoke-WebRequest -Uri $url -Method Get -Headers $headers -UseBasicParsing
 
  return $responseData
}


#---------------------- Get Input Params from Workflow ----------------------
# Get input Parameters from Workflow:

$result = Get-vRoRestCall -username $usr -password $pwd -url "https://vro8.vdi.sclabs.net/vco/api/workflows/$($wfid)/"
$dataToDict = $result | ConvertFrom-Json

$inputParams = $dataToDict.'input-parameters'
Write-Host -ForegroundColor Green "#---------------------- Input Parameter from this Worflow: $wfid"
$inputParams
