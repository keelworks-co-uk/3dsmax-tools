
	try(DestroyDialog maxToUnreal) catch() 

	_scale = 1

	rollout maxToUnreal "Max to UE Coordinates" width:160 height:86
	(
		button 'copyPos' "Copy Position To Clipboard" width:152 height:36 align:#center
		button 'copyRot' "Copy Rotation To Clipboard" width:152 height:36 align:#center

		on copyPos pressed do 
		(
			if selection.count != 1 then 
			(messageBox "please select a abject") 
			else 
			(
			pos = ("(X=" + (($.position.x) * _scale) as string + ", Y=" + (($.position.y * -1) * _scale) as string + ", Z=" + (($.position.z) * _scale) as string + ")")
			print pos 
			setclipboardText pos
			)
		)
		
		on copyRot pressed do 
		(
			if selection.count != 1 then 
			(messageBox "please select a abject") 
			else 
			(
			_r = $.controller.rotation as EulerAngles 
			rot = ("(Pitch=" + (_r.y * -1) as string + ",Yaw=" + (_r.z * -1) as string + ",Roll=" + (_r.x) as string + ")")
			print rot 
			setclipboardText rot
			)
		)
	)

	


	-- Check if the master Keelworks manager script and loading client scripts
	if globalKeelworksLoading == true  then
	(
		-- Add the rollout to the manager rollout window
		addRollout maxToUnreal masterRolloutFloat
		-- And close/collapse it by default
		maxToUnreal.open = false
	)
	else 
	(
		-- Create a new dialogue window for the rollout
		CreateDialog maxToUnreal
	)