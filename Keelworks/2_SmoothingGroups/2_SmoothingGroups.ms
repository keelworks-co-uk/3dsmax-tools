
	
	 rollout SmoothingGroups "2: Smoothing Groups"
					   
					(
	
				
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------SMOOTHING GROUPS START


				Group "Auto Smooth"
				(

					button sm0 "0" width:60 height:25 across:4
				    button sm15 "15" width:60 height:25
                    button sm30 "30" width:60 height:25
					button sm45 "45" width:60 height:25

				)
								Group "Force Reset Smoothing Groups:"
				(

					button resetsmg "Reset Smoothing Groups" width:150 height:25 tooltip:"This forces a hard reset on all Smoothing groups through Meshsmooth Modifier (overcoming a bug that sometimes occurs in Max where Smoothing groups cannot be reset) Will convert selection to Edit-Poly when done"
	

				)

				on resetsmg pressed do
					If $ != undefined then (
						
					sel = selection as array
					for obj in sel do
						(
				select obj
				ConvertTo obj Editable_Poly
		
					modPanel.addModToSelection (meshsmooth ()) ui:on
                    obj.modifiers[#MeshSmooth].iterations = 0
                    ConvertTo obj Editable_Poly
							
							
							
						)
						
						select sel
						
					) else messagebox "Select Object!"
				
				
				
				
			on sm0 pressed do
					If $ != undefined then (
						
					sel = selection as array
					for obj in sel do
						(
				select obj
				ConvertTo obj Editable_Poly
				smoothfaces = obj
				polyop.setFaceSelection smoothfaces #all
				smoothfaces.autoSmoothThreshold = 0
				smoothfaces.EditablePoly.autosmooth ()
							
						)
						
						select sel
						
					) else messagebox "Select Object!"
				

				on sm15 pressed do
				If $ != undefined then (

							sel = selection as array
					for obj in sel do
						(
				select obj
							ConvertTo obj Editable_Poly
				smoothfaces = obj
				polyop.setFaceSelection smoothfaces #all
				smoothfaces.autoSmoothThreshold = 15
				smoothfaces.EditablePoly.autosmooth ()
							
						)
						
						select sel

				) else messagebox "Select Object!"
				
								on sm30 pressed do
				If $ != undefined then (


							sel = selection as array
					for obj in sel do
						(
				select obj
							ConvertTo obj Editable_Poly
				smoothfaces = obj
				polyop.setFaceSelection smoothfaces #all
				smoothfaces.autoSmoothThreshold = 30
				smoothfaces.EditablePoly.autosmooth ()
							
						)
						
						select sel

				) else messagebox "Select Object!"
				
								on sm45 pressed do
				If $ != undefined then (

							sel = selection as array
					for obj in sel do
						(
				select obj
							ConvertTo obj Editable_Poly
				smoothfaces = obj
				polyop.setFaceSelection smoothfaces #all
				smoothfaces.autoSmoothThreshold = 45
				smoothfaces.EditablePoly.autosmooth ()
							
						)
						
						select sel

				) else messagebox "Select Object!"

			)
--------------------------------------------------------------------------------------- END EXTRA TOOLS
	
-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(

    -- Add the rollout to the manager rollout window
    addRollout SmoothingGroups masterRolloutFloat
    -- And close/collapse it by default
    SmoothingGroups.open = false

)
else 
(
    -- Create a new dialogue window for the rollout
    createDialog SmoothingGroups width:300 height:400
    
)
