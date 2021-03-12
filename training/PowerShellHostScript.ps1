param (
[Parameter(Position=0,mandatory=$true)]
[String]$user,
[Parameter(Position=1,mandatory=$true)]
[String]$variable
)



#####################################################################################################################################
# 1. Logging
#####################################################################################################################################
# Pfad der Logdatei:
$logpath = 'C:\Logfiles\HelloWorld\'
# Timestampermittlung für Logdateinamen
$date = "{0:yyyyMMddHHmmss}" -f (get-date)
# Zusammenbau des Logdateinamens
$logfilename = "$variable-$date.txt"
# Kompletter Pfad zur Logdatei:
$logfile = $logpath + $logfilename


# Funktion zum Schreiben der Log-Datei
function logAdd ([string]$msg) {
  $msg="{0:dd.MM.yyyy HH:mm:ss} {1}" -f (Get-Date), $msg
  $msg | Add-Content -Path $logfile
  if($script:config.debug -eq $true){$msg| Out-Host}
}


# Funktion zum Prüfen / Anlegen des Log-Verzeichnisses
function ensureDirectory([string]$ordner,[string]$error_msg="",[bool]$strict=$false,[bool]$silent=$false) {
  $returndir=$true
  if (!(Test-Path $ordner)) {
    try {
      New-Item -Type Directory -Path $ordner -ErrorAction Stop | Out-Null
    }
    catch {
      $returndir=$false 
      if ($error_msg -ne "") { $error_msg | Out-Host }      
      if ($strict -eq $true) { Exit }
    }
  }
  if ($silent -ne $true) { $returndir }
}


#####################################################################################################################################


ensureDirectory -ordner $logpath -strict $true -error_msg "FEHLER: Der Basisordner ist nicht vorhanden und konnte nicht angelegt werden." -silent $true

logAdd("INFO: `t Start Script Hello World")
Write-Host "Start Script Hello World"



try{
write-host "Hello Orchestrator!: $user, $variable"

}catch{
    Write-Host -ForegroundColor Red "FEHLER: `t  Beim Aufrufen des Hello World Scirpts"
    logAdd("FEHLER: `t Beim Aufrufen des Hello World Scirpts. ("+$_.Exception+")")
}
$output = "Script was successful"
return $output