
rollout Locks "4: Locks"
(

	
	button BTPos "Position" width:70 pos:[0,2]
		button PositionX "X"  width:25 pos:[70,2]
	    button PositionY "Y"  width:25 pos:[95,2]
	    button PositionZ "Z"  width:25 pos:[120,2]
	button BTRot "Rotation" width:70 pos:[0,30]
		button RotationX "X"  width:25 pos:[70,30]
	    button RotationY "Y"  width:25 pos:[95,30]
	    button RotationZ "Z"  width:25 pos:[120,30]
	button BTScale "Scale" width:70 pos:[0,55]
		button ScaleX "X"  width:25 pos:[70,55]
	    button ScaleY"Y"  width:25 pos:[95,55]
        button ScaleZ "Z"  width:25 pos:[120,55]	
	
	button BTAll "Lock ALL" width:100 height:35 pos:[150,2]
	button BTReset "Reset Locks" width:100 height:35 pos:[150,40]
	 

	on BTPos pressed do
	(
		selected = selection as array
		
		for  i in selected do
		(
			TransLock = (getTransformLockFlags i )  

			appendifunique TransLock 1
			appendifunique TransLock 2
			appendifunique TransLock 3
				
			setTransformLockFlags i TransLock
		)
		
	)
	
		on PositionX pressed do
	(
		selected = selection as array
		
		for  i in selected do
		(
			TransLock = (getTransformLockFlags i )  

			appendifunique TransLock 1
				
			setTransformLockFlags i TransLock
		)
		
	)
	
	on PositionY pressed do
	(
		selected = selection as array
		
		for i in selected do
		(
			TransLock = (getTransformLockFlags i )  

			appendifunique TransLock 2
				
			setTransformLockFlags i TransLock
		)
		
	)
	
		on PositionZ pressed do
	(
		selected = selection as array
		
		for i in selected do
		(
			TransLock = (getTransformLockFlags i )  

			appendifunique TransLock 3
				
			setTransformLockFlags i TransLock
		)
		
	)
	
	
		on BTRot pressed do
	(
		selected = selection as array
		
		for i in selected do
		(
			TransLock = (getTransformLockFlags i )  

			appendifunique TransLock 4
			appendifunique TransLock 5
			appendifunique TransLock 6
				
			setTransformLockFlags i TransLock
		)
		
	)
	
		on RotationX pressed do
	(
		selected = selection as array
		
		for  i in selected do
		(
			TransLock = (getTransformLockFlags i )  

			appendifunique TransLock 4
				
			setTransformLockFlags i TransLock
		)
		
	)
	
	on RotationY pressed do
	(
		selected = selection as array
		
		for  i in selected do
		(
			TransLock = (getTransformLockFlags i )  

			appendifunique TransLock 5
				
			setTransformLockFlags i TransLock
		)
		
	)
	
		on RotationZ pressed do
	(
		selected = selection as array
		
		for  i in selected do
		(
			TransLock = (getTransformLockFlags i )  

			appendifunique TransLock 6
				
			setTransformLockFlags i TransLock
		)
		
	)
	
	
	
			on BTScale pressed do
	(
		selected = selection as array
		
		for i in selected do
		(
			TransLock = (getTransformLockFlags i )  

			appendifunique TransLock 7
			appendifunique TransLock 8
			appendifunique TransLock 9
				
			setTransformLockFlags i TransLock
		)
		
	)
	
		on ScaleX pressed do
	(
		selected = selection as array
		
		for i in selected do
		(
			TransLock = (getTransformLockFlags i )  

			appendifunique TransLock 7
				
			setTransformLockFlags i TransLock
		)
		
	)
	
	on ScaleY pressed do
	(
		selected = selection as array
		
		for i in selected do
		(
			TransLock = (getTransformLockFlags i )  

			appendifunique TransLock 8
				
			setTransformLockFlags i TransLock
		)
		
	)
	
		on ScaleZ pressed do
	(
		selected = selection as array
		
		for i in selected do
		(
			TransLock = (getTransformLockFlags i )  

			appendifunique TransLock 9
				
			setTransformLockFlags i TransLock
		)
		
	)
	
	
		on BTReset pressed do
	(
		selected = selection as array
		
		for  i in selected do
		(
			setTransformLockFlags i #none
		)
	)
	
	
		on BTAll pressed do
	
	 (
		selected = selection as array
		
		for  i in selected do
		(
			setTransformLockFlags i #all 
		)
		
	)
	

	
	
)
				
				
-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(

    -- Add the rollout to the manager rollout window
    addRollout Locks masterRolloutFloat
    -- And close/collapse it by default
    Locks.open = false

)
else 
(
    -- Create a new dialogue window for the rollout
    createDialog Locks width:300 height:400
    
)

	