# Splunk-Universal-Forwarder-SCCM-Package
Microsoft System Center Configuration Manager package for Splunk Universal Forwarder (UF) without system/local configuration. This application package installs or upgrades the Splunk UF via Powershell in the background, as various states can thus be checked and achieved. During deployment/installation, settings under system/local are checked and partially removed. After successful installation, a customized Splunk app is copied to the application directory, which speaks to full central administration via the Splunk Deployment Server(s).


For the package import, the following steps are required:
   * copy xxx_package.zip file and the entire folder xxx_package_files
   * replace the dummy splunkforwarder.msi file with the right one
   * download the msi from Splunk.com

Import the Installation package in MS SCCM (Applications)

Installation Steps:
   * check if the MSI is already installed on the endpoint (detection method of sccm)
   * check system/local configuration for deploymentclient.conf or outputs.conf and delete these files
   * install/upgrade Splunk universal forwarder software
   * Copy the deployment-client definition (custom Splunk App) under ../etc/apps
   * restart splunkd
   * done


Addition:
   * you can extend/modify the logic of the Powershell Script for your own requirements
   * Another method is you can also create a SCCM package with a .cmd script only (this cmd calls a PowerShell script on an SCCM FileShare) -> for more flexibility
