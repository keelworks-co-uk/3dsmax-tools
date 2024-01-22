
--macroScript animationAlign category:"KeelWorks"
--(
try(DestroyDialog animationAlign) catch() 

rollout animationAlign "Animation Align" width:154 height:400
(
	
	label lbl1 "From Frame:" across:2 align:#left
	spinner 'startFrame_spn' "" width:60 range:[-1e+15,1e+15,0] type:#integer align:#right across:1
	button 'startMatch_btn' "Set Start Time" height:18 width:136
	label lbl2 "To Frame:" across:2 align:#left
	spinner 'endFrame_spn' "" width:60 range:[-1e+15,1e+15,0] type:#integer align:#right across:1
	button 'endMatch_btn' "Set End Time" height:18 width:136

	checkbox sampleFrames "Bake Every Nth Frame"
	spinner sampleToBake "Bake Every: " range:[1,1e+15,10] type:#integer align:#right across:1 enabled:false 
	
	
	group "Bake Options"
	(
	checkButton position_chb "Position" height:24 width:136 checked:true  
	checkButton rotation_chb "Rotation" height:24 width:136 checked:false 
	checkButton scale_chb "Scale" height:24 width:136 checked:false 
	)
	
	Button bake_btn "Bake!" height:36 width:136 
	
	
	group "Help:"(
		label help0 "HOW TO USE:" align:#left
		label help1 "1. Select Object(s)" align:#left
		label help2 "2. CTRL + Select Target" align:#left
		label help3 "3. Press Bake" align:#left
	)
	
	on bake_btn pressed do 
	(
		_count = selection.count
		if _count < 2 then 
		(
			messageBox "Object(s) + Target Node Must Be Selected!\nSee the How-To Section At The End of The Tool"
			return ok
		)
		_nodes = selection as array 
		_target = selection[_count]
		-- remove target from nodes 
		deleteItem _nodes _count
		
		undo on 
		(
			animate on 
			(
				print _target.transform.position
				step = 1
				if sampleFrames.state then step = sampleToBake.value
				for item in _nodes do 
				(
					for frame = startFrame_spn.value to endFrame_spn.value by step do 
					(
						at time frame 
						(
							if position_chb.state then (item.position = _target.transform.position)
							if rotation_chb.state then (item.rotation.controller.value = _target.transform.rotation)
							if scale_chb.state then (item.scale = _target.transform.scale)
						)						
					)
				)
			)
		)
	)
	
	
	on startMatch_btn pressed do startFrame_spn.value = currentTime
	on endMatch_btn pressed do endFrame_spn.value = currentTime
	
	on sampleFrames changed state do 
	(
		if state then 
		(
			sampleToBake.enabled = true 
		) else 
		(
			sampleToBake.enabled = false  
		)
	)
	
	on animationAlign open do 
	(
		startFrame_spn.value = animationRange.start
		endFrame_spn.value = animationRange.end
	)
)



-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(
	-- Add the rollout to the manager rollout window
    addRollout animationAlign masterRolloutFloat
	-- And close/collapse it by default
	animationAlign.open = false

)
else 
(
	-- Create a new dialogue window for the rollout
	CreateDialog animationAlign

)

--)
