try
(
	cui.UnRegisterDialogBar alignToSurface
	DestroyDialog alignToSurface

) catch ()

rollout alignToSurface "Anim-Align To Surface" width:184 height:296
(
	pickbutton 'pickNode' "Pick The Node" width:180 height:24 autoDisplay:true align:#center 
	pickbutton 'pickSurface' "Pick The Surface" width:180 height:24 autoDisplay:true align:#center 
	spinner 'offsetFromSurface' "Surface Offset" width:180 height:16 range:[-1e+15,1e+15,0] align:#left
	spinner 'steps' "Every Nth        " type:#integer width:180 height:16 range:[1,500,1] align:#left
	spinner 'startFrame' "Start Frame     " type:#integer  width:180 height:16 range:[-1e+15,1e+15,0] align:#left
	spinner 'endFrame' "End Frame       " type:#integer width:180 height:16 range:[-1e+15,1e+15,0] align:#left
	button 'bakeButton' "Bake"  width:180 height:34  align:#center
	spinner 'smoothIter' "Iteration          " type:#integer width:180 height:16 range:[1,50,5] align:#left
	button 'smoothRotButton' "Smooth Rotation"  width:180 height:26  align:#center
	button 'smoothPosButton' "Smooth Position"  width:180 height:26  align:#center
	button 'alignSelected' "Align Selected Nodes To Surface"  width:180 height:26  align:#center

	on alignSelected pressed do 
	(
		undo on 
			(
			_mesh = snapshot pickSurface.object

			for item in selection do 
			(
				_r = ray item.pos [0, 0, -1]
				_hit = intersectRay _mesh _r
			
				--print(_hit)
				item.pos = _hit.pos
			)
			
			delete _mesh 
			)
	)
	
	on bakeButton pressed do 
	(
		undo on 
		(
			_node = pickNode.object
			_mesh = snapshot pickSurface.object
			_transforms = #()

			_lastPos = _node.pos
			last_Y = undefined
			for frame = startFrame.value to endFrame.value do 
			(
				at time frame (
				_r = ray _node.pos [0, 0, -1]
				_hit = intersectRay _mesh _r
				_POS = _hit.pos
									
				_X = normalize _hit.dir 
				
				-- _Y = normalize (([0, 1, 0] * _node.transform) - _node.pos)
				
				_Y = _node.pos - _lastPos
				if (length(_Y) < 0.001) and (last_Y != undefined) then (_Y = last_Y)

				
				_Z = normalize (cross _X _Y)
				_Y = normalize (cross _Z _X)
				_M = matrix3 _X _Y _Z _POS 
				
				_lastPos = _node.pos
				
				_M.pos = _M.pos + (_X * offsetFromSurface.value)
				
				last_Y = _Y
				append _transforms _M
				)
			)
				
			print "_transforms"
			print _transforms.count 
			undo on 
			(
				animate on 
				(
					for f = startFrame.value to endFrame.value by steps.value do 
					(
						at time f 
						(
														
							_node.transform = _transforms[((f + 1) - startFrame.value)]
						-- _node.transform = _transforms[f]
						)
					)
				)
			)
			delete _mesh 
		)
	)
	
	on smoothRotButton pressed do 
	(
		undo on 
		(
		for iter = 0 to smoothIter.value do 
			(
			_rotations = #()

			_p = pickNode.object

			_startFrame = startFrame.value
			_endFrame = endFrame.value


			for f = _startFrame to _endFrame do 
			(
				at time f 
				(
					append _rotations _p.controller.rotation 
				)
			)


			for f = (_startFrame + 2) to (_endFrame - 1) do 
			(
				_la = Slerp _rotations[(f - 1) - _startFrame]  _rotations[(f + 1) - _startFrame] 0.5
				_lb = Slerp _rotations[f - _startFrame] _la 0.5
				
				--print ("Before: " + _rotations[f] as string)
				_rotations[f - _startFrame] = _lb
				--print ("After: " + _rotations[f] as string)
			)

			animate on
			(
				for f = _startFrame to _endFrame by steps.value do 
				(
					at time f 
					(
						_p.controller.rotation = _rotations[(f + 1) - _startFrame]
					)
				)
			)
			
			)
		)
	)
	
	on smoothPosButton pressed do 
	(
		undo on 
		(
			for iter = 0 to smoothIter.value do 
				(
				_positions = #()

				_p = pickNode.object

				_startFrame = startFrame.value
				_endFrame = endFrame.value


				for f = _startFrame to _endFrame do 
				(
					at time f 
					(
						append _positions _p.position 
					)
				)


				for f = (_startFrame + 2) to (_endFrame - 1) do 
				(
					_val = (_positions[(f - 1) - _startFrame] + _positions[(f + 1) - _startFrame] + _positions[f - _startFrame]) / 3
					--print ("Before: " + _rotations[f] as string)
					_positions[f - _startFrame] = _val
					--print ("After: " + _rotations[f] as string)
				)

				animate on
				(
					for f = _startFrame to _endFrame by steps.value do 
					(
						at time f 
						(
							_p.position = _positions[(f + 1) - _startFrame]
						)
					)
				)
				
			)
		)
	)
	
	on alignToSurface open do 
	(
		startFrame.value = animationRange.start
		endFrame.value = animationRange.end
	)
)



-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(
	-- Add the rollout to the manager rollout window
    addRollout alignToSurface masterRolloutFloat
	-- And close/collapse it by default
	alignToSurface.open = false
	--cui.RegisterDialogBar alignToSurface -- your can't dock it in this mode as it is part of a rollout floater
)
else 
(
	-- Create a new dialogue window for the rollout
	CreateDialog alignToSurface
	cui.RegisterDialogBar alignToSurface
)