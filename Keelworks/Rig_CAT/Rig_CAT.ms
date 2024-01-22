
	
	 rollout RigCAT "Rig: CAT Helpers for UE"
					   
					(
						
							group "Create CAT Parent - with correct UE axis:"
(
	button CreateCAT "Create CAT Parent" width:200 height:25
	button CreateCATPath "Create CAT Path Node" width:180 height:25
)

	
on CreateCAT pressed do
(
theParent = CATParent()--create a new CATrig parent:
select theparent
theparent.Catunits = 0.5
rotate $ (angleaxis -90 [0,1,0])
rotate $ (angleaxis -90 [0,0,1])
)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------SMOOTHING GROUPS START
				on CreateCATPath pressed do
				
				(
		pt = point Box:on size:140 wirecolor:blue
		pt.pos = [0,0,0]
		rotate pt (angleaxis -90 [0,1,0])
	    rotate pt (angleaxis -90 [0,0,1])
		pt.name="CATPathNode"
		Select pt
	)

				

			)
--------------------------------------------------------------------------------------- END EXTRA TOOLS
	
-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(

    -- Add the rollout to the manager rollout window
    addRollout RigCAT masterRolloutFloat
    -- And close/collapse it by default
    RigCAT.open = false

)
else 
(
    -- Create a new dialogue window for the rollout
    createDialog RigCAT width:300 height:400
    
)
