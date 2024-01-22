try(DestroyDialog morphBaker)catch()
 

rollout morphBaker "Morph Baker" width:160 height:266
(
	global _targets
	pickbutton pickBtn "Pick Node" width:152 height:24 align:#center autoDisplay:true 
	
	button addBtn "Add Target Nodes" width:152 height:24 align:#center
	button clearBtn "Clear Target Nodes" width:152 height:24 align:#center
	listBox listB "" width:152 height:7 align:#center
	
	spinner bakeStep "Bake Every: " type:#integer range:[-10000, 10000, 5] width:152 align:#center
	button bakeBtn "Bake Morth Targets" width:152 height:36 align:#center

	
	on pck_test picked obj do
	(
		global _node
		_node = obj
	)

	
	on addBtn pressed do 
	(
		global _selection
		global _targets
		_targets = #()
		_collection = #()
		_selection = selection 
		for i in selection do (
			append _collection i.name
			append _targets i 
			)
		listB.items = _collection
			
	)
	
	on clearBtn pressed do 
	(
		_selection = #()
		listB.items = _selection
	)
	
	on bakeBtn pressed do 
	(
		undo on 
		(
		max create mode

		-- bake interval [gap between each target]
		_step = bakeStep.value 
		startFrame = (animationRange.start as integer) / ticksPerFrame


		-- node name 
		_node = pickBtn.object

		_mod = Morpher name:"Morph Interval"
		addModifier _node _mod 

		-- taget prefix name followed by * - Format it like this [$] + ['] + ["Prefix"] + [*] + [']

		ind = 1
		for i in _targets do
		(
			WM3_MC_BuildFromNode _mod ind i
			
			ind += 1
		)

		-- stretch the time range 
		animationRange = (Interval startFrame (_targets.count * _step))
		maxOps.setDefaultTangentType 1 1 writeInCfgFile:true  
			
		dfltInTangentType 
			
		ind = 1
		for f = startFrame to (_targets.count-1) do 
		(
			frame = (f * _step) + _step

			animate on 
			(
				at time frame 
				(
					-- previous ind = 0.0
					if ind > 1 then WM3_MC_SetValue _mod (ind-1) 0.0 

					-- current ind = 100.0
					WM3_MC_SetValue _mod ind 100.0 
					
					-- next ind = 0.0
					if ind < _targets.count then WM3_MC_SetValue _mod (ind+1) 0.0 

				)
			)
			
			ind += 1
		)

		select pickBtn.object
		max modify mode
		)	
	)
	
	
)



-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(
	-- Add the rollout to the manager rollout window
    addRollout morphBaker masterRolloutFloat
	-- And close/collapse it by default
	morphBaker.open = false
)
else 
(
	-- Create a new dialogue window for the rollout
	createDialog morphBaker
)
