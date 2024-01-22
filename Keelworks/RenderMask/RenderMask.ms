		
				rollout renderMaskDialog "Render Masks (based on face selection)"
  (
  	local whArr = #("256 | 256", "512 | 512", "1024 | 1024", "2048 | 2048" , "4096 | 4096", "8192 | 8192")
  	dropdownlist ddL_outputs "Render Width\Height:" width:115 pos:[5,5] items:whArr selection:2
  	button btn "Render" pos:[125,23] height:50 width:125 tooltip:"This will set Production Renderer to Scanline and Render out the Mask based on Face selection and Resolution"
   
  	on btn pressed do
  	(
		if $ != undefined then (
  		local rwh = filterstring ddL_outputs.items[ddL_outputs.selection] " | "
  		
  		(
  			renderWidth = rwh[1] as integer
  			renderHeight  = rwh[2] as integer
  		)

		renderers.production = Default_Scanline_Renderer ()
     convertToPoly $
		
		newmat = StandardMaterial()
	 newmat.name = uniquename ("MAT_" + i as string)
	 $.material = newmat
	 newmat.Diffuse = color (random 0 255) (random 0 255) (random 0 255)

        renderers.production.globalSamplerEnabled  = true
  		renderSceneDialog.update()
 		free rwh
		setUseEnvironmentMap false
        t = backgroundColor
		backgroundColor = color 0 0 0
		
		
		
------------------------------------------------------------Set White MaterialBrowseDlg
subobjectLevel = 0

meditmaterials[1] = $.material

newMaterial = standardMaterial name:"Tempbaker" diffuse:(color 255 255 255) 
newMaterial.selfIllumAmount = 100
$.material = newMaterial

		
----------------------------------------------------------------------------------------------------------------Setup mesh
		
		
modPanel.addModToSelection (Edit_Poly ()) ui:on
subobjectLevel = 4
max select invert

$.modifiers[#Edit_Poly].ButtonOp #DeleteFace




--------------------------------------------------------------------------------------Bake start
		

objs = selection as array

for o in selection do
(
o.iNodeBakeProperties.removeAllBakeElements()
be1 = diffusemap()
be1.outputSzX = renderWidth
be1.outputSzY = renderHeight
be1.fileType = ("\\" + o.name + ".png")
be1.fileName = filenameFromPath be1.fileType
be1.filterOn = true
be1.shadowsOn = false
be1.lightingOn = false
be1.enabled = true
o.INodeBakeProperties.addBakeElement be1
o.INodeBakeProperties.bakeEnabled = true
o.INodeBakeProperties.bakeChannel = 1
o.INodeBakeProperties.nDilations = 1
)
select objs
render rendertype:#bakeSelected
deleteModifier $ 1

$.material = meditmaterials[1]


subobjectLevel = 4

backgroundColor = t
---------------------------------------------------------------------------------Bake End
		
		
		
	) else messageBox "Select Object"
	
)
)

-- Check if the master Keelworks manager script and loading client scripts
if globalKeelworksLoading == true  then
(

    -- Add the rollout to the manager rollout window
    addRollout renderMaskDialog masterRolloutFloat
    -- And close/collapse it by default
    renderMaskDialog.open = false

)
else 
(
    -- Create a new dialogue window for the rollout
    createDialog renderMaskDialog width:300 height:400
    
)

	