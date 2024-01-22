

	
try(DestroyDialog animationKeyTools) catch() 

rollout animationKeyTools "Animation Key Tools" width:154 height:310
(

	label lbl1 "From Frame:" across:2 align:#left
	spinner 'startFrame_spn' "" width:60 range:[-1e+15,1e+15,0] type:#integer align:#right across:1
	button 'startMatch_btn' "Set Start Time" height:18 width:136
	label lbl2 "To Frame:" across:2 align:#left
	spinner 'endFrame_spn' "" width:60 range:[-1e+15,1e+15,0] type:#integer align:#right across:1
	button 'endMatch_btn' "Set End Time" height:18 width:136

	checkbox keepFrames "Keep Every Nth Frame"
	spinner frameToKeep "Keep Every: " range:[1,1e+15,10] type:#integer align:#right across:1 enabled:false 
	
	
	checkButton posCheck "Remove Position" height:20 width:136 checked:true 
	checkButton rotCheck "Remove Rotation" height:20 width:136 checked:true 
	checkButton sclCheck "Remove Scale" height:20 width:136  checked:true 
	button remove_btn "Remove Keys!" height:32 width:136

	checkbox allKeys_chk "All Keys" align:#left across:2 state:true checked:true
	spinner offsettFrame_spn "" width:60 range:[-1e+15,1e+15,0] type:#integer align:#right across:1
	button move_btn "Move Keys!" height:32 width:136



	on move_btn pressed do 
	(
		undo on 
		(
			
			if not allKeys_chk.state then 
			(
				_start = startFrame_spn.value
				_end = endFrame_spn.value

				rangeInterval = interval _start _end
				print rangeInterval
			
				for obj in selection do 
				(
					try(
					if posCheck.state then 
					(
						theController = obj.position.controller
						selectKeys theController rangeInterval
						moveKeys theController offsettFrame_spn.value #selection
						sortKeys theController 		
					))catch()
					
					try(
					if rotCheck.state then 
					(
						theController = obj.rotation.controller
						selectKeys theController rangeInterval
						moveKeys theController offsettFrame_spn.value #selection
						sortKeys theController #selection			
					))catch()	
					
					try(
					if sclCheck.state then 
					(
						theController = obj.scale.controller
						selectKeys theController rangeInterval
						moveKeys theController offsettFrame_spn.value #selection
						sortKeys theController #selection			
					))catch()
				)
			) else 
			(
				for obj in selection do 
				(
					try(if posCheck.state then 
						(
							theController = obj.position.controller
							moveKeys theController offsettFrame_spn.value 
							sortKeys theController 		
						))catch()
						
						try(
						if rotCheck.state then 
						(
							theController = obj.rotation.controller
							moveKeys theController offsettFrame_spn.value
							sortKeys theController #selection			
						))catch()	
						
						try(
						if sclCheck.state then 
						(
							theController = obj.scale.controller
							moveKeys theController offsettFrame_spn.value
							sortKeys theController #selection			
						)
					)catch()
				)
			)
			
		)
	)


	on startMatch_btn pressed do startFrame_spn.value = currentTime
	on endMatch_btn pressed do endFrame_spn.value = currentTime
	
	on keepFrames changed state do 
	(
		if state then 
		(
			frameToKeep.enabled = true 
		) else 
		(
			frameToKeep.enabled = false  
		)
	)
	
	on animationKeyTools open do 
	(
		startFrame_spn.value = animationRange.start
		endFrame_spn.value = animationRange.end
	)
	
	
	
	on remove_btn pressed do 
	(
		undo on 
		(
			
		if keepFrames.state then 
		(
			
		ind = endFrame_spn.value / frameToKeep.value
		
		for i = 0 to (ind-1) do 
			(
				_start = ((i * frameToKeep.value) +1)
				_end = ((((i * frameToKeep.value) + frameToKeep.value)) - 1)
				
				rangeInterval = interval _start _end
				print rangeInterval
				ind += 1
				
				if _start > startFrame_spn.value then 
				(
					for obj in selection do 
					(
						try(
						if posCheck.state then 
						(
							theController = obj.position.controller
							selectKeys theController rangeInterval
							deleteKeys  theController #selection				
						))catch()
						
						try(
						if rotCheck.state then 
						(
							theController = obj.rotation.controller
							selectKeys theController rangeInterval
							deleteKeys  theController #selection				
						))catch()	
						
						try(
						if sclCheck.state then 
						(
							theController = obj.scale.controller
							selectKeys theController rangeInterval
							deleteKeys  theController #selection				
						))catch()
					)
				)
			)
		)
		else 
		(
				rangeInterval = interval startFrame_spn.value endFrame_spn.value
				
				for obj in selection do 
				(
					try(
					if posCheck.state then 
					(
						theController = obj.position.controller
						selectKeys theController rangeInterval
						deleteKeys  theController #selection				
					))catch()
					
					try(
					if rotCheck.state then 
					(
						theController = obj.rotation.controller
						selectKeys theController rangeInterval
						deleteKeys  theController #selection				
					))catch()	
					
					try(
					if sclCheck.state then 
					(
						theController = obj.scale.controller
						selectKeys theController rangeInterval
						deleteKeys  theController #selection				
					))catch()
				)
		)
	)
		
	)
)



-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(
	-- Add the rollout to the manager rollout window
    addRollout animationKeyTools masterRolloutFloat
	-- And close/collapse it by default
	animationKeyTools.open = false
)
else 
(
	-- Create a new dialogue window for the rollout
	CreateDialog animationKeyTools 
)
