
# In order to test this, you need to get vsphere SDK for webservices, as this is using the libraries from there. https://my.vmware.com/group/vmware/downloads/get-download?downloadGroup=VS-MGMT-SDK70U2
# new-webserviceproxy can't handle soap security headers. You also need PKCS#12 pfx certificate (in this example)



$vroURL = "https://vro8.vdi.sclabs.net:443"
$vcURL= "https://jw-vcsa7.vdi.sclabs.net:7444"
$username=  "vdi\julian"
$password = "XXX"
$certPass = "VMware1!"
$certPath = "C:\Users\JW\Desktop\jw-vcsa7.vdi.sclabs.net.combinedcertchain.pfx"
$wfid = 'b3549a47-25ac-462e-991a-6935f0aa6e12'
$inputFile = 'C:\Users\JW\Documents\GitHub\vRealizeAutomation\dispatscherWorkflow\InputParameterBody.xml'
$ApiEndpoint= "/vco/api/workflows/$($wfid)/executions"
$restmethod = 'POST'
$apiFormat = 'xml' 


Add-Type -Path 'C:\Users\JW\Desktop\SDK\vsphere-ws\dotnet\bin\VMware-SDK-Management-SampleTemplate\bin\Debug\VMware.Binding.WsTrust.dll'
Add-Type -Path 'C:\Users\JW\Desktop\SDK\vsphere-ws\dotnet\bin\VMware-SDK-Management-SampleTemplate\bin\Debug\STSService.dll'

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
[VMware.Binding.WsTrust.SamlTokenHelper]::SetupServerCertificateValidation()

#https://www.dorkbrain.com/docs/2017/09/02/gzip-in-powershell/
Function ConvertTo-GZipString () {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        $String
    )
    Process {
        $String | ForEach-Object {
            $stream = [System.IO.MemoryStream]::new()
            $writer = [System.IO.StreamWriter][System.IO.Compression.GZipStream]::new($stream, [System.IO.Compression.CompressionMode]::Compress)
            $writer.Write($_)
            $writer.Close()
            [Convert]::ToBase64String([byte[]][char[]]$stream.ToArray())
        }
    }
}


#i have generated my certificate with 'VMware1!' password
$signingCertificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$signingCertificate.Import($certPath, $certPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet)

$service = [VMware.Binding.WsTrust.SamlTokenHelper]::GetSTSService("$vcURL/sts/STSService", $username, $password, $signingCertificate) 
$token = [VMware.Binding.WsTrust.SamlTokenHelper]::GetHokRequestSecurityTokenType()
$token.SignatureAlgorithm = [vmware.sso.SignatureAlgorithmEnum]::httpwwww3org200104xmldsigmorersasha256
$response = $service.Issue($token)

$responsetoken = $response.RequestSecurityTokenResponse.RequestedSecurityToken
$responsetokenXML = $responsetoken.OuterXml
$encodedANDgzippedtoken = ConvertTo-GZipString –String $responsetokenXML

#I had new line like that before but `n works as well.
#$nl = (0x0A -as [char]) 

$timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds().ToString()
$nonce = $timestamp + ':ass234'

[system.uri]$uri = "$vroURL$ApiEndpoint"
$httprequesturi = '/' + $uri.AbsolutePath.split('/')[-1] + $uri.Query
$httprequesthost = $uri.Host
$httprequestport = $uri.Port
$noext = ''

$normalizedrequeststring = $timestamp + "`n" + $nonce + "`n" + $timestamp + "`n" + $restmethod + "`n" + $httprequesturi + "`n" + $httprequesthost + "`n" + $httprequestport + "`n" + $noext + "`n"


$psigningCertificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$psigningCertificate.Import($certPath, $certPass, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable  )
#converted from c# to PS from https://stackoverflow.com/questions/7444586/how-can-i-sign-a-file-using-rsa-and-sha256-with-net
$privatekey = $psigningCertificate.PrivateKey
$privatekey1 = New-Object System.Security.Cryptography.RSACryptoServiceProvider  
$privatekey1.ImportParameters($privatekey.ExportParameters($true))

$enc = [system.Text.Encoding]::UTF8
$data = $enc.GetBytes($normalizedrequeststring) 
$sig = $privatekey1.SignData($data, "SHA256")
$base64sig = [Convert]::ToBase64String($sig)
#[bool]$isValid = $privateKey1.VerifyData($data, "SHA256", $sig)


$headervalue = 'SIGN token="{0}",nonce="{1}",signature_alg="RSA-SHA256",signature="{2}"' -f $encodedANDgzippedtoken, $nonce, $base64sig
$header = @{'Authorization' = $headervalue;"Content-Type"="application/$($apiFormat)";"Accept"="application/$($apiFormat)" }

$jsonBody = Get-Content $inputFile -Raw

$answer = Invoke-WebRequest –Uri "$vroURL$ApiEndpoint" –Headers $header -Body $jsonBody -Method $restmethod
$answer.Content 






<#

Please find the details below shared by the engineering team.
The Authorization header has the following.
Authorization: SIGN token="…",
               nonce="1589541389518:1761545587",
               bodyhash="k9kbtCIy0CkI3/FEfpS/oIDjk6k=",
               signature_alg="RSA-SHA256",
               signature="…"
Description:
——-
token              REQUIRED. The SAML2 token identifying the caller. The value is calculated as BASE64(GZIP(SAML2)).
nonce              REQUIRED. A unique string generated by the client allowing the server to identify replay attacks and reject such requests. 
                             The strings must be unique across all requests of a single client. The definition is as specified in Section 3.1
                             of draft-ietf-oauth-v2-http-mac (http://tools.ietf.org/id/draft-ietf-oauth-v2-http-mac-00.txt) with one difference – the first component should be the current time expressed in
                             the number of milliseconds since January 1, 1970 00:00:00 GMT with no leading zeros.
bodyhash           OPTIONAL. A hash value computed as described in Section 3.2 of draft-ietf-oauth-v2-http-mac (http://tools.ietf.org/id/draft-ietf-oauth-v2-http-mac-00.txt) over the entire HTTP request 
                             entity body (as defined in Section 7.2 of RFC 2616(http://www.ietf.org/rfc/rfc2616.txt)). Note that the body hash may be missing only if there is no
                             request body, i.e. empty body. Otherwise it is required.
signature_alg      REQUIRED. The signature algorithm used by the client to sign the request – "RSA-SHA256", "RSA-SHA384" and "RSA-SHA512"
signature          REQUIRED. A message signature calculated over the normalized request as 
                             BASE64(signature-algorithm(private key, request)). The request normalization is done 
                             as defined in Section 3.3.1 of draft-ietf-oauth-v2-http-mac (http://tools.ietf.org/id/draft-ietf-oauth-v2-http-mac-00.txt) with two exception – (a) the body hash is included without 
                             BASE64 applied and (b) no "ext" field is appended. All text based fields in the normalized request
                             are encoded in UTF-8.

Source: https://grzegorzkulikowski.info/2020/05/20/vrealize-orchestrator-rest-request-using-hok-token/

#>