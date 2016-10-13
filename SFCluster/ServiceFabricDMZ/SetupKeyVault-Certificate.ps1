﻿Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "Jomit's Internal Subscription"

$KeyVaultName = 'appCerts'
$KeyVaultSecretName = 'jackschcert'
$ResourceGroupName = 'AllVaults'
$Location = 'westus'
$ClusterName = 'jacksch'
$CertDNSName = $ClusterName + '.' + $Location + '.cloudapp.azure.com'
$Password = "pass@word1"

#New-AzureRmKeyVault -VaultName  $KeyVaultName -ResourceGroupName $ResourceGroupName -Location $Location -EnabledForDeployment

$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$CertFileFullPath = $pwd.Path + '\' + $CertDNSName + '.pfx'

$NewCert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName $CertDNSName
Export-PfxCertificate -FilePath $CertFileFullPath -Password $SecurePassword -Cert $NewCert

$Bytes = [System.IO.File]::ReadAllBytes($CertFileFullPath)
$Base64 = [System.Convert]::ToBase64String($Bytes)

$JSONBlob = @{
    data = $Base64
    dataType = 'pfx'
    password = $Password
} | ConvertTo-Json

$ContentBytes = [System.Text.Encoding]::UTF8.GetBytes($JSONBlob)
$Content = [System.Convert]::ToBase64String($ContentBytes)

$SecretValue = ConvertTo-SecureString -String $Content -AsPlainText -Force
$NewSecret = Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $KeyVaultSecretName -SecretValue $SecretValue -Verbose

Write-Host
Write-Host "Source Vault Resource Id: "$(Get-AzureRmKeyVault -VaultName $KeyVaultName).ResourceId
Write-Host "Certificate URL : "$NewSecret.Id
Write-Host "Certificate Thumbprint : "$NewCert.Thumbprint


#Source Vault Resource Id:  /subscriptions/d0c802cd-23ce-4323-a183-5f6d9a84743e/resourceGroups/AllVaults/providers/Microsoft.KeyVault/vaults/appCerts
#Certificate URL :  https://appcerts.vault.azure.net:443/secrets/jomitschcert/7fdd577abc984738b77a888c22412cf6
#Certificate Thumbprint :  CF596D9A688362B4A2085CDFA120E8A1790DC606


#--------------------------------------------------------------------------------------


#SetupCert.ps1 -Install

$pswd = ConvertTo-SecureString -String "pass@word1" -Force –AsPlainText
Get-Item Cert:\LocalMachine\My\053a87f6c1e3d08ec7fc28522a2cf1921c9daa5e | Export-PfxCertificate -FilePath C:\github\secureservicefabric\SFCluster\ServiceFabricDMZ\jacksch.westus.cloudapp.azure.com.pfx -Password $pswd

$cert = Get-Item Cert:\LocalMachine\My\053a87f6c1e3d08ec7fc28522a2cf1921c9daa5e
Write-Host $cert.ToString($true)


$pswd = "pass@word1"
$PfcFilePath ="C:\github\secureservicefabric\SFCluster\ServiceFabricDMZ\jacksch.westus.cloudapp.azure.com.pfx"
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\LocalMachine\My -FilePath $PfxFilePath -Password (ConvertTo-SecureString -String $pswd -AsPlainText -Force)