Import-Module ServerManager

Add-WindowsFeature Web-Server
#Common HTTP Features
Add-WindowsFeature Web-Common-Http -IncludeAllSubFeature
Uninstall-WindowsFeature Web-DAV-Publishing
#Health and Diagnostics
Add-WindowsFeature Web-Health -IncludeAllSubFeature
#Performance
Add-WindowsFeature Web-Performance -IncludeAllSubFeature
#Security
Add-WindowsFeature Web-Security -IncludeAllSubFeature
Uninstall-WindowsFeature Web-IP-Security
#Application Development
Add-WindowsFeature Web-App-Dev -IncludeAllSubFeature
Uninstall-WindowsFeature Web-Includes,Web-WebSockets
#Management tools
Add-WindowsFeature Web-Mgmt-Console,Web-Mgmt-Compat,Web-Scripting-Tools
#WCF Services
Add-WindowsFeature NET-Framework-Features -IncludeAllSubFeature
Uninstall-WindowsFeature NET-Non-HTTP-Activ
Add-WindowsFeature NET-WCF-Services45 -IncludeAllSubFeature
Uninstall-WindowsFeature NET-WCF-MSMQ-Activation45