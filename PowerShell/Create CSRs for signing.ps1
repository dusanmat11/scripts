$CSRlist = Get-Content C:\temp\csrlist.txt

foreach ($CSR in $CSRlist) {
    Write-Host "Creating CertificateRequest (CSR) for $CertName `r "

    Invoke-Command -ScriptBlock {
        $CertName = $CSR
        $CSRPath = "C:\install\CSR\202310_CSR\$($CertName).csr"
        $INFPath = "c:\temp\$($CertName).inf"
        $Signature = '$Windows NT$'

        $AlternativeNames = "$CSR"  # Add your desired Alternative Names here

        $INF = @"
[Version]
Signature="$Signature"

[NewRequest]
Subject = "CN=$CertName, OU=DICT, O=Distributie Energie Electrica Romania, L=Cluj-Napoca, S=Cluj, C=RO"
KeySpec = 1
KeyLength = 2048
Exportable = TRUE
MachineKeySet = TRUE
SMIME = False
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0

[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.1

[Extensions]
2.5.29.17 = "{text}"
_continue_ = "DNS=$($AlternativeNames -join ', DNS=')"
"@

        Write-Host "Certificate Request is being generated `r "
        $INF | Out-File -FilePath $INFPath -Force
        certreq -new $INFPath $CSRPath
    }

    Write-Output "Certificate Request has been generated"
}
