# Splunk-Universal-Forwarder-SCCM-Package
Microsoft System Center Configuration Manager Package for Splunk Universal Forwarder without system/local configuration

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
