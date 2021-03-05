#Madhu Sunke

#To find Hardblocks information

[hashtable]$Hash = @{}

Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators" -Recurse | ForEach-Object {
       $path = Get-ItemProperty $_.PSPath

       foreach($item in $path){

       $GGatedBlockId = $item.GatedBlockId | Select-Object -ExpandProperty $_.GatedBlockId -ErrorAction SilentlyContinue
       $RedReason     = $item.RedReason | Select-Object -ExpandProperty $_.RedReason -ErrorAction SilentlyContinue

       if($GGatedBlockId -is [system.array]){
       $Hash.Add("PreCache$($item.PSChildName)GatedBlockId",$($GGatedBlockId -join ";"))
       }else{
       $Hash.Add("PreCache$($item.PSChildName)GatedBlockId",$GGatedBlockId)
       }

       if($RedReason -is [system.array]){
       $Hash.Add("PreCache$($item.PSChildName)RedReason",$($RedReason -join ";"))
       }else{
       $Hash.Add("PreCache$($item.PSChildName)RedReason",$RedReason)
       }
    
       }

 
 }

$ourObject = New-Object -TypeName psobject -Property $Hash

$task = Get-ScheduledTaskInfo -TaskName 'Microsoft Compatibility Appraiser' -TaskPath '\Microsoft\Windows\Application Experience\' -ErrorAction SilentlyContinue

#Hardblock info
$ourObject
#Appraiser Task info
$task

