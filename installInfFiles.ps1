### Common variables ###
$global:ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$logfile    = "$env:ProgramData\DriverInstall.log"
$dstart = Get-Date
$div    = "*"*50
#Please create a folder ConexantDrivers and extarct cab file content. 
$DriverCABPath = "$global:ScriptPath\ConexantDrivers"
#CMTraceLog Function formats logging in CMTrace style
function CMTraceLog {
    [CmdletBinding()]
Param (
       [Parameter(Mandatory=$false)]
       $Message,

       [Parameter(Mandatory=$false)]
       $ErrorMessage,

       [Parameter(Mandatory=$false)]
       $Component = "DrivercabInstall",

       [Parameter(Mandatory=$false)]
       [int]$Type,
   
       [Parameter(Mandatory=$true)]
       $LogFile
   )
<#
Type: 1 = Normal, 2 = Warning (yellow), 3 = Error (red)
#>
   $Time = Get-Date -Format "HH:mm:ss.ffffff"
   $Date = Get-Date -Format "MM-dd-yyyy"

   if ($ErrorMessage -ne $null) {$Type = 3}
   if ($Component -eq $null) {$Component = " "}
   if ($Type -eq $null) {$Type = 1}

   $LogMessage = "<![LOG[$Message $ErrorMessage" + "]LOG]!><time=`"$Time`" date=`"$Date`" component=`"$Component`" context=`"`" type=`"$Type`" thread=`"`" file=`"`">"
   $LogMessage | Out-File -Append -Encoding UTF8 -FilePath $LogFile
}
CMTraceLog -Message $div -LogFile $logfile -Type 1
CMTraceLog -Message "Script start time $dstart" -LogFile $logfile -Type 1
$Arch = (Get-Process -Id $PID).StartInfo.EnvironmentVariables["PROCESSOR_ARCHITECTURE"]
if($Arch -eq 'x86'){
    $pnputil = "$env:SystemRoot\sysnative\pnputil.exe"
}elseif ($Arch -eq 'AMD64') {
    $pnputil = "$env:SystemRoot\system32\pnputil.exe"
}
CMTraceLog -Message "PnPutil Path $pnputil" -LogFile $logfile -Type 1
CMTraceLog -Message "Looking for inf files from $DriverCABPath" -LogFile $logfile -Type 1
if(-not(Test-Path $DriverCABPath)){
    CMTraceLog -Message "Drivers folder not exists" -LogFile $logfile -Type 2
    CMTraceLog -Message "Script End time $(Get-Date)" -LogFile $logfile -Type 1
    CMTraceLog -Message $div -LogFile $logfile -Type 1
    exit 0
}
$infFiles = Get-ChildItem $DriverCABPath -Filter *.inf -Recurse -ErrorAction SilentlyContinue `
            | Select-Object -ExpandProperty FullName
if([int]$inffile.count -eq 0){
    CMTraceLog -Message "Inf files not found to install" -LogFile $logfile -Type 2
    CMTraceLog -Message "Script End time $(Get-Date)" -LogFile $logfile -Type 1
    CMTraceLog -Message $div -LogFile $logfile -Type 1
    exit 0
}
foreach($inffile in $infFiles){
    CMTraceLog -Message "Processing $inffile" -LogFile $logfile -Type 1
    & $pnputil -i -a $inffile
}
CMTraceLog -Message "Script End time $(Get-Date)" -LogFile $logfile -Type 1
CMTraceLog -Message $div -LogFile $logfile -Type 1