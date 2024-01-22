## Keelworks Script Manager and curated 3DS Max scripts collection

**License: MIT**

### Notes:

This repository has a collection of different 3DS Max scripts used at Keelworks to help with daily tasks. Feel free to manually download, install and use any script.

For your convenience we provided a macro script manager that can additionally be used to dynamically load all scripts into one interface which could make for a more convenient workflow. 

The scripts can be loaded individually or stacked up into the Manager as rollouts.

Installation:

There is an MZP installer that will install the Keelworks Script Manager into the user Appdata\3ds max folder for you with all scripts going into the Keelworks folder.

The installer will copy all scripts into the Keelworks script folder located under AppData.
Example:
C:\\\AppData\Local\Autodesk\3dsMax\2024 - 64bit\ENU\scripts\Keelworks

Any extra Script folders added manually under Keelworks folder will be automatically picked up by the Manager once restarted. 

Please restart Max when you install the Script Manager.

Custom editing of Scripts to work with Script Manager:

To make scripts compatible with the manager simply add the wrapper located at the bottom of each script with their relevant rollout names. In addition reading through the current scripts will give a clear idea of how the wrapper is set up.

NOTE: Re-installing the Script manager deletes the entire Keelworks Script folder should you have installed it previously for the sake of a “clean install”. So be mindful and backup any changes you may have done on relevant scripts before doing so in order not to lose them.

The script Manager is in Macro format, so you will have to manually add it to the 3ds max toolbar. It is listed under the 'Keelworks' category.

We hope to update this repository with any new scripts or script versions in the future.
