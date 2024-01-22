
	-- Wrapper client rollout for the script that can be used independently or as part of the Keelworks manager script
	Rollout Pointers "1: Helpers"
	(
		button DeleteAllEmptyLayers "Delete All Empty Layers" width:150 height:25 tooltip:"Deletes all empty Layers in the Layer Explorer"
		spinner adjust_spn "Helper Size:" range:[0,10000,10] type:#float pos:[30,37] tooltip:"Select a Point Helper to change its Size"
	    button helperobj "Create Point Helper" width:150 height:30 tooltip:"Creates a simple point helper in the scene"
		button zerooutworld "Zero world space" width:150 height:30 tooltip:"Takes the position of the selected object to world origin"
		button zeroxform "Zero-Xform" width:150 height:30 tooltip:"Takes object's Pivot to world origin and resets Xform"
		button snaps "Snapshot Mesh" width:150 height:30 tooltip:"Creates a snapshot of the selected mesh/helper object - removes all history from it"
		button z "Create Helper on Selection" width:200 height:35 tooltip:"Creates Reference helper with matching Rotation/Position on the selected helper object"
		button deleteconstrainstrotpos "Delete position | Rotation Constraints" width:200 height:30 tooltip:"Deletes the position and/or Orientation constraints applied to the selected object(s)"
		button posorientconst "Position - Orientation Constraint" width:200 height:30 tooltip:"Select the source object and then CTRL-select the target to assign constraints to the source"
		button linkcon "Create Link Constraint" width:200 height:30 tooltip:"Select the source object and then CTRL-select the target to assign constraints to the source"
		
		
		on adjust_spn changed val do
(
   -- collect all point helpers from selection into an array called 'thePoints'
   local thePoints = for obj in selection where classof obj == point collect obj

   -- any point helpers found in current selection?
   if thePoints.count > 0 then
   (
      -- change size of all selected point helpers
      thePoints.size = val --[b]val[/b]
   )
   else
   (
      -- no point helpers in current selection
      messagebox "Please select point helper!"
   )
)






  on DeleteAllEmptyLayers pressed do	
		
			(
				fn delete_empty_layers =
(
	local counter = 0
 
	for id = LayerManager.count - 1 to 1 by -1 do
	(
		local layer = LayerManager.getLayer id
 
		local contains_nodes = LayerManager.doesLayerHierarchyContainNodes layer.name
 
		if not contains_nodes then
		(
			local deleted = LayerManager.deleteLayerByName layer.name
 
			if deleted then counter += 1
		)
	)
 
	return counter
)

delete_empty_layers()

			)





on deleteconstrainstrotpos pressed do (
	
	If $ != undefined then (
      tm = $.transform
      $.position.controller=position_XYZ()
      $.rotation.controller=Euler_XYZ()
      $.transform = tm
	)else messageBox "Select object"

	
)
on linkcon pressed do (
	If $ != undefined then (
		

								source_array = #()
							for s = 1 to selection.count - 1 do append source_array selection[s]
							for c = 1 to source_array.count do
							(
							target_obj = selection[selection.count]
							source_obj = source_array[c]
								--pt = point Box:on size:15		wirecolor:red
	                            --pt.pos = [0,0,0]
	                            --pt.transform = source_obj.transform
								
								
								
								lc = link_constraint()
								source_obj.transform.controller = lc
								source_obj.transform.controller.AddTarget target_obj -1000
								
								--source_obj.transform = pt.transform
								
								--delete pt
							)
)else messageBox "Select object"
							
							
							
							
						)


on snaps pressed do (
	
	If $ != undefined then (
		
		snapshot $
		
	)else messageBox "Select object"
	
)


on posorientconst pressed do
(
	If $ != undefined then (
		
		source_array = #()
						for s = 1 to selection.count - 1 do append source_array selection[s]
						for c = 1 to source_array.count do
						(
						target_obj = selection[selection.count]
						source_obj = source_array[c]
						
						
					Source_obj.pos.controller = Position_List()
						 Pc = Position_Constraint ()
							 Source_obj.pos.controller.available.controller = Pc
				         positionConstraint = pc.constraints
				       positionConstraint.appendtarget target_obj 100
							Source_obj.pos.controller.Position_Constraint.controller.relative = on
								
							Source_obj.rotation.controller = Rotation_list()
							 Oc = Orientation_Constraint()
							 Source_obj.rotation.controller.available.controller = Oc
					         orientConstraint = Oc.constraints
					         orientConstraint.appendtarget target_obj 100
							Source_obj.rotation.controller.Orientation_Constraint.controller.relative = on
		
	
	
)
)else messageBox "Select object"
)
	
	
on zeroxform pressed do (
If $ != undefined then (
	
	
	$.pivot = [0,0,0]
	resetXForm selection
	collapseStack selection
	
) else messagebox "Select Object"
)


on zerooutworld pressed do (
If $ != undefined then (
	
	
	$.pos = [0,0,0]
	
) else messagebox "Select Object"
)



on z pressed do	
		
			(
			
				If $ != undefined then (
						
						for obj in 1 to selection.count do
(
pt = point Box:on size:15 wirecolor:red
pt.name = selection[1].name + "_RefPT"
target = selection[obj]
pt.pos = target.pos
pt.rotation = target.rotation
pt.pos = target.pos
)

					)
					else messagebox "Select Object"
				)
	

			
			on helperobj pressed do
				
			(
				
				pt = point Box:on size:15 wirecolor:green
		pt.pos = [0,0,0]
				select pt
		--pt.transform = $.transform
				
				
			)
				
			
			

)


-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(

    -- Add the rollout to the manager rollout window
    addRollout Pointers masterRolloutFloat
    -- And close/collapse it by default
    Pointers.open = True

)
else 
(
    -- Create a new dialogue window for the rollout
    createDialog Pointers width:300 height:400
    
)

