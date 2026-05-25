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



# Windows 10/11

# Enable IIS (Web Server)
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -All

# Common HTTP Features
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures -All
Disable-WindowsOptionalFeature -Online -FeatureName IIS-WebDAV

# Health and Diagnostics
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics -All

# Performance
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance -All

# Security
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security -All
Disable-WindowsOptionalFeature -Online -FeatureName IIS-IPSecurity

# Application Development
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment -All
Disable-WindowsOptionalFeature -Online -FeatureName IIS-Includes
Disable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets

# Management Tools
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementScriptingTools

# .NET Framework Features
Enable-WindowsOptionalFeature -Online -FeatureName NetFx4 -All

# WCF Services (subset available on client Windows)
Enable-WindowsOptionalFeature -Online -FeatureName WCF-Services45 -All
Disable-WindowsOptionalFeature -Online -FeatureName WCF-NonHTTP-Activation45
Disable-WindowsOptionalFeature -Online -FeatureName WCF-MSMQ-Activation45