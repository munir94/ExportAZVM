
#Original code from https://rajanieshkaushikk.com/2021/02/03/retrieve-azure-vm-details-by-using-powershell/
#with some improvement  https://www.tutorialspoint.com/how-to-retrieve-the-azure-vm-ram-and-cpu-size-using-powershell
####################################################################################################################

#Please install Excel module if not present 
#Install-Module -Name ImportExcel
#Import-Module ImportExcel

# Connect to Azure Account
Connect-AzAccount
 
# Create Report Array
$report = @()
# Record all the subscriptions in a Text file  
$SubscriptionIds = Get-Content -Path "c:\output"
Foreach ($SubscriptionId in $SubscriptionIds) 
{
$reportName = "VM-Details.csv"
 
# Select the subscription  
Select-AzSubscription $subscriptionId
 
# Get all the VMs from the selected subscription
$vms = Get-AzVM
 
# Get all the Public IP Address
$publicIps = Get-AzPublicIpAddress
 
# Get all the Network Interfaces
$nics = Get-AzNetworkInterface | Where-Object{ $_.VirtualMachine -NE $null} 
foreach ($nic in $nics) { 
    # Creating the Report Header we have taken maxium 5 disks but you can extend it based on your need
    $ReportDetails = "" | Select-Object VmName, Hostname , ResourceGroupName, Region, Zone , VmSize, VmCore, VmRAM , VirtualNetwork, Subnet, PrivateIpAddress, OsType, OSversion , PublicIPAddress, NicName, ApplicationSecurityGroup, OSDiskName, OSDisksku , OSDiskCaching, OSDiskSize, DataDiskCount, DataDisk1Name, DataDisk1Size,DataDisk1Caching, DataDisk1sku , DataDisk2Name, DataDisk2Size,DataDisk2Caching,DataDisk2sku , DataDisk3Name, DataDisk3Size,DataDisk3Caching,DataDisk3sku ,  DataDisk4Name, DataDisk4Size,DataDisk4Caching,DataDisk4sku , DataDisk5Name, DataDisk5Size,DataDisk5Caching , DataDisk5sku 
   #Get VM IDs
    $vm = $vms | Where-Object -Property Id -eq $nic.VirtualMachine.id 
    foreach($publicIp in $publicIps) { 
        if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
            $ReportDetails.PublicIPAddress = $publicIp.ipaddress
            } 
        } 
        $ReportDetails.OsType = $vm.StorageProfile.OsDisk.OsType
        $ReportDetails.OsVersion = $vm.StorageProfile.ImageReference.Offer + " $($vm.StorageProfile.ImageReference.Sku)"
        $ReportDetails.VMName = $vm.Name 
        $ReportDetails.Hostname =$vm.OSProfile.ComputerName
        $ReportDetails.ResourceGroupName = $vm.ResourceGroupName 
        $ReportDetails.Region = $vm.Location 
        # ! set zone 
        #$ReportDetails.Zonetemp = (Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name).Zones
        $ReportDetails.Zone = $vm | Select-Object -Property Zone -ExpandProperty Zones
        #@{Name=’Zone’;Expression={[string]::join(“{}”, ($_.Zones))}}
        # todo  set zone 
        $ReportDetails.VmSize = $vm.HardwareProfile.VmSize
        $ReportDetails.VmCore = (Get-AzVMSize -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name  | where-Object{$_.Name -eq $vm.HardwareProfile.VmSize}).NumberOfCores
        $ReportDetails.VmRAM = (Get-AzVMSize -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name  | Where-Object{$_.Name -eq $vm.HardwareProfile.VmSize}).MemoryInMB /1024
        $ReportDetails.VirtualNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3] 
        $ReportDetails.Subnet = $nic.IpConfigurations.subnet.Id.Split("/")[-1] 
        $ReportDetails.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress 
        $ReportDetails.NicName = $nic.Name 
        $ReportDetails.ApplicationSecurityGroup = $nic.IpConfigurations.ApplicationSecurityGroups.Id 
        $ReportDetails.OSDiskName = $vm.StorageProfile.OsDisk.Name
        $ReportDetails.OSDisksku = (Get-azdisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.OsDisk.Name).Sku.Name
        $ReportDetails.OSDiskSize = $vm.StorageProfile.OsDisk.DiskSizeGB
        $ReportDetails.OSDiskCaching = $vm.StorageProfile.OsDisk.Caching
        $ReportDetails.DataDiskCount = $vm.StorageProfile.DataDisks.count
 
        if ($vm.StorageProfile.DataDisks.count -gt 0)
        {
     $disks= $vm.StorageProfile.DataDisks
     foreach($disk in $disks)
        {
        If ($disk.Lun -eq 0)
        {
       $ReportDetails.DataDisk1Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
       $ReportDetails.DataDisk1Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
       $ReportDetails.DataDisk1Caching =  $vm.StorageProfile.DataDisks[$disk.Lun].Caching 
       $ReportDetails.DataDisk1sku = (Get-azdisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.DataDisks[$disk.Lun].Name).Sku.Name
         
        }
        elseif($disk.Lun -eq 1)
        {
        $ReportDetails.DataDisk2Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
       $ReportDetails.DataDisk2Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
       $ReportDetails.DataDisk2Caching =  $vm.StorageProfile.DataDisks[$disk.Lun].Caching
       $ReportDetails.DataDisk2sku = (Get-azdisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.DataDisks[$disk.Lun].Name).Sku.Name 
        }
        elseif($disk.Lun -eq 2)
        {
        $ReportDetails.DataDisk3Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
       $ReportDetails.DataDisk3Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
       $ReportDetails.DataDisk3Caching =  $vm.StorageProfile.DataDisks[$disk.Lun].Caching 
       $ReportDetails.DataDisk3sku = (Get-azdisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.DataDisks[$disk.Lun].Name).Sku.Name
        }
        elseif($disk.Lun -eq 3)
        {
        $ReportDetails.DataDisk4Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
       $ReportDetails.DataDisk4Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
       $ReportDetails.DataDisk4Caching =$vm.StorageProfile.DataDisks[$disk.Lun].Caching
       $ReportDetails.DataDisk4sku = (Get-azdisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.DataDisks[$disk.Lun].Name).Sku.Name 
        }
        elseif($disk.Lun -eq 4)
        {
        $ReportDetails.DataDisk5Name = $vm.StorageProfile.DataDisks[$disk.Lun].Name 
       $ReportDetails.DataDisk5Size =  $vm.StorageProfile.DataDisks[$disk.Lun].DiskSizeGB 
       $ReportDetails.DataDisk5Caching =  $vm.StorageProfile.DataDisks[$disk.Lun].Caching 
       $ReportDetails.DataDisk4sku = (Get-azdisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.DataDisks[$disk.Lun].Name).Sku.Name
        }
       }
        }
        $report+=$ReportDetails 
    } }
     
$report | Format-Table VmName, Hostname , ResourceGroupName, Region, Zone  , VmSize,VmCore, VmRAM , VirtualNetwork, Subnet, PrivateIpAddress, OsType, OSversion , PublicIPAddress, NicName, ApplicationSecurityGroup, OSDiskName,OSDisksku, OSDiskSize, DataDiskCount, DataDisk1Name, DataDisk1Size , DataDisk1sku 
#Change the path based on your convenience
#@{ n='Zone'; e={ $_.Zones[0] -join ' ' } }
$report | Export-CSV "D:ExportAZVM-main\output\$reportName"
#$report | Export-Excel -path "c:\outputs\$reportName"
#$report | Export-Excel -path "D:\output\test01.xlsx"
