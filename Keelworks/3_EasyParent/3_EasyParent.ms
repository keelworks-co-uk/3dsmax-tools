

try(DestroyDialog easyParent) catch() 

rollout easyParent "3: Easy Parent" width:154 height:300
(
	group "Quick Tools"
	(
	checkButton parent_chb "Parent" height:24 width:136 checked:true 
	checkButton position_chb "Position Constraint" height:24 width:136 checked:false 
	checkButton orientation_chb "Orientation Constraint" height:24 width:136  checked:false  
	checkButton lookat_chb "LookAt Constraint" height:24 width:136  checked:false  
	)
	
	Button apply_btn "Apply!" height:36 width:136 
	
		group "Help:"(
		label help0 "HOW TO USE:" align:#left
		label help1 "1. Select Object(s)" align:#left
		label help2 "2. CTRL + Select Target" align:#left
		label help3 "3. Press Apply" align:#left
	)
	
	on apply_btn pressed do 
	(
		undo on 
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

			for item in _nodes do 
			(
				if parent_chb.state then (item.parent = _target)
				
				if position_chb.state then (
					pCon = Position_Constraint()
					pCon.appendTarget _target 100.0
					item.position.controller = pCon)
					
				if orientation_chb.state then (
					rCon = Orientation_Constraint()
					rCon.appendTarget _target 100.0
					item.rotation.controller = rCon)
					
				if lookat_chb.state then (
					rCon = LookAt_Constraint()
					rCon.appendTarget _target 100.0
					item.rotation.controller = rCon)
					
			)
			
			format "Selected Operation(s) Applied:\n\t #[%] Selected Node(s)\n\t #[%] Main Target\n" _nodes.count _target.name 

		)
	)

)

-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(
	-- Add the rollout to the manager rollout window
    addRollout easyParent masterRolloutFloat
	-- And close/collapse it by default
	easyParent.open = false
)
else 
(
	-- Create a new dialogue window for the rollout
	CreateDialog easyParent
)
