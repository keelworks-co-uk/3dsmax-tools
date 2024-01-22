

	try(DestroyDialog instanceReplacement) catch() 

	_scale = 1

	rollout instanceReplacement "Replace Instances" width:160 height:152
	(
		radioButtons mode "Select The Mode:" labels:#("Instance replacement", "Reference Replacement") align:#center
		pickButton sourceNode "The Old Node" width:146 height:24 align:#center autoDisplay:true 
		pickButton destinationNode "The New Node" width:146 height:24 align:#center autoDisplay:true
		button replaceBtn "REPLACE!" width:146 height:32 align:#center
		
		
		on replaceBtn pressed do 
			(
				if isValidNode (sourceNode.object) and isValidNode(destinationNode.object) then 
				(
					undo on 
					(
						_mode = case mode.state of (
							1: (instanceReplace sourceNode.object destinationNode.object)
							2: (referenceReplace sourceNode.object destinationNode.object)
						)
					)
				) 
				else 
				(
					messageBox "Please Select The Old And The New Node"
				)
			)
	)

	

	-- Check if the master Keelworks manager script and loading client scripts
	if globalKeelworksLoading == true  then
	(
		-- Add the rollout to the manager rollout window
		addRollout instanceReplacement masterRolloutFloat
		-- And close/collapse it by default
		instanceReplacement.open = false
	)
	else 
	(
		-- Create a new dialogue window for the rollout
		CreateDialog instanceReplacement
	)