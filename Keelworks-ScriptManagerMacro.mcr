
-- Keelworks Script Manager 1.0

macroScript ScriptManagerMacro
category:"Keelworks"
tooltip:"Keelworks Script Manager 1.0"
buttonText:"Keelworks"
icon:#("Containers",10)
(
 
-- Clean up console
clearlistener()

global masterRolloutFloat

try (
    -- dont allow multiple instances of the the master rolloutFloater script manager
    closeRolloutFloater masterRolloutFloat
) catch()


-- Create a rolloutFloater
masterRolloutFloat = newRolloutFloater "Keelworks Script Manager 1.0" 280 780 style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)

-- Global variable to indicate if the Keelworks loading process is underay
-- read by client scripts to allow them to dynamically work with either the manager or without it
global globalKeelworksLoading = true

-- Get the directory of the currently executing script
scriptDir = getFilenamePath (getSourceFileName())

-- Get the path to 3dsmax user's scripts folder
userScriptsDir = getDir #userScripts

-- Create a rollout for the logo and copyright text and collapse it by default
rollout logoRollout "Info" width:400 height:100
(

    bitmap imgLogo fileName:"Keelworks-small-logo.png" pos:[10,10] width:32 height:32 

    label lblCopyright "MIT Licensed maxscripts on GitHub\n
github.com/keelworks-co-uk/3dsmax-tools\n" pos:[55,10] width:290 height:50
 
    -- Add a button control for the GitHub link
    button btnGitHub "Github Link" pos:[55,60]  width:100 height:20

    on btnGitHub pressed do
    (
        shellLaunch "https://github.com/keelworks-co-uk/3dsmax-tools" ""
    )
)

-- Add the logoRollout to the masterRolloutFloat
addRollout logoRollout masterRolloutFloat
logoRollout.open = false

-- Load and execute client scripts
fn loadClientScript filePath =
(
    try
    (
        fileIn filePath
    )
    catch
    (
        print ("-Exception: " + getCurrentException())
    )
)


-- Get a list of all subfolders of the userScriptsDir folder and store them in a variable
scriptFoldersList = getDirectories (userScriptsDir + "\\Keelworks\\*")

-- List the names of all folders found
for i = 1 to scriptFoldersList.count do
(
    -- Debugging, Print the name of the folder found
    --print (scriptFoldersList[i])

    -- Get a list of all .ms files in the current folder and store them in a variable
    scriptList = getFiles (scriptFoldersList[i]+"\\*.ms")

    -- List the names of of all .ms files found
    for j = 1 to scriptList.count do
    (
        -- Debugging, Print the name of the script found
        print ("Auto Loading " + scriptList[j])

        -- Load the script
        loadClientScript (scriptList[j])
    )

)

-- loading is done, change global flag
globalKeelworksLoading = false


)







