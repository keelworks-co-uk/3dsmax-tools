
-- Keelworks Script Manager 1.0

-- Define function that copies recursively a folder and its content
fn copyDir source destination =
(
    print "Copying files"

    -- create the destination folder if it doesnt exist
    makeDir destination
    
    -- get the subfolder folder listing of the source folder
    source_dir_content = GetDirectories (source + "\\*")

    -- for each subfolder, copy its content to the matching destination subfolder folder
    for i = 1 to source_dir_content.count do
    (
        -- get the files from the subfolder we are reading from
		source_files = getFiles (source_dir_content[i] + "\\*")

        -- the subfolder we are copying to, strip its full path, just keep the folder name with filenameFromPath
		current_target_dir = destination + "\\" + (filenameFromPath source_dir_content[i])
		
        -- create the target subfolder
		makeDir (current_target_dir)
			
		-- copy the sub files
        for j = 1 to source_files.count do
        (
			-- just keep the file name without the path with filenameFromPath
            -- and delete old files if they exist
            deleteFile (current_target_dir + "\\" + (filenameFromPath source_files[j]) )
			copyFile source_files[j] (current_target_dir + "\\" + (filenameFromPath source_files[j]) )
        )
    )

    -- copy the current root files to the destination folder root
    source_files = getFiles (source + "\\*")

    for i = 1 to source_files.count do
    (
        
        deleteFile (destination + "\\" + (filenameFromPath source_files[i]))

        copyFile source_files[i] (destination + "\\" + (filenameFromPath source_files[i]))
    )

)

-- function to install the static and dynamic files to the user's scripts and macros folders
fn install = 
(

    print "Installing Keelworks Script Manager 1.0"

    -- Define the path to the destination folders
    scriptsDir = getDir #userScripts
    scriptsDir = scriptsDir  + "\\"

    macrosDir = getDir #userMacros
    macrosDir = macrosDir  + "\\"

    -- Define the path to the temp installer source folder used bythe MZP file
    installDir = getFilenamePath(getSourceFileName()) + "\\"

    -- Define the main static name of the files to be copied
    installFile1 = "Keelworks-ScriptManagerMacro.mcr" 
    installFile2 = "Keelworks-small-logo.png" 

    -- Delete any existing files (older versions)
    deleteFile (macrosDir + installFile1)
    deleteFile (macrosDir + installFile2)

    -- Copy the files to the scripts folders
    copyFile (installDir + installFile1) (macrosDir + installFile1)
    copyFile (installDir + installFile2) (macrosDir + installFile2)

    -- delete any existing Keelworks script folder
    DOSCommand ("rmdir /s /q " + "\"" + scriptsDir + "\\Keelworks" + "\"")

    -- Copy the Keelworks scripts folder to the scripts folder recursively
    copyDir (installDir + "\\Keelworks") (scriptsDir + "\\Keelworks")
)


-- Installer dialog with some info and install buttons
rollout rolloutClient "Keelworks Script Manager Installer 1.0" width:400 height:200
(
    
    bitmap imgLogo fileName:"Keelworks-logo.png" pos:[10,10] width:90 height:90 

    label lblCopyright "MIT Licensed maxscripts can be found on GitHub
(https://github.com/keelworks-co-uk/3dsmax-tools)\n" pos:[120,10] width:290 height:50
 
    button btnGitHub "Github Link" pos:[120,50]  width:100 height:20

    on btnGitHub pressed do
    (
        shellLaunch "https://github.com/keelworks-co-uk/3dsmax-tools" ""
    )

    button btnInstall "Install Now" pos:[120,80]  width:100 height:20

    on btnInstall pressed do
    (
        
        install()
        messageBox "Keelworks Script Manager installed successfully" title:"Keelworks Script Manager 1.0" beep:false
    )

)

createDialog rolloutClient width:400 height:110