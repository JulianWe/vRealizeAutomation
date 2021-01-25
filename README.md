
# vRealizeAutomation
reusable automation items

# PowerShell script to execute Orchestrator workflow via REST API

PowerShell Script to show the input parameter and Execute Orchestrator Workflow via REST API. 
Execute-vRoWorkflow.ps1 has the following input parameters:
- Username (Testet with Active Directory User vdi\julian)
- password 
- vroServer "Example: vro8.vdi.sclabs.net"
- WorkflowID "Workflow ID from general tab in Orchestrator editor mode"
- apiFormat "json or xml"
- inputParameters "Path to input file (either json or xml)"

JSON File containing the same input parameter like the API-InputWorkflow
InputParameterBody.json File:
- ServerName (string)
- ServerIP (string)
- LocalAdminAccount (string)
- LocalAdminPassword (string)
- ServerOwner (string)
- numberOfNic (number)
- secondDisk (boolean)

com.API-InputWorkflow Workflowpackage contains VMware Orchestrator API-InputWorkflow with input values from above.

# How to use vCenter tags in VMware Orchestrator


# How to execute Ansible Playbook with VMware Orchestrator SSH Plugin
+ how to set backup IP on correct network Interface with Guest Script Manager
Package: https://github.com/JulianWe/vRealizeAutomation/blob/main/com.sunrise.AnsiblePlaybook.Backupip.package


# Day Two Operations
+ added some functionality to the PowerShell script regarding day two operations
+ change CPU count
+ change memory size
- add disk space

