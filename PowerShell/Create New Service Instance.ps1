sc.exe create "IpsEnergyODataWebApi193Service#DEV" displayname= "IPS®EAM Web API#DEV" type= own start= delayed-auto binpath= "c:\Program Files\IPS GmbH\IPS-ENERGY OData Web API 1.93\IpsEnergy.Services.ODataWebApi.exe serviceInstanceName=DEV"
sc.exe description IpsEnergyODataWebApi193Service#DEV "TCAMC-IPSDB-D01\INST01\IpsEnergy193_DEV"

sc.exe create "IpsLAMWebApiService#DEV" displayname= "IPS®LAM Web API Service#DEV" type= own start= delayed-auto binpath= "C:\Program Files\IPS GmbH\IPS-LAM\IpsLAM.WebApi.exe -C DEV"
sc.exe description "IpsLAMWebApiService#DEV" "TCAMC-IPSDB-D01\INST01\IpsEnergy193_DEV"

sc.exe create "IpsNIOMWebApiService#DEV" displayname= "IPS®NIOM Web API Service#DEV" type= own start= delayed-auto binpath= "C:\Program Files\IPS GmbH\IPS-NIOM\IpsNIOM.WebApi.exe -C DEV"
sc.exe description "IpsNIOMWebApiService#DEV" "TCAMC-IPSDB-D01\INST01\IpsEnergy193_DEV"


sc.exe create "IpsMRIWebApiService#DEV" displayname= "IPS®MRI Web API Service#DEV" type= own start= delayed-auto binpath= "C:\Program Files\IPS GmbH\IPS-MRI\IpsMRI.WebApi.exe -C DEV"
sc.exe description IpsMRIWebApiService#DEV "TCAMC-IPSDB-D01\INST01\IpsEnergy193_DEV"

sc.exe create "IpsNMMWebApiService#DEV" displayname= "IPS®NMM Web API Service#DEV" type= own start= delayed-auto binpath= "C:\Program Files\IPS GmbH\IPS-NMM\IpsNMM.WebApi.exe -C DEV"
sc.exe description IpsNMMWebApiService#DEV "TCAMC-IPSDB-D01\INST01\IpsEnergy193_DEV"

sc.exe create "IpsOMSWebApiService#DEV" displayname= "IPS®OMS Web API Service#DEV" type= own start= delayed-auto binpath= "C:\Program Files\IPS GmbH\IPS-OMS\IpsOMS.WebApi.exe -C DEV"
sc.exe description "IpsOMSWebApiService#DEV" "TCAMC-IPSDB-D01\INST01\IpsEnergy193_DEV"

sc.exe create "IpsAnalysisWebApiService#DEV" displayname= "IPS-Analysis™ Web API Service#DEV" type= own start= delayed-auto binpath= "C:\Program Files\IPS GmbH\IPS-Analysis Web API\IpsAnalysis.WebApi.exe -C DEV"
sc.exe description "IpsAnalysisWebApiService#DEV" "TCAMC-IPSDB-D01\INST01\IpsEnergy193_DEV"