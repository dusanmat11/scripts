New-NetFirewallRule -DisplayName "IPS IIS URLs" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 443 -Group "IPS GmbH"

New-NetFirewallRule -DisplayName "IPS®EAM Web API" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 7762 -Group "IPS GmbH"

New-NetFirewallRule -DisplayName "IPS®NMM Web API Service" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 7770 -Group "IPS GmbH"

New-NetFirewallRule -DisplayName "IPS®NIOM Web API" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 7777 -Group "IPS GmbH"

New-NetFirewallRule -DisplayName "IPS®MRI Web API" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 7778 -Group "IPS GmbH"

New-NetFirewallRule -DisplayName "IPS®OMS Web API Service" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 7779 -Group "IPS GmbH"

New-NetFirewallRule -DisplayName "IPS®CAPE Web API Service" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 7780 -Group "IPS GmbH"

New-NetFirewallRule -DisplayName "IPS®LAM Web API Service" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 7781 -Group "IPS GmbH"

New-NetFirewallRule -DisplayName "IPS®ANALYSIS Web API Service" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 7790 -Group "IPS GmbH"