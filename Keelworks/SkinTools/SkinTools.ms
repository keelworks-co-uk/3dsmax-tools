try
(
	cui.UnRegisterDialogBar skinModifier
	DestroyDialog skinModifier

) catch ()

rollout skinModifier "Skin Tools" width:184 height:196
(
	local _initiated = false 
	local _bone = 1
	local _skin
	
	
	button pickNode "Pick The Skin Modifier" width:180 height:24 autoDisplay:true align:#center 
	checkbutton selectionOnly "Selected Bone Only" width:180 height:24 autoDisplay:true align:#center checked:false enabled:false 

	group "Set Absoloute Value"
	(
		spinner setInner "Inner Radius:  " width:160 height:16 range:[0,1e+15,10] align:#left enabled:false 
		spinner setOuter "Outer Radius: " width:160 height:16 range:[0,1e+15,60] align:#left enabled:false 
		button setButton "Set Values"  width:166 height:34  align:#center enabled:false 
	)
	
	button selectBones "Select All Skinned Bones" width:180 height:24 autoDisplay:true align:#center 
	
	
	on selectBones pressed do 
	(
		undo on 
		(
			select ((skinOps.GetBoneNodes _skin) as array)
		)
	)
	
	
	on pickNode pressed do
	(

        _skin = modPanel.getCurrentObject()
		if classof _skin == Skin then 
		(
			pickNode.text = "Selected: " + _skin.name 
			
			-- disable the select button 
			pickNode.enabled = false 
			
			-- enable other parts
			selectionOnly.enabled = true 
			setInner.enabled = true 
			setOuter.enabled = true 
			setButton.enabled = true 
		) else 
		(
			messageBox "Select the mesh and go to modifier panel and select your skin modifier"
		)
	)
	
	on setButton pressed do 
	(
		undo on 
		(
			if selectionOnly.state then 
			(
				_bone = skinOps.GetSelectedBone _skin
				skinOps.SetInnerRadius _skin _bone 1 setInner.value 
				skinOps.SetInnerRadius _skin _bone 2 setInner.value
				skinOps.SetOuterRadius _skin _bone 1 setOuter.value
				skinOps.SetOuterRadius _skin _bone 2 setOuter.value 
			)
			else 
			(
				_bones = (skinOps.GetBoneNodes _skin).count
				for _bone = 1 to _bones do 
				(
					skinOps.SetInnerRadius _skin _bone 1 setInner.value 
					skinOps.SetInnerRadius _skin _bone 2 setInner.value
					skinOps.SetOuterRadius _skin _bone 1 setOuter.value
					skinOps.SetOuterRadius _skin _bone 2 setOuter.value 
				)
			)
		)
	
	)

	
)




-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(
	-- Add the rollout to the manager rollout window
    addRollout skinModifier masterRolloutFloat
	-- And close/collapse it by default
	skinModifier.open = false
	--cui.RegisterDialogBar alignToSurface -- your can't dock it in this mode as it is part of a rollout floater
)
else 
(
	-- Create a new dialogue window for the rollout
	CreateDialog skinModifier
	cui.RegisterDialogBar skinModifier
)
